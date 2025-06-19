const NotificationService = require('../services/notificationService');

class NotificationController {
    static async getUserNotifications(req, res, next) {
        try {
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 20;
            const offset = (page - 1) * limit;

            const notifications = await NotificationService.getUserNotifications(
                req.user.user_id,
                limit,
                offset
            );

            res.json({
                success: true,
                data: {
                    notifications,
                    pagination: {
                        page,
                        limit,
                        hasMore: notifications.length === limit
                    }
                }
            });
        } catch (error) {
            next(error);
        }
    }

    static async getUnreadCount(req, res, next) {
        try {
            const count = await NotificationService.getUnreadCount(req.user.user_id);

            res.json({
                success: true,
                data: { unreadCount: count }
            });
        } catch (error) {
            next(error);
        }
    }

    static async markAsRead(req, res, next) {
        try {
            const { id } = req.params;
            const notification = await NotificationService.markAsRead(id, req.user.user_id);

            res.json({
                success: true,
                message: 'Notification marked as read',
                data: { notification }
            });
        } catch (error) {
            next(error);
        }
    }

    static async markAllAsRead(req, res, next) {
        try {
            await NotificationService.markAllAsRead(req.user.user_id);

            res.json({
                success: true,
                message: 'All notifications marked as read'
            });
        } catch (error) {
            next(error);
        }
    }
}

module.exports = NotificationController;
