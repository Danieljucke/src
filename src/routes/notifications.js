const express = require('express');
const NotificationController = require('../controllers/notificationController');
const { authenticateToken } = require('../middlewares/auth');

const router = express.Router();

router.get('/', authenticateToken, NotificationController.getUserNotifications);
router.get('/unread-count', authenticateToken, NotificationController.getUnreadCount);
router.patch('/:id/read', authenticateToken, NotificationController.markAsRead);
router.patch('/mark-all-read', authenticateToken, NotificationController.markAllAsRead);

module.exports = router;
