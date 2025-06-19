const Transaction = require('../models/Transaction');
const Beneficiary = require('../models/Beneficiary');
const ExchangeRateService = require('./exchangeRateService');
const NotificationService = require('./notificationService');

class TransactionService {
    static async createTransaction(transactionData) {
        const { sender_id, beneficiary_id, amount_sent, currency_sent, payment_method } = transactionData;

        // Validate beneficiary belongs to sender
        const beneficiary = await Beneficiary.findById(beneficiary_id);
        if (!beneficiary || beneficiary.user_id !== sender_id) {
            throw new Error('Invalid beneficiary');
        }

        // Get current exchange rate
        const exchangeRate = await ExchangeRateService.getRate(currency_sent, 'MAD');
        
        // Create transaction using stored procedure
        const result = await Transaction.create({
            sender_id,
            beneficiary_id,
            amount_sent: parseFloat(amount_sent),
            currency_sent,
            payment_method
        });

        // Get full transaction details
        const transaction = await Transaction.findById(result[0].p_transaction_id);

        // Send notification
        await NotificationService.sendTransactionNotification(
            sender_id,
            transaction.transaction_id,
            'TRANSACTION_INITIATED',
            'Transaction Initiated',
            `Your transfer of ${amount_sent} ${currency_sent} has been initiated.`
        );

        return transaction;
    }

    static async getAllTransactions(page = 1, limit = 20, search = '') {
        const offset = (page - 1) * limit;
        const transactions = await Transaction.findAll(limit, offset, search);
        
        return {
            transactions,
            pagination: {
                page,
                limit,
                hasMore: transactions.length === limit
            }
        };
    }

    static async getUserTransactions(user_id, page = 1, limit = 20) {
        const offset = (page - 1) * limit;
        const transactions = await Transaction.findByUserId(user_id, limit, offset);
        
        return {
            transactions,
            pagination: {
                page,
                limit,
                hasMore: transactions.length === limit
            }
        };
    }

    static async getTransactionById(transaction_id, user_id) {
        const transaction = await Transaction.findById(transaction_id);
        
        if (!transaction) {
            throw new Error('Transaction not found');
        }

        // Ensure user can only access their own transactions
        if (transaction.sender_id !== user_id) {
            throw new Error('Access denied');
        }

        return transaction;
    }

    static async updateTransactionStatus(transaction_id, status, reason = null, admin_id = null) {
        const transaction = await Transaction.updateStatus(transaction_id, status, reason);

        // Send notification based on status
        let notificationType, title, message;
        
        switch (status) {
            case 'COMPLETED':
                notificationType = 'TRANSACTION_SUCCESS';
                title = 'Transfer Completed';
                message = `Your transfer of ${transaction.amount_sent} ${transaction.currency_sent} has been completed successfully.`;
                break;
            case 'FAILED':
                notificationType = 'TRANSACTION_FAILED';
                title = 'Transfer Failed';
                message = `Your transfer has failed. ${reason || 'Please contact support.'}`;
                break;
            default:
                notificationType = 'TRANSACTION_UPDATE';
                title = 'Transfer Update';
                message = `Your transfer status has been updated to ${status}.`;
        }

        await NotificationService.sendTransactionNotification(
            transaction.sender_id,
            transaction_id,
            notificationType,
            title,
            message
        );

        return transaction;
    }

    static calculateFees(amount, currency) {
        // Basic fee calculation - 2% with minimum 5 MAD
        const feePercentage = 0.02;
        const minimumFee = 5.00;
        
        const calculatedFee = amount * feePercentage;
        return Math.max(calculatedFee, minimumFee);
    }
}

module.exports = TransactionService;
