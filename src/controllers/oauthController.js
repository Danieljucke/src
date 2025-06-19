const OAuthService = require('../services/oauthService');
const { validationResult } = require('express-validator');
const { body } = require('express-validator');
const logger = require('../utils/logger');

class OAuthController {
    
    static googleMobileValidation = [
        body('idToken')
            .notEmpty()
            .withMessage('Google ID token is required')
            .isLength({ min: 100 })
            .withMessage('Invalid token format')
    ];

    static appleValidation = [
        body('idToken')
            .notEmpty()
            .withMessage('Apple ID token is required')
            .isLength({ min: 100 })
            .withMessage('Invalid token format'),
        body('user').optional().isObject()
    ];

    static linkOAuthValidation = [
        body('provider')
            .isIn(['google', 'apple'])
            .withMessage('Invalid OAuth provider'),
        body('idToken')
            .notEmpty()
            .withMessage('ID token is required')
    ];

    static async googleAuth(req, res) {
        try {
            const state = OAuthService.generateStateToken();
            const authUrl = OAuthService.getGoogleAuthUrl(state);

            res.json({
                success: true,
                message: 'Google authorization URL generated',
                data: { 
                    authUrl,
                    state // Retourner le state pour validation côté client
                }
            });
        } catch (error) {
            console.error('Google auth URL generation failed:', error);
            return res.status(500).json({
                success: false,
                message: 'Failed to generate Google auth URL',
                error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
            });
        }
    }

    static async googleCallback(req, res) {
        try {
            const { code, error, state } = req.query;

            if (error) {
                return res.status(400).json({
                    success: false,
                    message: 'OAuth authorization denied',
                    error: error
                });
            }

            if (!code) {
                return res.status(400).json({
                    success: false,
                    message: 'Authorization code missing'
                });
            }

            // Vérifier le state token pour la sécurité CSRF
            if (state) {
                try {
                    OAuthService.verifyStateToken(state);
                } catch (stateError) {
                    return res.status(400).json({
                        success: false,
                        message: 'Invalid state parameter'
                    });
                }
            }

            console.log('Processing Google OAuth callback with code');

            // Échanger le code contre les informations utilisateur
            const oauthData = await OAuthService.exchangeGoogleCode(code);

            // Authentifier l'utilisateur
            const result = await OAuthService.authenticateOAuthUser(oauthData, 'google');

            res.json({
                success: true,
                message: result.isNewUser ? 
                    'Account created successfully with Google' : 
                    'Login successful with Google',
                data: result
            });

        } catch (error) {
            console.error('Google OAuth callback failed:', error);
            
            if (error.message.includes('Invalid Google token')) {
                return res.status(401).json({
                    success: false,
                    message: 'Invalid Google authentication'
                });
            }

            return res.status(500).json({
                success: false,
                message: 'Google OAuth authentication failed',
                error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error',
                field: error.field || 'unknown',
                details: process.env.NODE_ENV === 'development' ? error.details || error.stack : undefined,
                logger: logger.error('Google OAuth callback error', {
                    error: error.message,
                    field: error.field || 'unknown',
                    details: process.env.NODE_ENV === 'development' ? error.details || error.stack : undefined
                })
            });
        }
    }

    static async googleMobile(req, res) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const { idToken } = req.body;

            console.log('Processing Google mobile authentication');

            // Vérifier le token Google
            const oauthData = await OAuthService.verifyGoogleIdToken(idToken);

            // Authentifier l'utilisateur
            const result = await OAuthService.authenticateOAuthUser(oauthData, 'google');

