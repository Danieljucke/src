-- Nom du fichier : Base de Données WALLET AFRICA.sql
 /*
    Projet : Wallet Africa
    Description : Base de données pour la gestion des transactions financières, utilisateurs, bénéficiaires et partenaires.
    Objectif : Fournir une structure robuste pour le suivi des transactions, la gestion des utilisateurs et l'intégration des partenaires financiers.
    Technologies : PostgreSQL
    Entreprise : Wallet Student
    Auteur : Joy Daniel
    Version : 1.0
    Date de création : 2025-25-05
    Date de mise à jour : 2025-12-06
    Base de données : wallet_africa
    Langage : SQL
    Target : PostgreSQL 15
    Version de PostgreSQL : 15.4
    Type de base de données : Relationnelle
    Nombre de tables: 9
        - countries_currencies
        - users
        - beneficiaries  
        - partners
        - transactions
        - exchange_rates_history
        - transaction_logs
        - user_sessions
        - notifications
    Nombre d'index: 19
        - idx_users_email
        - idx_users_phone
        - idx_users_country
        - idx_beneficiaries_country
        - idx_partners_country
        - idx_partners_type
        - idx_partners_active
        - idx_transactions_sender
        - idx_transactions_beneficiary 
        - idx_transactions_status
        - idx_transactions_date
        - idx_transactions_reference
        - idx_rates_currencies
        - idx_rates_date
        - idx_logs_transaction
        - idx_logs_date
        - idx_sessions_user
        - idx_sessions_active
        - idx_sessions_last_activity
        - idx_notifications_user
        - idx_notifications_unread
        - idx_notifications_date
        - idx_transactions_user_period
        - idx_transactions_status_date
        - idx_beneficiaries_sender_active
        - idx_sessions_user_active
    Nombre de clés étrangères: 13
        - users -> countries_currencies
        - beneficiaries -> users
        - beneficiaries -> countries_currencies  
        - partners -> countries_currencies
        - transactions -> users
        - transactions -> beneficiaries
        - transactions -> partners (sending)
        - transactions -> partners (receiving)
        - transactions -> exchange_rates_history
        - transaction_logs -> transactions
        - transaction_logs -> users
        - user_sessions -> users
        - notifications -> users
        - notifications -> transactions
    Nombre de vues : 2 
    Nombre de procédures stockées : 1
    Nombre de triggers : 0
    Version de Express : 2.0.1
    Type de backend : REST API/ Multiplatform
*/


