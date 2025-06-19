const express = require('express');
const { body } = require('express-validator');
const AuthController = require('../controllers/authController');
const { authenticateToken } = require('../middlewares/auth');

const router = express.Router();

// Validation rules
const registerValidation = [
    body('email').isEmail().normalizeEmail(),
    body('phone_number').isMobilePhone(),
    body('first_name').trim().isLength({ min: 2, max: 100 }),
    body('last_name').trim().isLength({ min: 2, max: 100 }),
    body('password').isLength({ min: 8 }).matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/),
    body('country_code').isLength({ min: 2, max: 3 }),
    body('user_type').isIn(['SENDER', 'RECEIVER']),
];

const loginValidation = [
    body('email').isEmail().normalizeEmail(),
    body('password').notEmpty()
];

const otpValidation = [
    body('otpToken').notEmpty().withMessage('OTP token is required'),
    body('otp').isLength({ min: 4, max: 4 }).isNumeric().withMessage('OTP must be 4 digits')
];

const resendOTPValidation = [
    body('otpToken').notEmpty().withMessage('OTP token is required')
];

const forgotPasswordValidation = [
    body('email').isEmail().normalizeEmail()
];

const resetPasswordValidation = [
    body('otpToken').notEmpty().withMessage('OTP token is required'),
    body('otp').isLength({ min: 4, max: 4 }).isNumeric().withMessage('OTP must be 4 digits'),
    body('newPassword').isLength({ min: 8 }).matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/).withMessage('Password must be at least 8 characters with uppercase, lowercase and number')
];

const changePasswordValidation = [
    body('currentPassword').notEmpty().withMessage('Current password is required'),
    body('newPassword').isLength({ min: 8 }).matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/).withMessage('New password must be at least 8 characters with uppercase, lowercase and number')
];




// Routes
router.post('/register', registerValidation, AuthController.register);
router.post('/login', loginValidation, AuthController.login);
router.post('/verify-otp', otpValidation, AuthController.verifyOTP);
router.post('/resend-otp', resendOTPValidation, AuthController.resendOTP);
router.post('/refresh-token', AuthController.refreshToken);
router.post('/logout', authenticateToken, AuthController.logout);
router.post('/forgot-password', forgotPasswordValidation, AuthController.forgotPassword);
router.post('/reset-password', resetPasswordValidation, AuthController.resetPassword);
router.post('/change-password', authenticateToken, changePasswordValidation, AuthController.changePassword);
router.get('/profile', authenticateToken, AuthController.getProfile);

module.exports = router;