const AuthService = require('../services/authService');
const User = require('../models/User');
const OTPService = require('../services/otpService');
const { validationResult } = require('express-validator');

class AuthController {
    static async register(req, res, next) {
        try {
            console.log('=== REGISTER REQUEST ===');
            console.log('Body:', req.body);
            console.log('Headers:', req.headers);

            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                console.log('Validation errors:', errors.array());
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const userData = req.body;
            console.log('User data to create:', userData);
            
            // Validation manuelle supplémentaire
            const requiredFields = ['email', 'phone_number', 'first_name', 'last_name', 'password', 'country_code', 'user_type'];
            const missingFields = requiredFields.filter(field => !userData[field]);
            
            if (missingFields.length > 0) {
                console.log('Missing required fields:', missingFields);
                return res.status(400).json({
                    success: false,
                    message: 'Missing required fields',
                    missingFields
                });
            }

            console.log('Creating user with data:', userData);
            const user = await User.create(userData);
            console.log('User created:', user);

            // Générer et envoyer l'OTP
            const otpData = {
                user_id: user.user_id,
                email: user.email,
                first_name: user.first_name,
                role: user.role
            };
            
            console.log('Generating OTP for:', otpData);
            const otpToken = await OTPService.generateAndSendOTP(otpData, 'register');
            console.log('OTP token generated:', otpToken ? 'Yes' : 'No');

            // Retourner la réponse sans données sensibles
            const { password_hash, ...userResponse } = user;

            res.status(201).json({
                success: true,
                message: 'User registered successfully. Please check your email for verification code.',
                data: { 
                    user: userResponse,
                    otpToken,
                    requiresOTP: true
                }
            });
        } catch (error) {
            console.error('Register error:', error);
            
            if (error.code === '23505') {
                return res.status(409).json({
                    success: false,
                    message: 'Email or phone number already exists'
                });
            }
            
            // Erreur détaillée pour le débogage
            return res.status(500).json({
                success: false,
                message: 'Registration failed',
                error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error',
                details: process.env.NODE_ENV === 'development' ? error.stack : undefined
            });
        }
    }

    static async login(req, res, next) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                console.log('Login validation errors:', errors.array());
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const { email, password } = req.body;
            
            if (!email || !password) {
                return res.status(400).json({
                    success: false,
                    message: 'Email and password are required'
                });
            }
            
            // Vérifier les identifiants
            const user = await User.findByEmail(email);
            
            if (!user) {
                return res.status(401).json({
                    success: false,
                    message: 'Invalid credentials'
                });
            }
            const isValidPassword = await User.validatePassword(password, user.password_hash);
            
            if (!isValidPassword) {
                return res.status(401).json({
                    success: false,
                    message: 'Invalid credentials'
                });
            }

            if (user.account_status === 'SUSPENDED' || user.account_status === 'CLOSED') {
                return res.status(401).json({
                    success: false,
                    message: `Account is ${user.account_status.toLowerCase()}`
                });
            }

            // Si le compte n'est pas encore vérifié
            if (user.account_status === 'PENDING') {
                
                const otpToken = await OTPService.generateAndSendOTP({
                    user_id: user.user_id,
                    email: user.email,
                    first_name: user.first_name,
                    role: user.role
                }, 'register');

                return res.status(200).json({
                    success: true,
                    message: 'Account verification required. Please check your email for verification code.',
                    data: {
                        otpToken,
                        requiresOTP: true,
                        accountStatus: 'PENDING'
                    }
                });
            }

            // Générer et envoyer l'OTP pour la connexion sécurisée
            const otpToken = await OTPService.generateAndSendOTP({
                user_id: user.user_id,
                email: user.email,
                first_name: user.first_name,
                role: user.role
            }, 'login');