-- Table COUNTRIES_CURRENCIES
CREATE TABLE countries_currencies (
    country_code VARCHAR(3) PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    currency_code VARCHAR(3) NOT NULL,
    currency_name VARCHAR(50) NOT NULL,
    currency_symbol VARCHAR(10),
    is_supported BOOLEAN DEFAULT FALSE,
    exchange_rate_to_mad DECIMAL(10,6),
    exchange_rate_updated_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table EXCHANGE_RATES_HISTORY (créée avant TRANSACTIONS car référencée)
CREATE TABLE exchange_rates_history (
    rate_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_currency VARCHAR(3) NOT NULL,
    to_currency VARCHAR(3) NOT NULL,
    rate DECIMAL(10,6) NOT NULL,
    source VARCHAR(50),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table USERS
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    user_type VARCHAR(10) CHECK (user_type IN ('SENDER', 'RECEIVER')) NOT NULL,
    role VARCHAR(10) CHECK (role IN ('USER', 'ADMIN')) DEFAULT 'USER',
    is_active BOOLEAN DEFAULT TRUE,
    country_code VARCHAR(3) NOT NULL,
    city VARCHAR(100),
    address TEXT,
    
    -- Security and token
    refresh_token TEXT,
    token_version INTEGER,
    password_hash VARCHAR(255) NOT NULL,

    -- oauth2 and security
    google_id VARCHAR(255) UNIQUE,
    apple_id VARCHAR(255) UNIQUE,
    profile_picture TEXT,
    is_oauth_user BOOLEAN DEFAULT FALSE;
    
    -- Informations de sécurité
    account_status VARCHAR(10) CHECK (account_status IN ('ACTIVE', 'SUSPENDED', 'CLOSED','PENDING')) DEFAULT 'PENDING',
    loyalty_level VARCHAR(10) CHECK (loyalty_level IN ('BRONZE', 'SILVER', 'GOLD', 'PLATINUM')) DEFAULT 'BRONZE',
    total_transaction_volume DECIMAL(15,2) DEFAULT 0.00,

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    refresh_token_expired_at TIMESTAMP,
    last_token_issued_at TIMESTAMP,

    -- Clés étrangères
    FOREIGN KEY (country_code) REFERENCES countries_currencies(country_code)
);

-- Table BENEFICIARIES
CREATE TABLE beneficiaries (
    beneficiary_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(255),
    relationship VARCHAR(50),
    country_code VARCHAR(3) NOT NULL,

    -- Informations bancaires
    rib VARCHAR(50),
    bank_name VARCHAR(100),
    bank_code VARCHAR(20),
    account_number VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Clés étrangères
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (country_code) REFERENCES countries_currencies(country_code)
);

-- Table PARTNERS
CREATE TABLE partners (
    partner_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partner_name VARCHAR(200) NOT NULL,
    partner_type VARCHAR(20) CHECK (partner_type IN ('BANK', 'FINTECH', 'MOBILE_MONEY')) NOT NULL,
    country_code VARCHAR(3) NOT NULL,
    
    -- Informations de contact
    contact_email VARCHAR(255),
    contact_phone VARCHAR(20),
    website VARCHAR(255),
    
    -- Informations API
    api_endpoint VARCHAR(500),
    api_key_encrypted TEXT,
    api_version VARCHAR(20),
    
    -- Informations de transactions
    commission_rate DECIMAL(5,4),
    min_transaction DECIMAL(10,2),
    max_transaction DECIMAL(15,2),
    supported_currencies JSON,

    is_active BOOLEAN DEFAULT TRUE,
    contract_start_date DATE,
    contract_end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Clés étrangères
    FOREIGN KEY (country_code) REFERENCES countries_currencies(country_code)
);

-- Table TRANSACTIONS
CREATE TABLE transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reference_code VARCHAR(50) UNIQUE NOT NULL,
    sender_id UUID NOT NULL,
    beneficiary_id UUID NOT NULL,
    exchange_rate_id UUID,

    -- Montants et devises
    amount_sent DECIMAL(15,2) NOT NULL,
    currency_sent VARCHAR(3) NOT NULL,
    amount_received DECIMAL(15,2) NOT NULL,
    currency_received VARCHAR(3) NOT NULL,
    exchange_rate DECIMAL(10,6) NOT NULL,

    -- Frais de transaction et coût total
    transaction_fee DECIMAL(10,2) NOT NULL,
    partner_fee DECIMAL(10,2) DEFAULT 0.00,
    total_cost DECIMAL(15,2) GENERATED ALWAYS AS (amount_sent + transaction_fee) STORED,
    
    -- Statut de la transaction et tracking
    status VARCHAR(20) CHECK (status IN ('INITIATED', 'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED')) DEFAULT 'INITIATED',
    payment_method VARCHAR(20) CHECK (payment_method IN ('BANK_TRANSFER', 'MOBILE_MONEY', 'CARD')) NOT NULL,
    
    -- Identifiants des partenaires impliqués dans la transaction
    sending_partner_id UUID,
    receiving_partner_id UUID,

    -- Timestamps pour le suivi du cycle de vie de la transaction
    initiated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP,
    completed_at TIMESTAMP,
    failed_at TIMESTAMP,

    -- metadonnées de suivi
    failure_reason TEXT,
    admin_notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Clés étrangères
    FOREIGN KEY (sender_id) REFERENCES users(user_id),
    FOREIGN KEY (beneficiary_id) REFERENCES beneficiaries(beneficiary_id),
    FOREIGN KEY (sending_partner_id) REFERENCES partners(partner_id),
    FOREIGN KEY (receiving_partner_id) REFERENCES partners(partner_id),
    FOREIGN KEY (exchange_rate_id) REFERENCES exchange_rates_history(rate_id)
);

-- Table TRANSACTION_LOGS
CREATE TABLE transaction_logs (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transaction_id UUID NOT NULL,
    previous_status VARCHAR(20),
    new_status VARCHAR(20),
    changed_by UUID,
    change_reason TEXT,
    system_response TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Clés étrangères
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    FOREIGN KEY (changed_by) REFERENCES users(user_id)
);

-- Table USER_SESSIONS
CREATE TABLE user_sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    device_info TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logout_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,

    -- Clés étrangères
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Table NOTIFICATIONS
CREATE TABLE notifications (
    notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    transaction_id UUID,
    notification_type VARCHAR(20) CHECK (notification_type IN ('TRANSACTION_SUCCESS', 'TRANSACTION_FAILED', 'APPLICATION_UPDATED', 'PROMOTIONAL', 'SECURITY_ALERT')),
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sent_via VARCHAR(10) CHECK (sent_via IN ('PUSH', 'EMAIL', 'SMS')) DEFAULT 'PUSH',
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);

-- CRÉATION DES INDEX (séparément des tables)

-- Index pour la table USERS
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_country ON users(country_code);

-- Index pour améliorer les performances des recherches OAuth
CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);
CREATE INDEX IF NOT EXISTS idx_users_apple_id ON users(apple_id);

-- Index pour la table BENEFICIARIES
CREATE INDEX idx_beneficiaries_country ON beneficiaries(country_code);
CREATE INDEX idx_beneficiaries_sender_active ON beneficiaries(user_id, is_active);

-- Index pour la table PARTNERS
CREATE INDEX idx_partners_country ON partners(country_code);
CREATE INDEX idx_partners_type ON partners(partner_type);
CREATE INDEX idx_partners_active ON partners(is_active);