            res.json({
                success: true,
                message: result.isNewUser ? 
                    'Account created successfully with Google' : 
                    'Login successful with Google',
                data: result
            });

        } catch (error) {
            console.error('Google mobile auth failed:', error);

            if (error.message === 'Invalid Google token' || error.message === 'Google email not verified') {
                return res.status(401).json({
                    success: false,
                    message: error.message
                });
            }

            return res.status(500).json({
                success: false,
                message: 'Google authentication failed',
                error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error',
                field: error.field || 'unknown',
                details: process.env.NODE_ENV === 'development' ? error.details || error.stack : undefined,
                logger: logger.error('Google mobile auth error', {
                    error: error.message,
                    field: error.field || 'unknown',
                    details: process.env.NODE_ENV === 'development' ? error.details || error.stack : undefined
                })
            });
        }
    }

    static async appleAuth(req, res) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const { idToken, user } = req.body;

            console.log('Processing Apple authentication');

            // Vérifier le token Apple
            const oauthData = await OAuthService.verifyAppleIdToken(idToken);

            // Apple peut fournir des données utilisateur supplémentaires lors de la première connexion
            if (user && user.name) {
                oauthData.name = `${user.name.firstName || ''} ${user.name.lastName || ''}`.trim();
                oauthData.given_name = user.name.firstName;
                oauthData.family_name = user.name.lastName;
            }

            // Authentifier l'utilisateur
            const result = await OAuthService.authenticateOAuthUser(oauthData, 'apple');

            res.json({
                success: true,
                message: result.isNewUser ? 
                    'Account created successfully with Apple' : 
                    'Login successful with Apple',
                data: result
            });

        } catch (error) {
            console.error('Apple auth failed:', error);

            if (error.message === 'Invalid Apple token') {
                return res.status(401).json({
                    success: false,
                    message: 'Invalid Apple token'
                });
            }

            return res.status(500).json({
                success: false,
                message: 'Apple authentication failed',
                error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error',
                field: error.field || 'unknown',
                details: process.env.NODE_ENV === 'development' ? error.details || error.stack : undefined,
                logger: logger.error('Apple auth error', {
                    error: error.message,
                    field: error.field || 'unknown',
                    details: process.env.NODE_ENV === 'development' ? error.details || error.stack : undefined
                })
            });
        }
    }

    static async linkOAuthAccount(req, res) {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const { provider, idToken } = req.body;
            const userId = req.user.user_id;

            console.log(`Linking ${provider} account for user:`, userId);

            let oauthData;

            // Vérifier le token selon le provider
            if (provider === 'google') {
                oauthData = await OAuthService.verifyGoogleIdToken(idToken);
            } else if (provider === 'apple') {
                oauthData = await OAuthService.verifyAppleIdToken(idToken);
            }

            // Utiliser la méthode du modèle User pour lier le compte
            const User = require('../models/User');
            
            const additionalData = {};
            if (oauthData.picture && provider === 'google' && !req.user.profile_picture) {
                additionalData.profile_picture = oauthData.picture;
            }

            await User.linkOAuthAccount(userId, provider, oauthData.id, additionalData);

            res.json({
                success: true,
                message: `${provider.charAt(0).toUpperCase() + provider.slice(1)} account linked successfully`
            });

        } catch (error) {
            console.error('OAuth account linking failed:', error);

            if (error.message.includes('already linked')) {
                return res.status(409).json({
                    success: false,
                    message: error.message
                });
            }

            return res.status(500).json({
                success: false,
                message: 'Failed to link OAuth account',
                error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error',
                field: error.field || 'unknown',
                details: process.env.NODE_ENV === 'development' ? error.details || error.stack : undefined,
                logger: logger.error('OAuth account linking error', {
                    error: error.message,
                    field: error.field || 'unknown',
                    details: process.env.NODE_ENV === 'development' ? error.details || error.stack : undefined
                })
            });
        }
    }

    static async unlinkOAuthAccount(req, res) {
        try {
            const { provider } = req.params;
            const userId = req.user.user_id;

            if (!['google', 'apple'].includes(provider)) {
                return res.status(400).json({
                    success: false,
                    message: 'Invalid OAuth provider'
                });
            }

            console.log(`Unlinking ${provider} account for user:`, userId);

            const User = require('../models/User');
            const user = req.user;

            // Vérifier que l'utilisateur a un autre moyen de connexion
            const hasPassword = user.password_hash && !user.is_oauth_user;
            const hasOtherOAuth = (provider === 'google' && user.apple_id) ||
                                  (provider === 'apple' && user.google_id);

            if (!hasPassword && !hasOtherOAuth) {
                return res.status(400).json({
                    success: false,
                    message: 'Cannot unlink the only authentication method. Please set a password first.'
                });
            }

            // Délier le compte OAuth
            await User.unlinkOAuthAccount(userId, provider);

            res.json({
                success: true,
                message: `${provider.charAt(0).toUpperCase() + provider.slice(1)} account unlinked successfully`
            });

        } catch (error) {
            console.error('OAuth account unlinking failed:', error);
            return res.status(500).json({
                success: false,
                message: 'Failed to unlink OAuth account',
                error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error',
                field: error.field || 'unknown',
                details: process.env.NODE_ENV === 'development' ? error.details || error.stack : undefined,
                logger: logger.error('OAuth account unlinking error', {
                    error: error.message,
                    field: error.field || 'unknown',
                    details: process.env.NODE_ENV === 'development' ? error.details || error.stack : undefined
                })
            });
        }
    }

    static async getOAuthStatus(req, res) {
        try {
            const user = req.user;

            const oauthStatus = {
                google: {
                    linked: !!user.google_id,
                    id: user.google_id ? user.google_id.substring(0, 8) + '...' : null
                },
                apple: {
                    linked: !!user.apple_id,
                    id: user.apple_id ? user.apple_id.substring(0, 8) + '...' : null
                },
                isOAuthUser: user.is_oauth_user,
                hasPassword: !!user.password_hash,
                profilePicture: user.profile_picture
            };

            res.json({
                success: true,
                message: 'OAuth status retrieved successfully',
                data: oauthStatus
            });

        } catch (error) {
            console.error('Failed to get OAuth status:', error);
            return res.status(500).json({
                success: false,
                message: 'Failed to retrieve OAuth status',
                error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error',
                field: error.field || 'unknown',
                details: process.env.NODE_ENV === 'development' ? error.details || error.stack : undefined,
                logger: logger.error('OAuth status retrieval error', {
                    error: error.message,
                    field: error.field || 'unknown',
                    details: process.env.NODE_ENV === 'development' ? error.details || error.stack : undefined
                })
            });
        }
    }
}

module.exports = OAuthController;
