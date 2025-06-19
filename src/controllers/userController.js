const User = require('../models/User');
const NotificationService = require('../services/notificationService');
const { validationResult } = require('express-validator');
const logger = require('../utils/logger');

class UserController {
    static async getProfile(req, res, next) {
        try {
            const { password_hash, refresh_token, ...userProfile } = req.user;

            res.json({
                success: true,
                data: { user: userProfile }
            });
        } catch (error) {
            next(error);
        }
    }

    static async updateProfile(req, res, next) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                logger.error('Profile update validation failed', { errors: errors.array() });
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const allowedUpdates = ['first_name', 'last_name', 'city', 'address', 'date_of_birth'];
            const updates = {};
            
            Object.keys(req.body).forEach(key => {
                if (allowedUpdates.includes(key)) {
                    updates[key] = req.body[key];
                }
            });

            const user = await User.update(req.user.user_id, updates);

            const { password_hash, refresh_token, ...userResponse } = user;

            res.json({
                success: true,
                message: 'Profile updated successfully',
                data: { user: userResponse }
            });
        } catch (error) {
            next(error);
        }
    }

    static async getUserStats(req, res, next) {
        try {
            const stats = await User.getStats(req.user.user_id);

            res.json({
                success: true,
                data: { stats }
            });
        } catch (error) {
            next(error);
        }
    }

    static async getAllUsers(req, res, next) {
        try {
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 20;
            const search = req.query.search;

            const result = await User.findAll(page, limit, search);

            res.json({
                success: true,
                data: result
            });
        } catch (error) {
            next(error);
        }
    }

    static async getUserById(req, res, next) {
        try {
            const { id } = req.params;
            const user = await User.findById(id);

            if (!user) {
                return res.status(404).json({
                    success: false,
                    message: 'User not found'
                });
            }

            const { password_hash, refresh_token, ...userResponse } = user;

            res.json({
                success: true,
                data: { user: userResponse }
            });
        } catch (error) {
            next(error);
        }
    }

    static async updateUserStatus(req, res, next) {
        try {
            const { id } = req.params;
            const { account_status } = req.body;

            if (!['ACTIVE', 'SUSPENDED', 'CLOSED'].includes(account_status)) {
                return res.status(400).json({
                    success: false,
                    message: 'Invalid account status'
                });
            }

            const user = await User.updateStatus(id, account_status);

            if (!user) {
                return res.status(404).json({
                    success: false,
                    message: 'User not found'
                });
            }

            // Send notification to user
            await NotificationService.sendTransactionNotification(
                id,
                null,
                'SECURITY_ALERT',
                'Account Status Updated',
                `Your account status has been changed to ${account_status}.`
            );

            res.json({
                success: true,
                message: 'User status updated successfully',
                data: { user }
            });
        } catch (error) {
            logger.error('Error updating user status', { error });
            next(error);
        }
    }
}

module.exports = UserController;
