const TransactionService = require('../services/transactionService');
const { validationResult } = require('express-validator');
const logger = require('../utils/logger');

class TransactionController {
    static async createTransaction(req, res, next) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const transactionData = {
                ...req.body,
                sender_id: req.user.user_id
            };

            const transaction = await TransactionService.createTransaction(transactionData);

            res.status(201).json({
                success: true,
                message: 'Transaction created successfully',
                data: { transaction }
            });
        } catch (error) {
            logger.error('Error creating transaction', { error });
            if (error.message === 'Invalid beneficiary') {
                return res.status(400).json({
                    success: false,
                    message: error.message
                });
            }
            next(error);
        }
    }

    static async getAllTransactions(req, res, next) {
        try {
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 20;
            const search = req.query.search;
            const result = await TransactionService.getAllTransactions(page, limit, search);
            
            if (!result || result.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: 'No transactions found'
                });
            }
            res.json({
                success: true,
                data: result
            });
        }
        catch (error) {
            logger.error('Error fetching transactions', { error });
            next(error);
        }
    }

    static async getUserTransactions(req, res, next) {
        try {
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 20;

            const result = await TransactionService.getUserTransactions(
                req.user.user_id,
                page,
                limit
            );

            res.json({
                success: true,
                data: result
            });
        } catch (error) {
            next(error);
        }
    }

    static async getTransactionById(req, res, next) {
        try {
            const { id } = req.params;
            const transaction = await TransactionService.getTransactionById(id, req.user.user_id);

            res.json({
                success: true,
                data: { transaction }
            });
        } catch (error) {
            if (error.message === 'Transaction not found' || error.message === 'Access denied') {
                return res.status(404).json({
                    success: false,
                    message: error.message
                });
            }
            next(error);
        }
    }

    static async updateTransactionStatus(req, res, next) {
        try {
            const { id } = req.params;
            const { status, reason } = req.body;

            const transaction = await TransactionService.updateTransactionStatus(
                id,
                status,
                reason,
                req.user.user_id
            );

            res.json({
                success: true,
                message: 'Transaction status updated successfully',
                data: { transaction }
            });
        } catch (error) {
            logger.error('Error updating transaction status', { error });
            next(error);
        }
    }

    static async calculateFees(req, res, next) {
        try {
            const { amount, currency } = req.query;

            if (!amount || !currency) {
                return res.status(400).json({
                    success: false,
                    message: 'Amount and currency are required'
                });
            }

            const fees = TransactionService.calculateFees(parseFloat(amount), currency);

            res.json({
                success: true,
                data: {
                    amount: parseFloat(amount),
                    currency,
                    fees,
                    total: parseFloat(amount) + fees
                }
            });
        } catch (error) {
            next(error);
        }
    }
}

module.exports = TransactionController;