-- Index pour la table TRANSACTIONS
CREATE INDEX idx_transactions_sender ON transactions(sender_id);
CREATE INDEX idx_transactions_beneficiary ON transactions(beneficiary_id);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_date ON transactions(initiated_at);
CREATE INDEX idx_transactions_reference ON transactions(reference_code);
CREATE INDEX idx_transactions_user_period ON transactions(sender_id, initiated_at DESC);
CREATE INDEX idx_transactions_status_date ON transactions(status, initiated_at DESC);

-- Index pour la table EXCHANGE_RATES_HISTORY
CREATE INDEX idx_rates_currencies ON exchange_rates_history(from_currency, to_currency);
CREATE INDEX idx_rates_date ON exchange_rates_history(recorded_at);

-- Index pour la table TRANSACTION_LOGS
CREATE INDEX idx_logs_transaction ON transaction_logs(transaction_id);
CREATE INDEX idx_logs_date ON transaction_logs(created_at);

-- Index pour la table USER_SESSIONS
CREATE INDEX idx_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_sessions_active ON user_sessions(is_active);
CREATE INDEX idx_sessions_last_activity ON user_sessions(last_activity);
CREATE INDEX idx_sessions_user_active ON user_sessions(user_id, is_active, last_activity DESC);

-- Index pour la table NOTIFICATIONS
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_date ON notifications(sent_at);

-- VUES POUR LES STATISTIQUES

-- Vue : Statistiques des transactions
CREATE VIEW transaction_statistics AS
SELECT 
    DATE(initiated_at) as transaction_date,
    COUNT(*) as total_transactions,
    COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) as completed_transactions,
    COUNT(CASE WHEN status = 'FAILED' THEN 1 END) as failed_transactions,
    SUM(CASE WHEN status = 'COMPLETED' THEN amount_sent ELSE 0 END) as total_volume,
    AVG(CASE WHEN status = 'COMPLETED' THEN amount_sent ELSE NULL END) as average_amount,
    SUM(CASE WHEN status = 'COMPLETED' THEN transaction_fee ELSE 0 END) as total_fees
FROM transactions
GROUP BY DATE(initiated_at)
ORDER BY transaction_date DESC;

-- Vue : Performance par partenaire
CREATE VIEW partner_performance AS
SELECT 
    p.partner_name,
    p.country_code,
    COUNT(t.transaction_id) as total_transactions,
    COUNT(CASE WHEN t.status = 'COMPLETED' THEN 1 END) as successful_transactions,
    ROUND(
        COUNT(CASE WHEN t.status = 'COMPLETED' THEN 1 END) * 100.0 / NULLIF(COUNT(t.transaction_id), 0), 
        2
    ) as success_rate,
    SUM(CASE WHEN t.status = 'COMPLETED' THEN t.amount_sent ELSE 0 END) as total_volume
FROM partners p
LEFT JOIN transactions t ON (p.partner_id = t.sending_partner_id OR p.partner_id = t.receiving_partner_id)
WHERE p.is_active = TRUE
GROUP BY p.partner_id, p.partner_name, p.country_code
ORDER BY total_volume DESC;

-- PROCÉDURES STOCKÉES

-- Procédure : Créer une transaction
CREATE OR REPLACE FUNCTION CreateTransaction(
    p_sender_id UUID,
    p_beneficiary_id UUID,
    p_amount_sent DECIMAL(15,2),
    p_currency_sent TEXT,
    p_payment_method TEXT,
    OUT p_transaction_id UUID,
    OUT p_reference_code TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE 
    v_exchange_rate DECIMAL(10,6);
    v_amount_received DECIMAL(15,2);
    v_transaction_fee DECIMAL(10,2);
BEGIN
    -- Generate unique reference
    p_reference_code := 'WA' || TO_CHAR(NOW(), 'YYYYMMDD') || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
    p_transaction_id := gen_random_uuid();
    
    -- Calculate exchange rate and fee
    SELECT exchange_rate_to_mad INTO v_exchange_rate 
    FROM countries_currencies 
    WHERE currency_code = p_currency_sent;
    
    v_transaction_fee := GREATEST(p_amount_sent * 0.02, 5.00); -- 2% min 5 MAD
    v_amount_received := p_amount_sent * COALESCE(v_exchange_rate, 1.0);
    
    -- Insert transaction
    INSERT INTO transactions (
        transaction_id, reference_code, sender_id, beneficiary_id,
        amount_sent, currency_sent, amount_received, currency_received,
        exchange_rate, transaction_fee, payment_method, status
    ) VALUES (
        p_transaction_id, p_reference_code, p_sender_id, p_beneficiary_id,
        p_amount_sent, p_currency_sent, v_amount_received, 'MAD',
        COALESCE(v_exchange_rate, 1.0), v_transaction_fee, p_payment_method, 'INITIATED'
    );
    
    -- Log creation
    INSERT INTO transaction_logs (transaction_id, new_status, change_reason)
    VALUES (p_transaction_id, 'INITIATED', 'Transaction créée par utilisateur');
    
END;
$$;