            res.json({
                success: true,
                message: 'Verification code sent to your email. Please enter the code to complete login.',
                data: {
                    otpToken,
                    requiresOTP: true
                }
            });
        } catch (error) {
            console.error('Login error:', error);
            return res.status(500).json({
                success: false,
                message: 'Login failed',
                error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
            });
        }
    }

    static async verifyOTP(req, res, next) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                console.log('OTP validation errors:', errors.array());
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const { otpToken, otp } = req.body;

            if (!otpToken || !otp) {
                return res.status(400).json({
                    success: false,
                    message: 'OTP token and code are required'
                });
            }
            
            // Vérifier l'OTP
            const userData = OTPService.verifyOTP(otpToken, otp);
            
            // Récupérer l'utilisateur complet
            const user = await User.findById(userData.user_id);
            if (!user) {
                return res.status(404).json({
                    success: false,
                    message: 'User not found'
                });
            }

            // Si c'est une vérification d'inscription, activer le compte
            if (userData.action === 'register' && user.account_status === 'PENDING') {
                
                await User.updateStatus(user.user_id, 'ACTIVE');
                user.account_status = 'ACTIVE';
            }
        
            const tokens = AuthService.generateTokens(user);
            
            // Calculer l'expiration du refresh token
            const refreshExpiresAt = new Date();
            refreshExpiresAt.setDate(refreshExpiresAt.getDate() + 7);

            // Mettre à jour l'utilisateur avec le refresh token
            await User.updateRefreshToken(user.user_id, tokens.refreshToken, refreshExpiresAt);

            // Retourner les données sans informations sensibles
            const { password_hash, refresh_token, ...userResponse } = user;

            res.json({
                success: true,
                message: userData.action === 'register' ? 
                    'Account verified and activated successfully' : 
                    'Login successful',
                data: {
                    user: userResponse,
                    tokens
                }
            });
        } catch (error) {
            
            if (error.message === 'Invalid OTP' || error.message === 'OTP expired' || error.message === 'Invalid OTP token') {
                return res.status(400).json({
                    success: false,
                    message: error.message
                });
            }
            
            return res.status(500).json({
                success: false,
                message: 'OTP verification failed',
                error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
            });
        }
    }

    static async resendOTP(req, res, next) {
        try {
        
            const { otpToken } = req.body;

            if (!otpToken) {
                return res.status(400).json({
                    success: false,
                    message: 'OTP token is required'
                });
            }

            // Décoder le token pour récupérer les données utilisateur
            try {
                const jwt = require('jsonwebtoken');
                const decoded = jwt.decode(otpToken);
                
                
                if (!decoded || !decoded.user_id) {
                    return res.status(400).json({
                        success: false,
                        message: 'Invalid OTP token'
                    });
                }

                // Vérifier que l'utilisateur existe
                const user = await User.findById(decoded.user_id);
                if (!user) {
                    return res.status(404).json({
                        success: false,
                        message: 'User not found'
                    });
                }

                // Générer un nouveau token OTP
                const newOtpToken = await OTPService.generateAndSendOTP({
                    user_id: user.user_id,
                    email: user.email,
                    first_name: user.first_name,
                    role: user.role
                }, decoded.action || 'verify');

                res.json({
                    success: true,
                    message: 'New verification code sent to your email',
                    data: {
                        otpToken: newOtpToken
                    }
                });
            } catch (error) {
                console.error('Token decode error:', error);
                return res.status(400).json({
                    success: false,
                    message: 'Invalid OTP token format'
                });
            }
        } catch (error) {
            console.error('Resend OTP error:', error);
            return res.status(500).json({
                success: false,
                message: 'Failed to resend OTP',
                error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
            });
        }
    }

    static async refreshToken(req, res, next) {
        try {
            const { refreshToken } = req.body;
            
            if (!refreshToken) {
                return res.status(400).json({
                    success: false,
                    message: 'Refresh token required'
                });
            }

            const tokens = await AuthService.refreshToken(refreshToken);

            res.json({
                success: true,
                message: 'Token refreshed successfully',
                data: { tokens }
            });
        } catch (error) {
            return res.status(401).json({
                success: false,
                message: error.message
            });
        }
    }

    static async logout(req, res, next) {
        try {
            await AuthService.logout(req.user.user_id);

            res.json({
                success: true,
                message: 'Logout successful'
            });
        } catch (error) {
            next(error);
        }
    }

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

    static async forgotPassword(req, res, next) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const { email } = req.body;

            // Vérifier si l'utilisateur existe
            const user = await User.findByEmail(email);
            if (!user) {
                // Pour des raisons de sécurité, on renvoie toujours un message de succès
                return res.json({
                    success: true,
                    message: 'If this email exists in our system, you will receive a password reset code.'
                });
            }

            // Vérifier le statut du compte
            if (user.account_status === 'SUSPENDED' || user.account_status === 'CLOSED') {
                return res.status(401).json({
                    success: false,
                    message: `Account is ${user.account_status.toLowerCase()}`
                });
            }

            // Générer et envoyer l'OTP pour la réinitialisation
            const otpToken = await OTPService.generateAndSendOTP({
                user_id: user.user_id,
                email: user.email,
                first_name: user.first_name,
                role: user.role
            }, 'password_reset');

            res.json({
                success: true,
                message: 'Password reset code sent to your email.',
                data: {
                    otpToken,
                    requiresOTP: true
                }
            });
        } catch (error) {
            console.error('Forgot password error:', error);
            return res.status(500).json({
                success: false,
                message: 'Failed to process password reset request',
                error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
            });
        }
    }

    static async resetPassword(req, res, next) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const { otpToken, otp, newPassword } = req.body;

            if (!otpToken || !otp || !newPassword) {
                return res.status(400).json({
                    success: false,
                    message: 'OTP token, code and new password are required'
                });
            }

            // Vérifier l'OTP
            const userData = OTPService.verifyOTP(otpToken, otp);

            // Vérifier que c'est bien une action de réinitialisation
            if (userData.action !== 'password_reset') {
                return res.status(400).json({
                    success: false,
                    message: 'Invalid OTP token for password reset'
                });
            }

            // Récupérer l'utilisateur
            const user = await User.findById(userData.user_id);
            if (!user) {
                return res.status(404).json({
                    success: false,
                    message: 'User not found'
                });
            }

            // Mettre à jour le mot de passe
            await User.updatePassword(user.user_id, newPassword);

            // Invalider tous les tokens existants pour des raisons de sécurité
            await User.incrementTokenVersion(user.user_id);
            await User.updateRefreshToken(user.user_id, null, null);

            res.json({
                success: true,
                message: 'Password reset successfully. Please login with your new password.'
            });
        } catch (error) {
            console.error('Reset password error:', error);
            
            if (error.message === 'Invalid OTP' || error.message === 'OTP expired' || error.message === 'Invalid OTP token') {
                return res.status(400).json({
                    success: false,
                    message: error.message
                });
            }
            
            return res.status(500).json({
                success: false,
                message: 'Password reset failed',
                error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
            });
        }
    }

    static async changePassword(req, res, next) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const { currentPassword, newPassword } = req.body;
            const userId = req.user.user_id;

            if (!currentPassword || !newPassword) {
                return res.status(400).json({
                    success: false,
                    message: 'Current password and new password are required'
                });
            }

            // Récupérer l'utilisateur complet
            const user = await User.findById(userId);
            if (!user) {
                return res.status(404).json({
                    success: false,
                    message: 'User not found'
                });
            }

            // Vérifier l'ancien mot de passe
            const isValidPassword = await User.validatePassword(currentPassword, user.password_hash);
            if (!isValidPassword) {
                return res.status(400).json({
                    success: false,
                    message: 'Current password is incorrect'
                });
            }

            // Vérifier que le nouveau mot de passe est différent
            const isSamePassword = await User.validatePassword(newPassword, user.password_hash);
            if (isSamePassword) {
                return res.status(400).json({
                    success: false,
                    message: 'New password must be different from current password'
                });
            }

            // Mettre à jour le mot de passe
            await User.updatePassword(userId, newPassword);

            // Invalider tous les autres tokens pour des raisons de sécurité
            await User.incrementTokenVersion(userId);

            res.json({
                success: true,
                message: 'Password changed successfully'
            });
        } catch (error) {
            console.error('Change password error:', error);
            return res.status(500).json({
                success: false,
                message: 'Failed to change password',
                error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
            });
        }
    }
}

module.exports = AuthController;