const { supabase } = require('../config/database');

class Beneficiary {
    static async create(beneficiaryData) {
        const { data, error } = await supabase
            .from('beneficiaries')
            .insert([beneficiaryData])
            .select()
            .single();

        if (error) throw error;
        return data;
    }

    static async findByUserId(user_id) {
        const { data, error } = await supabase
            .from('beneficiaries')
            .select(`
                *,
                country:countries_currencies(country_name, currency_code, currency_symbol)
            `)
            .eq('user_id', user_id)
            .eq('is_active', true)
            .order('created_at', { ascending: false });

        if (error) throw error;
        return data;
    }

    static async findById(beneficiary_id) {
        const { data, error } = await supabase
            .from('beneficiaries')
            .select(`
                *,
                country:countries_currencies(country_name, currency_code, currency_symbol)
            `)
            .eq('beneficiary_id', beneficiary_id)
            .eq('is_active', true)
            .single();

        if (error && error.code !== 'PGRST116') throw error;
        return data;
    }

    static async update(beneficiary_id, updateData, user_id) {
        const { data, error } = await supabase
            .from('beneficiaries')
            .update({
                ...updateData,
                updated_at: new Date().toISOString()
            })
            .eq('beneficiary_id', beneficiary_id)
            .eq('user_id', user_id)
            .select()
            .single();

        if (error && error.code !== 'PGRST116') throw error;
        return data;
    }

    static async delete(beneficiary_id, user_id) {
        const { data, error } = await supabase
            .from('beneficiaries')
            .update({ is_active: false })
            .eq('beneficiary_id', beneficiary_id)
            .eq('user_id', user_id)
            .select()
            .single();

        if (error && error.code !== 'PGRST116') throw error;
        return !!data;
    }
}

module.exports = Beneficiary;
