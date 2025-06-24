const AuthService = require('../services/authService');
const User = require('../models/User');
const OTPService = require('../services/otpService');
const { validationResult } = require('express-validator');
const jwt = require('jsonwebtoken');
const logger = require('../utils/logger');

class AuthController {
    // Méthodes utilitaires statiques
    static _handleValidationErrors(req, res) {
        const errors = validationResult(req);
        if (!errors.isEmpty())  return res.status(400).json({ success: false, message: 'Validation failed', errors: errors.array() });
        return null;
    }
    static _handleError(error, res, customMessage = 'Operation failed') {
        console.error(`${customMessage}:`, error);
        // Gestion des erreurs spécifiques
        const errorHandlers = {
            '23505': () => res.status(409).json({ success: false, message: 'Email or phone number already exists' }),
            'INVALID_CREDENTIALS': () => res.status(401).json({ success: false, message: 'Invalid credentials'}),
            'ACCOUNT_SUSPENDED': () => res.status(401).json({ success: false, message: 'Account is suspended'}),
            'ACCOUNT_CLOSED': () => res.status(401).json({ success: false, message: 'Account is closed'}),
            'USER_NOT_FOUND': () => res.status(404).json({ success: false, message: 'User not found'}),
            'INVALID_OTP': () => res.status(400).json({ success: false, message: 'Invalid or expired verification code' })
        };
        const handler = errorHandlers[error.code] || errorHandlers[error.message];
        if (handler) return handler();
        // Erreur générique
        return res.status(500).json({
            success: false,
            message: customMessage,
            fieldErrors: error.fieldErrors,
            error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error',
            logger: logger.error(error.message, {error: error.message, fieldErrors: error.fieldErrors, details: process.env.NODE_ENV === 'development' ? error.details || error.stack : undefined})
        });
    }
    static _sanitizeUser(user) {
        const { password_hash, refresh_token, ...sanitizedUser } = user;
        return sanitizedUser;
    }
    static _validateRequiredFields(data, requiredFields) {
        return requiredFields.filter(field => !data[field]);
    }
    static async _generateOTPResponse(user, action, message) {
        const otpToken = await OTPService.generateAndSendOTP({ user_id: user.user_id, email: user.email, first_name: user.first_name, role: user.role}, action);
        return { success: true, message, data: {otpToken, requiresOTP: true, ...(action === 'register' && { accountStatus: user.account_status })} };
    }

    static async register(req, res, next) {
        try {
            // Validation
            const validationError = AuthController._handleValidationErrors(req, res);
            if (validationError) return validationError;
            const userData = req.body;
            // Validation des champs requis
            const requiredFields = ['email', 'phone_number', 'first_name', 'last_name', 'password', 'country_code', 'user_type'];
            const missingFields = AuthController._validateRequiredFields(userData, requiredFields);
            if (missingFields.length > 0) return res.status(400).json({ success: false, message: 'Missing required fields', missingFields });
            // Création de l'utilisateur
            const user = await User.create(userData);
            // Génération et envoi de l'OTP
            const response = await AuthController._generateOTPResponse( user, 'register', 'User registered successfully. Please check your email for verification code.');
            response.data.user = AuthController._sanitizeUser(user);
            return res.status(201).json(response);
        } catch (error) {
            return AuthController._handleError(error, res, 'Registration failed');
        }
    }
    static async login(req, res, next) {
        try {
            // Validation
            const validationError = AuthController._handleValidationErrors(req, res);
            if (validationError) return validationError;

            const { email, password } = req.body;
            if (!email || !password) return res.status(400).json({success: false,message: 'Email and password are required'});
            
            // Vérification des identifiants
            const user = await User.findByEmail(email);
            if (!user || !(await User.validatePassword(password, user.password_hash))) throw new Error('INVALID_CREDENTIALS');
            // Vérification du statut du compte
            if (['SUSPENDED', 'CLOSED'].includes(user.account_status)) throw new Error(`ACCOUNT_${user.account_status}`);
            // Gestion du compte non vérifié
            if (user.account_status === 'PENDING') {
                const response = await AuthController._generateOTPResponse(user,'register','Account verification required. Please check your email for verification code.');
                response.data.accountStatus = 'PENDING';
                return res.status(200).json(response);
            }
            // Génération de l'OTP pour la connexion
            const response = await AuthController._generateOTPResponse(user, 'login', 'Verification code sent to your email. Please enter the code to complete login.');
            return res.json(response);
        } catch (error) {
            return AuthController._handleError(error, res, 'Login failed');
        }
    }

    static async verifyOTP(req, res, next) {
        try {
            // Validation
            const validationError = AuthController._handleValidationErrors(req, res);
            if (validationError) return validationError;
            const { otpToken, otp } = req.body;
            if (!otpToken || !otp) return res.status(400).json({success: false, message: 'OTP token and code are required'});
            // Vérification de l'OTP
            let userData;
            try {
                userData = OTPService.verifyOTP(otpToken, otp);
            } catch (error) {
                throw new Error('INVALID_OTP');
            }
            // Récupération de l'utilisateur
            const user = await User.findById(userData.user_id);
            if (!user) throw new Error('USER_NOT_FOUND');
            // Activation du compte si nécessaire
            if (userData.action === 'register' && user.account_status === 'PENDING') { await User.updateStatus(user.user_id, 'ACTIVE'); user.account_status = 'ACTIVE'; }
            // Génération des tokens
            const tokens = AuthService.generateTokens(user);
            // Mise à jour du refresh token
            const refreshExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 jours
            await User.updateRefreshToken(user.user_id, tokens.refreshToken, refreshExpiresAt);
            return res.json({success: true, message: userData.action === 'register' ? 'Account verified and activated successfully' : 'Login successful', data: {user: AuthController._sanitizeUser(user),tokens}});
        } catch (error) {
            return AuthController._handleError(error, res, 'OTP verification failed');
        }
    }

