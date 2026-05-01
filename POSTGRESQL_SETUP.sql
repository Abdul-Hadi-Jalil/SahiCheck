-- ============================================
-- SAHICHECK DATABASE SETUP SCRIPT
-- Run this in pgAdmin Query Tool connected to sahicheck database
-- ============================================

-- Create schema (optional, but good practice)
CREATE SCHEMA IF NOT EXISTS sahicheck_schema;
SET search_path TO sahicheck_schema, public;

-- ============================================
-- CREATE TABLES
-- ============================================

-- Users table for Firebase authentication and user management
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    firebase_uid VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    subscription_type VARCHAR(50) DEFAULT 'free',
    api_calls_count INTEGER DEFAULT 0,
    storage_used_mb DECIMAL(10,2) DEFAULT 0.0
);

-- Reports table for ML model results and input data
CREATE TABLE IF NOT EXISTS reports (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,           -- 'phishing', 'fraud', 'fake_news'
    input_data JSONB,                      -- Store original input as JSON
    result VARCHAR(50) NOT NULL,          -- 'Phishing', 'Legitimate', 'Fraud', 'Fake News', 'True News'
    confidence DECIMAL(5,4) NOT NULL,     -- 0.0000 to 1.0000
    ml_probabilities JSONB,                 -- Store all probability scores as JSON
    processing_time_ms INTEGER,                -- ML processing time in milliseconds
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Analytics table for usage statistics and metrics
CREATE TABLE IF NOT EXISTS analytics (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    endpoint VARCHAR(100) NOT NULL,     -- '/phishing', '/fraud', '/fake-news'
    request_count INTEGER DEFAULT 1,
    avg_confidence DECIMAL(5,4),
    success_count INTEGER DEFAULT 0,
    error_count INTEGER DEFAULT 0,
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- System logs table for application monitoring
CREATE TABLE IF NOT EXISTS system_logs (
    id SERIAL PRIMARY KEY,
    level VARCHAR(20) NOT NULL,            -- 'INFO', 'WARNING', 'ERROR'
    message TEXT NOT NULL,
    endpoint VARCHAR(100),
    user_id VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CREATE INDEXES FOR BETTER PERFORMANCE
-- ============================================

-- Indexes for reports table
CREATE INDEX IF NOT EXISTS idx_reports_user_type ON reports(user_id, type);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reports_type_result ON reports(type, result);

-- Indexes for analytics table
CREATE INDEX IF NOT EXISTS idx_analytics_user_date ON analytics(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_endpoint_date ON analytics(endpoint, date DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_user_endpoint ON analytics(user_id, endpoint);

-- Indexes for users table
CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at DESC);

-- Indexes for system_logs table
CREATE INDEX IF NOT EXISTS idx_system_logs_level ON reports(level);
CREATE INDEX IF NOT EXISTS idx_system_logs_created_at ON system_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_system_logs_endpoint ON system_logs(endpoint);

-- ============================================
-- CREATE UNIQUE CONSTRAINT FOR ANALYTICS
-- ============================================

-- Add unique constraint for analytics upsert operations
ALTER TABLE analytics 
ADD CONSTRAINT IF NOT EXISTS analytics_user_endpoint_date_key 
UNIQUE (user_id, endpoint, date);

-- ============================================
-- GRANT PERMISSIONS
-- ============================================

-- Grant permissions to postgres user (adjust as needed)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sahicheck_schema TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sahicheck_schema TO postgres;

-- Grant usage on schema
GRANT USAGE ON SCHEMA sahicheck_schema TO postgres;

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- Insert sample user (you can remove this)
INSERT INTO users (firebase_uid, email) 
VALUES ('test_user_123', 'test@example.com')
ON CONFLICT (firebase_uid) DO NOTHING;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check if tables were created successfully
SELECT table_name, table_schema 
FROM information_schema.tables 
WHERE table_schema IN ('sahicheck_schema', 'public') 
ORDER BY table_schema, table_name;

-- Check indexes
SELECT indexname, tablename 
FROM pg_indexes 
WHERE schemaname IN ('sahicheck_schema', 'public')
ORDER BY tablename, indexname;
