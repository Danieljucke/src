const { supabase } = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
    static async create(userData) {
        const {
            email, phone_number, first_name, last_name, password,
            country_code, user_type, date_of_birth, city, address, role,
            google_id, apple_id, profile_picture, is_oauth_user
        } = userData;

        // Hash password (optionnel pour OAuth)
        let password_hash = null;
        if (password) {
            password_hash = await bcrypt.hash(password, 12);
        }

        const { data, error } = await supabase
            .from('users')
            .insert([{
                email,
                phone_number,
                first_name,
                last_name,
                password_hash,
                country_code,
                user_type,
                date_of_birth: date_of_birth ? new Date(date_of_birth).toISOString() : null,
                city,
                address,
                is_active: true,
                account_status: is_oauth_user ? 'ACTIVE' : 'PENDING',
                loyalty_level: 'BRONZE',
                role: role || 'USER',
                google_id: google_id || null,
                apple_id: apple_id || null,
                profile_picture: profile_picture || null,
                is_oauth_user: is_oauth_user || false,
                created_at: new Date().toISOString(),
                token_version: 0
            }])
            .select()
            .single();

        if (error) throw error;
        return data;
    }

    static async findByEmail(email) {
        const { data, error } = await supabase
            .from('users')
            .select('*')
            .eq('email', email)
            .eq('is_active', true)
            .single();

        if (error && error.code !== 'PGRST116') throw error;
        return data;
    }

    static async findById(user_id) {
        const { data, error } = await supabase
            .from('users')
            .select('*')
            .eq('user_id', user_id)
            .eq('is_active', true)
            .single();

        if (error && error.code !== 'PGRST116') throw error;
        return data;
    }

    static async update(user_id, updates) {
        const { data, error } = await supabase
            .from('users')
            .update({
                ...updates,
                updated_at: new Date().toISOString()
            })
            .eq('user_id', user_id)
            .select()
            .single();

        if (error) throw error;
        return data;
    }

    static async updatePassword(user_id, newPassword) {
        const hashedPassword = await bcrypt.hash(newPassword, 12);
        const { data, error } = await supabase
            .from('users')
            .update({
                password_hash: hashedPassword,
                updated_at: new Date().toISOString()
            })
            .eq('user_id', user_id)
            .select()
            .single();
            
        if (error) throw error;
        return data;
    }

    static async updateRefreshToken(user_id, refresh_token, expires_at) {
        const updateData = {
            refresh_token,
            refresh_token_expired_at: expires_at,
            last_token_issued_at: new Date().toISOString()
        };

        // Mettre à jour last_login seulement si refresh_token n'est pas null (connexion réussie)
        if (refresh_token) {
            updateData.last_login = new Date().toISOString();
        }

        const { data, error } = await supabase
            .from('users')
            .update(updateData)
            .eq('user_id', user_id)
            .select()
            .single();

        if (error) throw error;
        return data;
    }

    static async incrementTokenVersion(user_id) {
        const { data, error } = await supabase
            .rpc('increment_token_version', { user_id });

        if (error) throw error;
        return data;
    }

    static async updateStatus(user_id, account_status) {
        const { data, error } = await supabase
            .from('users')
            .update({
                account_status,
                updated_at: new Date().toISOString()
            })
            .eq('user_id', user_id)
            .select()
            .single();

        if (error) throw error;
        return data;
    }

    static async getStats(user_id) {
        // Get transaction statistics
        const { data: transactionStats, error: transError } = await supabase
            .from('transactions')
            .select('status, amount_sent, currency_sent, initiated_at')
            .eq('sender_id', user_id);

        if (transError) throw transError;

        // Calculate stats
        const totalTransactions = transactionStats.length;
        const completedTransactions = transactionStats.filter(t => t.status === 'COMPLETED').length;
        const totalVolume = transactionStats
            .filter(t => t.status === 'COMPLETED')
            .reduce((sum, t) => sum + parseFloat(t.amount_sent), 0);

        // Get this month's transactions
        const thisMonth = new Date();
        thisMonth.setDate(1);
        const thisMonthTransactions = transactionStats.filter(
            t => new Date(t.initiated_at) >= thisMonth
        ).length;

        return {
            totalTransactions,
            completedTransactions,
            totalVolume,
            thisMonthTransactions,
            successRate: totalTransactions > 0 ? (completedTransactions / totalTransactions * 100).toFixed(2) : 0
        };
    }

    static async findAll(page = 1, limit = 20, search = null) {
        let query = supabase
            .from('users')
            .select('user_id, email, phone_number, first_name, last_name, user_type, role, account_status, created_at, last_login', { count: 'exact' })
            .eq('is_active', true);

        if (search) {
            query = query.or(`first_name.ilike.%${search}%,last_name.ilike.%${search}%,email.ilike.%${search}%`);
        }

        const offset = (page - 1) * limit;
        query = query.range(offset, offset + limit - 1);

        const { data, error, count } = await query;

        if (error) throw error;

        return {
            users: data,
            pagination: {
                page,
                limit,
                total: count,
                totalPages: Math.ceil(count / limit)
            }
        };
    }

    static async validatePassword(plainPassword, hashedPassword) {
        return await bcrypt.compare(plainPassword, hashedPassword);
    }

    // Méthode pour vérifier si un utilisateur peut se connecter
    static async canLogin(email) {
        const user = await this.findByEmail(email);
        if (!user) return { canLogin: false, reason: 'User not found' };
        
        if (user.account_status === 'SUSPENDED') {
            return { canLogin: false, reason: 'Account suspended' };
        }
        
        if (user.account_status === 'CLOSED') {
            return { canLogin: false, reason: 'Account closed' };
        }
        
        return { canLogin: true, user };
    }

    static async findByOAuthId(provider, oauthId) {
        const column = provider === 'google' ? 'google_id' : 'apple_id';

        const { data, error } = await supabase
            .from('users')
            .select('*')
            .eq(column, oauthId)
            .eq('is_active', true)
            .single();

        if (error && error.code !== 'PGRST116') throw error;
        return data;
    }

    static async updateOAuthInfo(user_id, provider, oauthId, additionalData = {}) {
        const column = provider === 'google' ? 'google_id' : 'apple_id';

        const updateData = {
            [column]: oauthId,
            last_login: new Date().toISOString(),
            updated_at: new Date().toISOString(),
            ...additionalData
        };

        const { data, error } = await supabase
            .from('users')
            .update(updateData)
            .eq('user_id', user_id)
            .select()
            .single();

        if (error) throw error;
        return data;
    }

    static async canOAuthLogin(email, provider) {
        const user = await this.findByEmail(email);
        if (!user) return { canLogin: true, reason: 'New user' };

        if (user.account_status === 'SUSPENDED') {
            return { canLogin: false, reason: 'Account suspended' };
        }

        if (user.account_status === 'CLOSED') {
            return { canLogin: false, reason: 'Account closed' };
        }

        return { canLogin: true, user };
    }

    static async linkOAuthAccount(user_id, provider, oauthId, additionalData = {}) {
        const column = provider === 'google' ? 'google_id' : 'apple_id';

        // Vérifier que cet OAuth ID n'est pas déjà utilisé
        const existingUser = await this.findByOAuthId(provider, oauthId);
        if (existingUser && existingUser.user_id !== user_id) {
            throw new Error(`This ${provider} account is already linked to another user`);
        }

        const updateData = {
            [column]: oauthId,
            updated_at: new Date().toISOString(),
            ...additionalData
        };

        const { data, error } = await supabase
            .from('users')
            .update(updateData)
            .eq('user_id', user_id)
            .select()
            .single();

        if (error) throw error;
        return data;
    }

    static async unlinkOAuthAccount(user_id, provider) {
        const column = provider === 'google' ? 'google_id' : 'apple_id';

        const updateData = {
            [column]: null,
            updated_at: new Date().toISOString()
        };

        // Si c'est Google, on peut aussi supprimer la photo de profil
        if (provider === 'google') {
            updateData.profile_picture = null;
        }

        const { data, error } = await supabase
            .from('users')
            .update(updateData)
            .eq('user_id', user_id)
            .select()
            .single();

        if (error) throw error;
        return data;
    }

    static async hasOAuthAccount(user_id, provider) {
        const column = provider === 'google' ? 'google_id' : 'apple_id';

        const { data, error } = await supabase
            .from('users')
            .select(column)
            .eq('user_id', user_id)
            .single();

        if (error) throw error;
        return !!data[column];
    }
    
    static async getOAuthAccounts(user_id) {
        const { data, error } = await supabase
            .from('users')
            .select('google_id, apple_id, profile_picture, is_oauth_user')
            .eq('user_id', user_id)
            .single();

        if (error) throw error;
        return {
            google: !!data.google_id,
            apple: !!data.apple_id,
            isOAuthUser: data.is_oauth_user,
            profilePicture: data.profile_picture
        };
    }

    // Méthode pour mettre à jour le profil avec les données OAuth
    static async updateProfileFromOAuth(user_id, oauthData, provider) {
        const updateData = {
            updated_at: new Date().toISOString()
        };

        // Mettre à jour la photo de profil si disponible (Google uniquement)
        if (provider === 'google' && oauthData.picture) {
            updateData.profile_picture = oauthData.picture;
        }

        // Mettre à jour les noms si ils sont vides
        if (oauthData.given_name || oauthData.family_name) {
            const user = await this.findById(user_id);
            if (!user.first_name || user.first_name === 'User') {
                updateData.first_name = oauthData.given_name || user.first_name;
            }
            if (!user.last_name || user.last_name === 'OAuth') {
                updateData.last_name = oauthData.family_name || user.last_name;
            }
        }

        if (Object.keys(updateData).length > 1) { // Plus que juste updated_at
            const { data, error } = await supabase
                .from('users')
                .update(updateData)
                .eq('user_id', user_id)
                .select()
                .single();

            if (error) throw error;
            return data;
        }

        return null;
    }
}

module.exports = User;