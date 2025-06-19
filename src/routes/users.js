const express = require('express');
const { body } = require('express-validator');
const UserController = require('../controllers/userController');
const { authenticateToken, requireRole } = require('../middlewares/auth');

const router = express.Router();

// Routes
router.get('/profile', authenticateToken, UserController.getProfile);
router.put('/profile', authenticateToken, UserController.updateProfile);
router.get('/stats', authenticateToken, UserController.getUserStats);

// Admin routes
router.get('/', authenticateToken, requireRole(['ADMIN']), UserController.getAllUsers);
router.get('/:id', authenticateToken, requireRole(['ADMIN']), UserController.getUserById);
router.patch('/:id/status', authenticateToken, requireRole(['ADMIN']), UserController.updateUserStatus);

module.exports = router;
