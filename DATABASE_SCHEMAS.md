# SahiCheck Database Schemas

## Overview
SahiCheck uses a dual-database approach:
- **MongoDB**: Store raw input data for analysis
- **PostgreSQL**: Store processed results and reports

---

## 🗄️ MongoDB Schema

### Database: `sahicheck`
### Collection: `inputs`

```javascript
{
  "_id": ObjectId("..."),
  "type": "phishing" | "fraud" | "fake_news",
  "input": {
    // Phishing Input
    "url": "https://example.com",
    "user_id": "user123",
    
    // Fraud Input  
    "time": 1000.0,
    "amount": 100.0,
    "v1": -1.2, "v2": 0.5, ..., "v28": 0.3,
    "user_id": "user123",
    
    // Fake News Input
    "title": "Breaking News Headline",
    "text": "News article content...",
    "user_id": "user123"
  },
  "timestamp": ISODate("2024-01-01T12:00:00Z"),
  "processed": false,
  "ml_confidence": 0.85,
  "processing_time_ms": 150
}
```

### Indexes Recommended:
```javascript
db.inputs.createIndex({ 
  "user_id": 1, 
  "type": 1, 
  "timestamp": -1 
});
```

---

## 🐘 PostgreSQL Schema

### Database: `sahicheck`

#### Table: `users`
```sql
CREATE TABLE users (
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
```

#### Table: `reports`
```sql
CREATE TABLE reports (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,           -- 'phishing', 'fraud', 'fake_news'
    input_data JSONB,                      -- Store original input
    result VARCHAR(50) NOT NULL,           -- 'Phishing', 'Legitimate', 'Fraud', 'Fake News', 'True News'
    confidence DECIMAL(5,4) NOT NULL,     -- 0.0000 to 1.0000
    ml_probabilities JSONB,                 -- Store all probability scores
    processing_time_ms INTEGER,                -- ML processing time
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    FOREIGN KEY (user_id) REFERENCES users(firebase_uid) ON DELETE CASCADE
);
```

#### Table: `analytics`
```sql
CREATE TABLE analytics (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    endpoint VARCHAR(100) NOT NULL,     -- '/phishing', '/fraud', '/fake-news'
    request_count INTEGER DEFAULT 1,
    avg_confidence DECIMAL(5,4),
    success_count INTEGER DEFAULT 0,
    error_count INTEGER DEFAULT 0,
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(firebase_uid) ON DELETE CASCADE
);
```

#### Table: `system_logs`
```sql
CREATE TABLE system_logs (
    id SERIAL PRIMARY KEY,
    level VARCHAR(20) NOT NULL,            -- 'INFO', 'WARNING', 'ERROR'
    message TEXT NOT NULL,
    endpoint VARCHAR(100),
    user_id VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔄 Data Flow Architecture

### 1. User Request Flow
```
Frontend → FastAPI → 
  1. Store raw input in MongoDB (inputs collection)
  2. Process with ML models
  3. Store results in PostgreSQL (reports table)
  4. Update analytics in PostgreSQL (analytics table)
```

### 2. Data Purposes

#### MongoDB - Raw Data Storage
- **Audit Trail**: Complete record of all requests
- **Debugging**: Raw inputs for troubleshooting
- **Batch Processing**: Queue for background ML processing
- **Data Recovery**: Restore failed requests
- **Analytics**: Input pattern analysis

#### PostgreSQL - Processed Data
- **User Management**: User accounts and subscriptions
- **Reporting**: Structured query and analysis
- **Analytics**: Performance metrics and usage stats
- **Compliance**: Data retention and privacy
- **Integration**: Connect with BI tools

---

## 📊 Required Data Fields

### Phishing Detection
**MongoDB Input:**
- `url`: String (max 2048 chars)
- `user_id`: String (Firebase UID)

**PostgreSQL Report:**
- `input_data.url`: Original URL
- `result`: 'Phishing' | 'Legitimate'
- `confidence`: Float (0.0000 - 1.0000)
- `ml_probabilities`: {phishing: 0.85, legitimate: 0.15}

### Fraud Detection
**MongoDB Input:**
- `time`: Float (Unix timestamp)
- `amount`: Float (Transaction amount)
- `v1-v28`: Float (PCA features)
- `user_id`: String (Firebase UID)

**PostgreSQL Report:**
- `input_data`: Complete transaction object
- `result`: 'Fraud' | 'Legitimate'
- `confidence`: Float
- `ml_probabilities`: {fraud: 0.75, legitimate: 0.25}

### Fake News Detection
**MongoDB Input:**
- `title`: String (max 500 chars)
- `text`: String (max 10000 chars)
- `user_id`: String (Firebase UID)

**PostgreSQL Report:**
- `input_data.title`: Original title
- `input_data.text`: Original text
- `result`: 'Fake News' | 'True News'
- `confidence`: Float
- `ml_probabilities`: {fake_news: 0.73, true_news: 0.27}

---

## 🚀 Performance Optimizations

### MongoDB Indexes
```javascript
// Compound indexes for common queries
db.inputs.createIndex({"user_id": 1, "type": 1, "timestamp": -1});
db.inputs.createIndex({"type": 1, "timestamp": -1});
db.inputs.createIndex({"processed": 1, "timestamp": -1});
```

### PostgreSQL Indexes
```sql
-- User-based queries
CREATE INDEX idx_reports_user_type ON reports(user_id, type);
CREATE INDEX idx_reports_created_at ON reports(created_at DESC);
CREATE INDEX idx_analytics_user_date ON analytics(user_id, date DESC);

-- Performance monitoring
CREATE INDEX idx_analytics_endpoint_date ON analytics(endpoint, date DESC);
```

---

## 🔒 Security Considerations

### Data Encryption
- **MongoDB**: Enable field-level encryption
- **PostgreSQL**: Enable column-level encryption
- **Connection**: Use SSL/TLS for all connections

### Data Retention
- **MongoDB**: 90 days for raw inputs
- **PostgreSQL**: 1 year for reports, 90 days for logs
- **Analytics**: 2 years for usage patterns

### Access Control
- **MongoDB**: Role-based access per collection
- **PostgreSQL**: Row-level security with user roles
- **API**: Rate limiting per user per endpoint