    static async resendOTP(req, res, next) {
        try {
            const { otpToken } = req.body;

            if (!otpToken) return res.status(400).json({success: false, message: 'OTP token is required'});
            // Décodage du token
            let decoded;
            try {
                decoded = jwt.decode(otpToken);
                if (!decoded?.user_id) throw new Error('Invalid token structure');
            } catch (error) {
                return res.status(400).json({ success: false, message: 'Invalid OTP token format'});
            }
            // Vérification de l'utilisateur
            const user = await User.findById(decoded.user_id);
            if (!user) throw new Error('USER_NOT_FOUND');
            // Génération d'un nouveau token OTP
            const newOtpToken = await OTPService.generateAndSendOTP({
                user_id: user.user_id,
                email: user.email,
                first_name: user.first_name,
                role: user.role
            }, decoded.action || 'verify');
            return res.json({success: true, message: 'New verification code sent to your email', data: { otpToken: newOtpToken } });
        } catch (error) {
            return AuthController._handleError(error, res, 'Failed to resend OTP');
        }
    }

    static async refreshToken(req, res, next) {
        try {
            const { refreshToken } = req.body;
            if (!refreshToken) return res.status(400).json({ success: false, message: 'Refresh token required'});
            const tokens = await AuthService.refreshToken(refreshToken);
            return res.json({ success: true, message: 'Token refreshed successfully', data: { tokens } });
        } catch (error) {
            return res.status(401).json({ success: false, message: error.message});
        }
    }

    static async logout(req, res, next) {
        try {
            await AuthService.logout(req.user.user_id);
            return res.json({ success: true, message: 'Logout successful'});
        } catch (error) {
            next(error);
        }
    }

    static async getProfile(req, res, next) {
        try {
            return res.json({ success: true, data: { user: AuthController._sanitizeUser(req.user) } });
        } catch (error) {
            next(error);
        }
    }

    static async forgotPassword(req, res, next) {
        try {
            // Validation
            const validationError = AuthController._handleValidationErrors(req, res);
            if (validationError) return validationError;

            const { email } = req.body;

            // Vérification de l'utilisateur
            const user = await User.findByEmail(email);
            if (!user) return res.json({ success: true, message: 'If this email exists in our system, you will receive a password reset code.' });
        
            // Vérification du statut du compte
            if (['SUSPENDED', 'CLOSED'].includes(user.account_status)) throw new Error(`ACCOUNT_${user.account_status}`);

            // Génération et envoi de l'OTP
            const response = await AuthController._generateOTPResponse(user, 'password_reset', 'Password reset code sent to your email.');
            return res.json(response);
        } catch (error) {
            return AuthController._handleError(error, res, 'Failed to process password reset request');
        }
    }

    static async resetPassword(req, res, next) {
        try {
            // Validation
            const validationError = AuthController._handleValidationErrors(req, res);
            if (validationError) return validationError;
            const { otpToken, otp, newPassword } = req.body;
            if (!otpToken || !otp || !newPassword) return res.status(400).json({ success: false, message: 'OTP token, code and new password are required'});
            // Vérification de l'OTP
            let userData;
            try {
                userData = OTPService.verifyOTP(otpToken, otp);
            } catch (error) {
                throw new Error('INVALID_OTP');
            }
            if (userData.action !== 'password_reset') return res.status(400).json({ success: false, message: 'Invalid OTP token for password reset'});
            const user = await User.findById(userData.user_id);
            if (!user) throw new Error('USER_NOT_FOUND');

            // Mise à jour du mot de passe et invalidation des tokens
            await Promise.all([ User.updatePassword(user.user_id, newPassword), User.incrementTokenVersion(user.user_id), User.updateRefreshToken(user.user_id, null, null)]);
            return res.json({ success: true, message: 'Password reset successfully. Please login with your new password.'});

        } catch (error) {
            return AuthController._handleError(error, res, 'Password reset failed');
        }
    }

    static async changePassword(req, res, next) {
        try {
            // Validation
            const validationError = AuthController._handleValidationErrors(req, res);
            if (validationError) return validationError;
            const { currentPassword, newPassword } = req.body;
            const userId = req.user.user_id;
            if (!currentPassword || !newPassword) return res.status(400).json({ success: false, message: 'Current password and new password are required' });
            // Récupération de l'utilisateur
            const user = await User.findById(userId);
            if (!user) throw new Error('USER_NOT_FOUND');
            // Vérification de l'ancien mot de passe
            if (!(await User.validatePassword(currentPassword, user.password_hash))) return res.status(400).json({ success: false, message: 'Current password is incorrect'});
            // Vérification que le nouveau mot de passe est différent
            if (await User.validatePassword(newPassword, user.password_hash)) return res.status(400).json({ success: false, message: 'New password must be different from current password'});
            // Mise à jour du mot de passe et invalidation des tokens
            await Promise.all([ User.updatePassword(userId, newPassword), User.incrementTokenVersion(userId) ]);

            return res.json({ success: true, message: 'Password changed successfully' });
        } catch (error) {
            return AuthController._handleError(error, res, 'Failed to change password');
        }
    }
}

module.exports = AuthController;