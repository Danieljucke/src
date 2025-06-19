const { supabase } = require('../config/database');

class Transaction {
    static async create(transactionData) {
        const { data, error } = await supabase
            .rpc('createtransaction', {
                p_sender_id: transactionData.sender_id,
                p_beneficiary_id: transactionData.beneficiary_id,
                p_amount_sent: transactionData.amount_sent,
                p_currency_sent: transactionData.currency_sent,
                p_payment_method: transactionData.payment_method
            });

        if (error) throw error;
        return data;
    }

    static async findById(transaction_id) {
        const { data, error } = await supabase
            .from('transactions')
            .select(`
                *,
                sender:users!sender_id(first_name, last_name, email),
                beneficiary:beneficiaries(first_name, last_name, phone_number)
            `)
            .eq('transaction_id', transaction_id)
            .single();

        if (error && error.code !== 'PGRST116') throw error;
        return data;
    }

    static async findByUserId(user_id, limit = 20, offset = 0) {
        const { data, error } = await supabase
            .from('transactions')
            .select(`
                *,
                beneficiary:beneficiaries(first_name, last_name, country_code)
            `)
            .eq('sender_id', user_id)
            .order('initiated_at', { ascending: false })
            .range(offset, offset + limit - 1);

        if (error) throw error;
        return data;
    }

    static async updateStatus(transaction_id, status, reason = null) {
        const updates = { 
            status,
            updated_at: new Date().toISOString()
        };

        // Add timestamp based on status
        switch (status) {
            case 'CONFIRMED':
                updates.confirmed_at = new Date().toISOString();
                break;
            case 'COMPLETED':
                updates.completed_at = new Date().toISOString();
                break;
            case 'FAILED':
                updates.failed_at = new Date().toISOString();
                if (reason) updates.failure_reason = reason;
                break;
        }

        const { data, error } = await supabase
            .from('transactions')
            .update(updates)
            .eq('transaction_id', transaction_id)
            .select()
            .single();

        if (error) throw error;

        // Log status change
        await this.logStatusChange(transaction_id, status, reason);
        
        return data;
    }

    static async logStatusChange(transaction_id, new_status, reason = null) {
        const { error } = await supabase
            .from('transaction_logs')
            .insert([{
                transaction_id,
                new_status,
                change_reason: reason || `Status changed to ${new_status}`
            }]);

        if (error) throw error;
    }
}

module.exports = Transaction;
