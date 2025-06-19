const { OAuth2Client } = require('google-auth-library');
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');
const User = require('../models/User');
const AuthService = require('./authService');
const CountryMappingUtils = require('../utils/countryMapping');
const logger = require('../utils/logger');

class OAuthService {
    constructor() {
        // Configuration Google OAuth
        this.googleClient = new OAuth2Client(
            process.env.GOOGLE_CLIENT_ID,
            process.env.GOOGLE_CLIENT_SECRET,
            process.env.GOOGLE_REDIRECT_URI
        );

        // Configuration Apple OAuth
        this.appleClientId = process.env.APPLE_CLIENT_ID;
        this.appleTeamId = process.env.APPLE_TEAM_ID;
        this.appleKeyId = process.env.APPLE_KEY_ID;
        this.applePrivateKey = process.env.APPLE_PRIVATE_KEY?.replace(/\\n/g, '\n');

        // Client JWKS pour Apple
        this.appleJwksClient = jwksClient({
            jwksUri: 'https://appleid.apple.com/auth/keys',
            cache: true,
            cacheMaxAge: 86400000, // 24 heures
            rateLimit: true,
            jwksRequestsPerMinute: 10
        });
    }

    // ==================== GOOGLE OAUTH ====================
    
    getGoogleAuthUrl(state = null) {
        const scopes = [
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/userinfo.profile'
        ];

        const authUrl = this.googleClient.generateAuthUrl({
            access_type: 'offline',
            scope: scopes,
            prompt: 'consent',
            state: state // Pour la sécurité CSRF
        });

        return authUrl;
    }

    async verifyGoogleIdToken(idToken) {
        try {
            const ticket = await this.googleClient.verifyIdToken({
                idToken: idToken,
                audience: process.env.GOOGLE_CLIENT_ID
            });

            const payload = ticket.getPayload();

            if (!payload.email_verified) {
                throw new Error('Google email not verified');
            }

            return {
                id: payload.sub,
                email: payload.email,
                name: payload.name,
                given_name: payload.given_name,
                family_name: payload.family_name,
                picture: payload.picture,
                email_verified: payload.email_verified,
                locale: payload.locale
            };
        } catch (error) {
            console.error('Google token verification failed:', error);
            logger.error('Google token verification failed:', error);
            throw new Error('Invalid Google token');
        }
    }

    async exchangeGoogleCode(code) {
        try {
            const { tokens } = await this.googleClient.getToken(code);
            
            if (!tokens.id_token) {
                throw new Error('No ID token received from Google');
            }

            return await this.verifyGoogleIdToken(tokens.id_token);
        } catch (error) {
            console.error('Google code exchange failed:', error);
            logger.error('Google code exchange failed:', error);
            throw new Error('Failed to exchange Google authorization code');
            
        }
    }

    // ==================== APPLE OAUTH ====================

    generateAppleClientSecret() {
        if (!this.applePrivateKey) {
            throw new Error('Apple private key not configured');
        }

        const now = Math.floor(Date.now() / 1000);
        
        const payload = {
            iss: this.appleTeamId,
            iat: now,
            exp: now + 3600, // 1 heure
            aud: 'https://appleid.apple.com',
            sub: this.appleClientId
        };

        return jwt.sign(payload, this.applePrivateKey, {
            algorithm: 'ES256',
            keyid: this.appleKeyId
        });
    }

