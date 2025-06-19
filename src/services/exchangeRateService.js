const { supabase } = require('../config/database');

class ExchangeRateService {
    static async getRate(fromCurrency, toCurrency) {
        try {
            // First try to get from our database
            const { data, error } = await supabase
                .from('countries_currencies')
                .select('exchange_rate_to_mad, exchange_rate_updated_at')
                .eq('currency_code', fromCurrency)
                .single();

            if (error && error.code !== 'PGRST116') throw error;

            // If rate exists and is recent (less than 1 hour old), use it
            if (data && data.exchange_rate_to_mad) {
                const lastUpdate = new Date(data.exchange_rate_updated_at);
                const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
                
                if (lastUpdate > oneHourAgo) {
                    return data.exchange_rate_to_mad;
                }
            }

            // Otherwise, fetch from external API and update database
            const rate = await this.fetchExternalRate(fromCurrency, toCurrency);
            await this.updateRate(fromCurrency, rate);
            
            return rate;
        } catch (error) {
            console.error('Error getting exchange rate:', error);
            // Return default rate or throw error based on your business logic
            return 1.0;
        }
    }

    static async fetchExternalRate(fromCurrency, toCurrency) {
        // Example using a free exchange rate API
        // Replace with your preferred exchange rate service
        try {
            const response = await fetch(
                `https://api.exchangerate-api.com/v4/latest/${fromCurrency}`
            );
            const data = await response.json();
            
            if (data.rates && data.rates[toCurrency]) {
                return data.rates[toCurrency];
            }
            
            throw new Error('Rate not found');
        } catch (error) {
            console.error('External API error:', error);
            return 1.0; // Default rate
        }
    }

    static async updateRate(currency, rate) {
        const { error } = await supabase
            .from('countries_currencies')
            .update({
                exchange_rate_to_mad: rate,
                exchange_rate_updated_at: new Date().toISOString()
            })
            .eq('currency_code', currency);

        if (error) {
            console.error('Error updating exchange rate:', error);
        }

        // Also store in history
        await supabase
            .from('exchange_rates_history')
            .insert([{
                from_currency: currency,
                to_currency: 'MAD',
                rate: rate,
                source: 'external_api'
            }]);
    }

    static async getRateHistory(fromCurrency, toCurrency, days = 30) {
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);

        const { data, error } = await supabase
            .from('exchange_rates_history')
            .select('*')
            .eq('from_currency', fromCurrency)
            .eq('to_currency', toCurrency)
            .gte('recorded_at', startDate.toISOString())
            .order('recorded_at', { ascending: false });

        if (error) throw error;
        return data;
    }
}

module.exports = ExchangeRateService;
