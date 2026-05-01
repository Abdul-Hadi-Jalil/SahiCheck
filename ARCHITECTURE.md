# SahiCheck - Multi-Modal AI Detection Platform Architecture

## Overview
SahiCheck is a comprehensive AI-powered detection platform that identifies phishing URLs, fake news articles, and fraudulent transactions using machine learning models with dual database storage for optimal performance and analytics.

## System Architecture

### Frontend Layer (Flutter Mobile App)
```
Flutter Application
    |- Phishing Detection Screen
    |- Fake News Detection Screen  
    |- Fraud Detection Screen
    |- User Authentication (Firebase)
    |- API Service Layer
```

### Backend Layer (FastAPI Python Server)
```
FastAPI Server (localhost:8002)
    |- ML Model Processing Pipeline
    |- Dual Database Integration
    |- REST API Endpoints
    |- Error Handling & Analytics
```

### Database Layer (Dual Storage Strategy)
```
PostgreSQL (Local)          MongoDB Atlas (Cloud)
    |- Users Table              |- Raw Inputs Collection
    |- Reports Table            |- Complete Input History
    |- Analytics Table           |- Flexible Schema Storage
    |- System Logs Table         |- ML Training Data
```

## Data Flow Architecture

### Request Processing Pipeline
```
Mobile Device
    [User Input] 
        (HTTP POST)
    Backend Server
    [ML Model Inference] 
        [Dual Storage]
    MongoDB Atlas + PostgreSQL
    [Response] 
        (JSON Response)
    Mobile Device
    [Results Display]
```

### Detailed Flow Sequence

1. **Input Reception**
   - Mobile app captures user input (URL, text, or transaction data)
   - HTTP POST request sent to backend API endpoint
   - Request includes user_id and raw input data

2. **ML Processing**
   - Backend receives request and validates input
   - Appropriate ML model loads and processes features
   - Prediction generated with confidence scores
   - Result formatted with probability distributions

3. **Dual Database Storage**
   - **MongoDB Atlas**: Raw input data stored with timestamp
   - **PostgreSQL**: Structured results with analytics
   - Both databases updated asynchronously
   - Error handling ensures data integrity

4. **Response Delivery**
   - ML results returned to mobile app immediately
   - Background storage continues independently
   - User receives instant feedback with confidence scores

## Technology Stack

### Frontend Technologies
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language for Flutter
- **Firebase**: User authentication and services
- **HTTP Package**: REST API communication

### Backend Technologies
- **FastAPI**: High-performance Python web framework
- **Python 3.10**: Backend programming language
- **Scikit-learn**: Machine learning model serving
- **NumPy/Pandas**: Data processing and feature engineering

### Database Technologies
- **PostgreSQL 13**: Structured data storage and analytics
- **MongoDB Atlas**: Cloud-based NoSQL for raw data
- **psycopg2**: PostgreSQL Python driver
- **pymongo**: MongoDB Python driver

### ML Models
- **Phishing Detection**: Feature-based classification model
- **Fake News Detection**: TF-IDF text classification
- **Fraud Detection**: Anomaly detection with scaled features

## API Endpoints

### Detection Endpoints
```
POST /phishing
POST /fake-news  
POST /fraud
```

### Utility Endpoints
```
GET / (Health Check)
GET /test-mongo (MongoDB Connection Test)
```

## Database Schema

### PostgreSQL Tables
- **users**: Firebase user management and subscriptions
- **reports**: ML results with confidence scores and analytics
- **analytics**: Usage metrics and performance tracking
- **system_logs**: Application monitoring and error tracking

### MongoDB Collections
- **raw_inputs**: Complete user input history with flexible schema

## Network Architecture

### Mobile to Backend Communication
```
Mobile Device (WiFi)
    HTTP/HTTPS
    192.168.18.251:8002
    Backend Server (Laptop)
```

### Backend to Database Connections
```
Backend Server
    psycopg2
    PostgreSQL (localhost:5432)
    
Backend Server  
    pymongo
    MongoDB Atlas (Cloud)
```

## Security & Performance

### Security Features
- Firebase authentication for user management
- Input validation and sanitization
- Error handling without data exposure
- Secure database connections with credentials

### Performance Optimizations
- Asynchronous database operations
- Dual database strategy for workload distribution
- ML model caching and efficient feature extraction
- Fast response times with background storage

## Scalability Considerations

### Horizontal Scaling
- MongoDB Atlas handles unlimited raw data growth
- PostgreSQL can be scaled with read replicas
- Backend can be containerized for cloud deployment

### Data Management
- Raw data preserved in MongoDB for ML training
- Structured analytics in PostgreSQL for business intelligence
- Automated cleanup and archival strategies

## Deployment Architecture

### Development Environment
```
Laptop Development Server
    |- Backend: FastAPI (localhost:8002)
    |- PostgreSQL: Local instance
    |- MongoDB Atlas: Cloud connection
    |- Mobile: Flutter app on device/emulator
```

### Production Considerations
- Backend: Cloud server deployment
- Databases: Managed services (PostgreSQL + MongoDB Atlas)
- Frontend: App Store distribution
- Monitoring: System logs and analytics tracking

## Data Privacy & Compliance

### Data Handling
- Raw inputs stored for ML improvement
- User analytics anonymized where possible
- GDPR compliance considerations for user data
- Secure credential management

### Backup Strategy
- PostgreSQL: Regular backups and point-in-time recovery
- MongoDB Atlas: Automated backups and global clusters
- Application logs: Centralized logging and monitoring

This architecture provides a robust, scalable foundation for AI-powered detection services with comprehensive data storage and analytics capabilities.