    async getApplePublicKey(kid) {
        return new Promise((resolve, reject) => {
            this.appleJwksClient.getSigningKey(kid, (err, key) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(key.getPublicKey());
                }
            });
        });
    }

    async verifyAppleIdToken(idToken) {
        try {
            // Décoder le header pour obtenir le kid
            const decoded = jwt.decode(idToken, { complete: true });
            
            if (!decoded || !decoded.header.kid) {
                throw new Error('Invalid Apple ID token format');
            }

            // Récupérer la clé publique Apple
            const publicKey = await this.getApplePublicKey(decoded.header.kid);

            // Vérifier le token avec la clé publique
            const payload = jwt.verify(idToken, publicKey, {
                algorithms: ['RS256'],
                audience: this.appleClientId,
                issuer: 'https://appleid.apple.com'
            });

            return {
                id: payload.sub,
                email: payload.email,
                email_verified: payload.email_verified === 'true',
                is_private_email: payload.is_private_email === 'true',
                real_user_status: payload.real_user_status
            };
        } catch (error) {
            console.error('Apple token verification failed:', error);
            logger.error('Apple token verification failed:', error);
            throw new Error('Invalid Apple token');
        }
    }

    async findOrCreateOAuthUser(oauthData, provider) {
        try {
            const { email, id: providerId } = oauthData;

            // Vérifier si l'utilisateur existe déjà avec cet OAuth ID
            let user = await User.findByOAuthId(provider, providerId);
            
            if (user) {
                // Utilisateur existant avec cet OAuth ID
                await this.updateLastLogin(user.user_id);
                return { user, isNewUser: false };
            }

            // Vérifier si un utilisateur existe avec cet email
            user = await User.findByEmail(email);
            
            if (user) {
                // Utilisateur existant avec cet email - lier le compte OAuth
                const updateData = {
                    [`${provider}_id`]: providerId,
                    last_login: new Date().toISOString()
                };

                if (oauthData.picture && provider === 'google' && !user.profile_picture) {
                    updateData.profile_picture = oauthData.picture;
                }

                user = await User.update(user.user_id, updateData);
                return { user, isNewUser: false };
            }

            // Créer un nouveau utilisateur
            const userData = this.buildUserDataFromOAuth(oauthData, provider, providerId);
            user = await User.create(userData);
            
            console.log(`New user created via ${provider}:`, user.user_id);
            return { user, isNewUser: true };

        } catch (error) {
            console.error('Error in findOrCreateOAuthUser:', error);
            logger.error('Error in findOrCreateOAuthUser:', error);
            throw error;
        }
    }

    buildUserDataFromOAuth(oauthData, provider, providerId) {
        const names = this.extractNames(oauthData);
        const countryCode = CountryMappingUtils.determineCountryCode(oauthData);
        console.log('Determined country code:', countryCode);
        
        return {
            email: oauthData.email,
            phone_number: this.generateTemporaryPhone(),
            first_name: names.firstName,
            last_name: names.lastName,
            password: this.generateRandomPassword(),
            country_code: countryCode,
            user_type: 'SENDER',
            account_status: 'ACTIVE',
            [`${provider}_id`]: providerId,
            profile_picture: oauthData.picture || null,
            is_oauth_user: true
        };
    }

    extractNames(oauthData) {
        let firstName = 'User';
        let lastName = 'OAuth';

        if (oauthData.given_name && oauthData.family_name) {
            firstName = oauthData.given_name;
            lastName = oauthData.family_name;
        } else if (oauthData.name) {
            const nameParts = oauthData.name.split(' ');
            firstName = nameParts[0] || 'User';
            lastName = nameParts.slice(1).join(' ') || 'OAuth';
        }

        return { firstName, lastName };
    }

    async authenticateOAuthUser(oauthData, provider) {
        try {
            // Valider les données OAuth
            this.validateOAuthData(oauthData, provider);

            // Trouver ou créer l'utilisateur
            const { user, isNewUser } = await this.findOrCreateOAuthUser(oauthData, provider);

            // Vérifier le statut du compte
            if (user.account_status !== 'ACTIVE') {
                throw new Error(`Account is ${user.account_status.toLowerCase()}`);
            }

            // Générer les tokens
            const tokens = AuthService.generateTokens(user);

            // Mettre à jour le refresh token
            const refreshExpiresAt = new Date();
            refreshExpiresAt.setDate(refreshExpiresAt.getDate() + 7);
            
            await User.updateRefreshToken(user.user_id, tokens.refreshToken, refreshExpiresAt);

            // Préparer la réponse
            const { password_hash, refresh_token, ...userResponse } = user;

            return {
                user: userResponse,
                tokens,
                isNewUser,
                requiresPhoneVerification: isNewUser || user.phone_number?.startsWith('temp_')
            };

        } catch (error) {
            console.error(`OAuth authentication failed for ${provider}:`, error);
            logger.error(`OAuth authentication failed for ${provider}:`, error);
            throw error;
        }
    }

    async updateLastLogin(userId) {
        await User.update(userId, {
            last_login: new Date().toISOString()
        });
    }

    // ==================== UTILITAIRES ====================

    generateTemporaryPhone() {
        const timestamp = Date.now();
        const random = Math.floor(Math.random() * 1000);
        return `temp_${timestamp}_${random}`;
    }

    generateRandomPassword() {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';
        let password = '';
        for (let i = 0; i < 16; i++) {
            password += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return password;
    }

    validateOAuthData(data, provider) {
        const requiredFields = ['id', 'email'];
        
        for (const field of requiredFields) {
            if (!data[field]) {
                throw new Error(`Missing required ${provider} OAuth field: ${field}`);
            }
        }

        // Vérifier le format de l'email
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(data.email)) {
            throw new Error('Invalid email format from OAuth provider');
        }

        return true;
    }

    // ==================== SÉCURITÉ ====================

    generateStateToken() {
        return jwt.sign(
            { 
                timestamp: Date.now(),
                random: Math.random()
            },
            process.env.JWT_SECRET,
            { expiresIn: '10m' }
        );
    }

    verifyStateToken(state) {
        try {
            return jwt.verify(state, process.env.JWT_SECRET);
        } catch (error) {
            throw new Error('Invalid state token');
        }
    }
}

module.exports = new OAuthService();
