const { supabase } = require('../config/database');

class NotificationService {
    static async sendTransactionNotification(user_id, transaction_id, type, title, message) {
        try {
            const { data, error } = await supabase
                .from('notifications')
                .insert([{
                    user_id,
                    transaction_id,
                    notification_type: type,
                    title,
                    message,
                    sent_via: 'PUSH'
                }])
                .select()
                .single();

            if (error) throw error;

            // Here you would integrate with your push notification service
            // Example: Firebase Cloud Messaging, OneSignal, etc.
            await this.sendPushNotification(user_id, title, message);

            return data;
        } catch (error) {
            console.error('Error sending notification:', error);
        }
    }

    static async sendPushNotification(user_id, title, message) {
        // Implement your push notification logic here
        // This is where you'd integrate with FCM, APNS, etc.
        console.log(`Push notification sent to user ${user_id}: ${title} - ${message}`);
    }

    static async getUserNotifications(user_id, limit = 50, offset = 0) {
        const { data, error } = await supabase
            .from('notifications')
            .select('*')
            .eq('user_id', user_id)
            .order('sent_at', { ascending: false })
            .range(offset, offset + limit - 1);

        if (error) throw error;
        return data;
    }

    static async markAsRead(notification_id, user_id) {
        const { data, error } = await supabase
            .from('notifications')
            .update({
                is_read: true,
                read_at: new Date().toISOString()
            })
            .eq('notification_id', notification_id)
            .eq('user_id', user_id)
            .select()
            .single();

        if (error) throw error;
        return data;
    }

    static async markAllAsRead(user_id) {
        const { data, error } = await supabase
            .from('notifications')
            .update({
                is_read: true,
                read_at: new Date().toISOString()
            })
            .eq('user_id', user_id)
            .eq('is_read', false);

        if (error) throw error;
        return data;
    }

    static async getUnreadCount(user_id) {
        const { count, error } = await supabase
            .from('notifications')
            .select('*', { count: 'exact', head: true })
            .eq('user_id', user_id)
            .eq('is_read', false);

        if (error) throw error;
        return count;
    }
}

module.exports = NotificationService;
