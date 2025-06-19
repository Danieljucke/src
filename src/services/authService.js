const jwt = require('jsonwebtoken');
const { secret, refreshSecret, expiresIn, refreshExpiresIn } = require('../config/jwt');
const User = require('../models/User');

class AuthService {
    static generateTokens(user) {
        const payload = {
            user_id: user.user_id,
            email: user.email,
            role: user.role,
            token_version: user.token_version
        };

        const accessToken = jwt.sign(payload, secret, { expiresIn });
        const refreshToken = jwt.sign(payload, refreshSecret, { expiresIn: refreshExpiresIn });

        return { accessToken, refreshToken };
    }

    static async login(email, password) {
        const user = await User.findByEmail(email);
        if (!user) {
            throw new Error('Invalid credentials');
        }

        const isValidPassword = await User.validatePassword(password, user.password_hash);
        if (!isValidPassword) {
            throw new Error('Invalid credentials');
        }

        if (user.account_status !== 'ACTIVE') {
            throw new Error('Account is suspended or closed');
        }

        const tokens = this.generateTokens(user);
        
        // Calculate refresh token expiration
        const refreshExpiresAt = new Date();
        refreshExpiresAt.setDate(refreshExpiresAt.getDate() + 7); // 7 days

        // Update user with refresh token
        await User.updateRefreshToken(user.user_id, tokens.refreshToken, refreshExpiresAt);

        // Remove sensitive data
        const { password_hash, refresh_token, ...userResponse } = user;

        return {
            user: userResponse,
            tokens
        };
    }

    static async refreshToken(refreshToken) {
        try {
            const decoded = jwt.verify(refreshToken, refreshSecret);
            const user = await User.findById(decoded.user_id);

            if (!user || user.refresh_token !== refreshToken) {
                throw new Error('Invalid refresh token');
            }

            // Check if refresh token is expired
            if (new Date() > new Date(user.refresh_token_expired_at)) {
                throw new Error('Refresh token expired');
            }

            const tokens = this.generateTokens(user);
            
            // Update refresh token
            const refreshExpiresAt = new Date();
            refreshExpiresAt.setDate(refreshExpiresAt.getDate() + 7);
            
            await User.updateRefreshToken(user.user_id, tokens.refreshToken, refreshExpiresAt);

            return tokens;
        } catch (error) {
            throw new Error('Invalid refresh token');
        }
    }

    static async logout(user_id) {
        // Increment token version to invalidate all tokens
        await User.incrementTokenVersion(user_id);
        
        // Clear refresh token
        await User.updateRefreshToken(user_id, null, null);
    }
}

module.exports = AuthService;
