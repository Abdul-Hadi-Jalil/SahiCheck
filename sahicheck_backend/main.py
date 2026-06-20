from fastapi import FastAPI
from pydantic import BaseModel
import os
import pickle
import numpy as np
import pandas as pd
from pymongo import MongoClient
import psycopg2
from datetime import datetime
import re
from urllib.parse import urlparse
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.base import BaseEstimator, TransformerMixin
import json

app = FastAPI()

# ===============================
# LOAD MODELS
# ===============================

# Load all models and components for highest confidence
# Load phishing detection model and components
with open("saved_models/phishing_detection_model.pkl", "rb") as f:
    phishing_model = pickle.load(f)
with open("saved_models/phishing_label_encoder.pkl", "rb") as f:
    phishing_encoder = pickle.load(f)
with open("saved_models/phishing_feature_names.pkl", "rb") as f:
    phishing_feature_names = pickle.load(f)

# Load fraud detection model and components
with open("saved_models/fraud_detection_model.pkl", "rb") as f:
    fraud_model = pickle.load(f)
with open("saved_models/fraud_scaler.pkl", "rb") as f:
    fraud_scaler = pickle.load(f)
with open("saved_models/fraud_feature_names.pkl", "rb") as f:
    fraud_feature_names = pickle.load(f)

# Load fake news detection model and components (new simple approach)
with open("saved_models/fake_news_simple_model.pkl", "rb") as f:
    fake_news_model = pickle.load(f)
with open("saved_models/fake_news_simple_tfidf.pkl", "rb") as f:
    text_extractor = pickle.load(f)

# ===============================
# DATABASE CONNECTIONS (lazy)
# ===============================

# Use environment variables so the app can start even when a database
# is temporarily unavailable. Placeholders are used as defaults.
MONGO_URI = os.getenv("MONGO_URI", "YOUR_MONGO_CONNECTION")
POSTGRES_HOST = os.getenv("POSTGRES_HOST", "localhost")
POSTGRES_DB = os.getenv("POSTGRES_DB", "sahicheck")
POSTGRES_USER = os.getenv("POSTGRES_USER", "postgres")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD", "abdul123")

mongo_client = None
mongo_inputs_collection = None
pg_conn = None
pg_cursor = None


def get_mongo_collection():
    """
    Connect to MongoDB only when needed.
    Returns None if MongoDB is not configured or unreachable.
    """
    global mongo_client, mongo_inputs_collection

    if mongo_inputs_collection is not None:
        return mongo_inputs_collection

    if MONGO_URI == "YOUR_MONGO_CONNECTION":
        print("MongoDB not configured. Skipping raw input storage.")
        return None

    try:
        mongo_client = MongoClient(MONGO_URI, serverSelectionTimeoutMS=5000)
        mongo_client.admin.command("ping")
        mongo_inputs_collection = mongo_client["sahicheck"]["raw_inputs"]
        print("Connected to MongoDB")
        return mongo_inputs_collection
    except Exception as mongo_error:
        print(f"MongoDB connection failed: {mongo_error}")
        mongo_client = None
        mongo_inputs_collection = None
        return None


def get_pg_cursor():
    """
    Connect to PostgreSQL only when needed.
    Returns None if PostgreSQL is unreachable.
    """
    global pg_conn, pg_cursor

    if pg_cursor is not None:
        return pg_cursor

    try:
        pg_conn = psycopg2.connect(
            host=POSTGRES_HOST,
            database=POSTGRES_DB,
            user=POSTGRES_USER,
            password=POSTGRES_PASSWORD,
        )
        pg_cursor = pg_conn.cursor()
        pg_cursor.execute("SET search_path TO sahicheck_schema, public")
        pg_conn.commit()
        print("Connected to PostgreSQL - Using sahicheck_schema")
        return pg_cursor
    except Exception as pg_error:
        print(f"PostgreSQL connection failed: {pg_error}")
        pg_conn = None
        pg_cursor = None
        return None

# ===============================
# REQUEST MODELS
# ===============================

class NewsInput(BaseModel):
    title: str
    text: str
    user_id: str

class URLInput(BaseModel):
    url: str
    user_id: str

class TransactionInput(BaseModel):
    time: float
    v1: float
    v2: float
    v3: float
    v4: float
    v5: float
    v6: float
    v7: float
    v8: float
    v9: float
    v10: float
    v11: float
    v12: float
    v13: float
    v14: float
    v15: float
    v16: float
    v17: float
    v18: float
    v19: float
    v20: float
    v21: float
    v22: float
    v23: float
    v24: float
    v25: float
    v26: float
    v27: float
    v28: float
    amount: float
    user_id: str

# ===============================
# PREPROCESSING FUNCTIONS
# ===============================

def preprocess_phishing_features(url):
    """
    Extract comprehensive features for phishing detection using the trained feature names
    """
    parsed = urlparse(url)
    
    # Extract all features that the model was trained on
    features = {}
    
    # Basic URL features
    features['length_url'] = len(url)
    features['length_hostname'] = len(parsed.netloc)
    features['ip'] = 1 if re.match(r'\d+\.\d+\.\d+\.\d+', parsed.netloc) else 0
    features['nb_dots'] = url.count('.')
    features['nb_hyphens'] = url.count('-')
    features['nb_at'] = url.count('@')
    features['nb_qm'] = url.count('?')
    features['nb_and'] = url.count('&')
    features['nb_or'] = url.count('|')
    features['nb_eq'] = url.count('=')
    features['nb_underscore'] = url.count('_')
    features['nb_tilde'] = url.count('~')
    features['nb_percent'] = url.count('%')
    features['nb_slash'] = url.count('/')
    features['nb_star'] = url.count('*')
    features['nb_colon'] = url.count(':')
    features['nb_comma'] = url.count(',')
    features['nb_semicolumn'] = url.count(';')
    features['nb_dollar'] = url.count('$')
    features['nb_space'] = url.count(' ')
    features['nb_www'] = 1 if 'www.' in url else 0
    features['nb_com'] = 1 if '.com' in url else 0
    features['nb_dslash'] = url.count('//')
    features['http_in_path'] = 1 if 'http:' in parsed.path else 0
    features['https_token'] = 1 if 'https' in url else 0
    
    # Advanced features
    features['ratio_digits_url'] = sum(c.isdigit() for c in url) / len(url) if len(url) > 0 else 0
    features['ratio_digits_host'] = sum(c.isdigit() for c in parsed.netloc) / len(parsed.netloc) if len(parsed.netloc) > 0 else 0
    features['punycode'] = 1 if 'xn--' in parsed.netloc else 0
    features['port'] = parsed.port if parsed.port else 0
    features['tld_in_path'] = 1 if any(tld in parsed.path for tld in ['.com', '.org', '.net', '.edu', '.gov']) else 0
    features['tld_in_subdomain'] = 0
    features['abnormal_subdomain'] = 0
    features['nb_subdomains'] = len(parsed.netloc.split('.')) - 1 if parsed.netloc else 0
    features['prefix_suffix'] = 0
    features['random_domain'] = 0
    features['shortening_service'] = 1 if any(service in url for service in ['bit.ly', 'tinyurl.com', 't.co', 'goo.gl']) else 0
    
    # Word-based features
    features['path_extension'] = 0
    features['nb_redirection'] = 0
    features['nb_external_redirection'] = 0
    features['length_words_raw'] = len(url.split())
    features['char_repeat'] = 0
    features['shortest_words_raw'] = min(len(word) for word in url.split()) if url.split() else 0
    features['shortest_word_host'] = min(len(word) for word in parsed.netloc.split('.')) if parsed.netloc else 0
    features['shortest_word_path'] = min(len(word) for word in parsed.path.split('/')) if parsed.path else 0
    features['longest_words_raw'] = max(len(word) for word in url.split()) if url.split() else 0
    features['longest_word_host'] = max(len(word) for word in parsed.netloc.split('.')) if parsed.netloc else 0
    features['longest_word_path'] = max(len(word) for word in parsed.path.split('/')) if parsed.path else 0
    features['avg_words_raw'] = np.mean([len(word) for word in url.split()]) if url.split() else 0
    features['avg_word_host'] = np.mean([len(word) for word in parsed.netloc.split('.')]) if parsed.netloc else 0
    features['avg_word_path'] = np.mean([len(word) for word in parsed.path.split('/')]) if parsed.path else 0
    
    # HTML and web features (simplified - would need actual HTML content)
    features['phish_hints'] = 0
    features['domain_in_brand'] = 0
    features['brand_in_subdomain'] = 0
    features['brand_in_path'] = 0
    features['suspecious_tld'] = 0
    features['statistical_report'] = 0
    features['nb_hyperlinks'] = 0
    features['ratio_intHyperlinks'] = 0
    features['ratio_extHyperlinks'] = 0
    features['ratio_nullHyperlinks'] = 0
    features['nb_extCSS'] = 0
    features['ratio_intRedirection'] = 0
    features['ratio_extRedirection'] = 0
    features['ratio_intErrors'] = 0
    features['ratio_extErrors'] = 0
    features['login_form'] = 0
    features['external_favicon'] = 0
    features['links_in_tags'] = 0
    features['submit_email'] = 0
    features['ratio_intMedia'] = 0
    features['ratio_extMedia'] = 0
    features['sfh'] = 0
    features['iframe'] = 0
    features['popup_window'] = 0
    features['safe_anchor'] = 0
    features['onmouseover'] = 0
    features['right_clic'] = 0
    features['empty_title'] = 0
    features['domain_in_title'] = 0
    features['domain_with_copyright'] = 0
    
    # Domain and reputation features (simplified)
    features['whois_registered_domain'] = 0
    features['domain_registration_length'] = 0
    features['domain_age'] = 0
    features['web_traffic'] = 0
    features['dns_record'] = 0
    features['google_index'] = 0
    features['page_rank'] = 0
    
    # Ensure all required features are present in the correct order
    ordered_features = []
    for feature in phishing_feature_names:
        ordered_features.append(features.get(feature, 0))
    
    return np.array([ordered_features])

def preprocess_fraud_features(data):
    """
    Create features array for fraud detection with proper scaling
    """
    features_dict = {
        'Time': data.time,
        'V1': data.v1, 'V2': data.v2, 'V3': data.v3, 'V4': data.v4, 'V5': data.v5,
        'V6': data.v6, 'V7': data.v7, 'V8': data.v8, 'V9': data.v9, 'V10': data.v10,
        'V11': data.v11, 'V12': data.v12, 'V13': data.v13, 'V14': data.v14, 'V15': data.v15,
        'V16': data.v16, 'V17': data.v17, 'V18': data.v18, 'V19': data.v19, 'V20': data.v20,
        'V21': data.v21, 'V22': data.v22, 'V23': data.v23, 'V24': data.v24, 'V25': data.v25,
        'V26': data.v26, 'V27': data.v27, 'V28': data.v28, 'Amount': data.amount
    }
    
    # Create DataFrame with features in correct order
    features_df = pd.DataFrame([features_dict])[fraud_feature_names]
    
    # Scale features using the trained scaler
    features_scaled = fraud_scaler.transform(features_df)
    
    return features_scaled

def preprocess_fake_news_features(title, text):
    """
    Create TF-IDF features for fake news detection using the new simple model
    """
    # Combine title and text (same format as training)
    combined_text = title + ' ' + text
    
    # Transform using the trained TF-IDF vectorizer
    features = text_extractor.transform([combined_text])
    
    return features

# ===============================
# FAKE NEWS ENDPOINT
# ===============================

@app.post("/fake-news")
def detect_fake_news(data: NewsInput):
    try:
        # Preprocess features using full TF-IDF extraction
        features = preprocess_fake_news_features(data.title, data.text)
        
        # Make prediction
        prediction = fake_news_model.predict(features)[0]
        prediction_proba = fake_news_model.predict_proba(features)[0]
        
        result = "Fake News" if prediction == 1 else "True News"
        confidence = float(max(prediction_proba))
        
        # Save raw input to MongoDB (optional)
        mongo_collection = get_mongo_collection()
        if mongo_collection is not None:
            try:
                mongo_collection.insert_one({
                    "type": "fake_news",
                    "raw_input": {
                        "title": data.title,
                        "text": data.text,
                        "user_id": data.user_id
                    },
                    "timestamp": datetime.now(),
                    "ip_address": None,
                    "user_agent": None
                })
            except Exception as mongo_error:
                print(f"MongoDB error: {mongo_error}")
        
        # Save to PostgreSQL (result with full data)
        import json
        input_data = {
            "title": data.title,
            "text": data.text,
            "user_id": data.user_id
        }
        
        ml_probabilities = {
            "fake_news": float(prediction_proba[1]),
            "true_news": float(prediction_proba[0])
        }
        
        cursor = get_pg_cursor()
        if cursor is not None:
            try:
                cursor.execute(
                    """
                    INSERT INTO reports (user_id, type, input_data, result, confidence, ml_probabilities, created_at) 
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    """,
                    (data.user_id, "fake_news", json.dumps(input_data), result, confidence, json.dumps(ml_probabilities), datetime.now())
                )
                pg_conn.commit()
            except Exception as db_error:
                pg_conn.rollback()
                print(f"Database error in reports: {db_error}")
            
            # Update analytics
            try:
                cursor.execute(
                    """
                    INSERT INTO analytics (user_id, endpoint, request_count, avg_confidence, success_count, date, created_at)
                    VALUES (%s, %s, 1, %s, 1, CURRENT_DATE, CURRENT_TIMESTAMP)
                    ON CONFLICT (user_id, endpoint, date) 
                    DO UPDATE SET 
                        request_count = analytics.request_count + 1,
                        avg_confidence = (analytics.avg_confidence * analytics.request_count + %s) / (analytics.request_count + 1),
                        success_count = analytics.success_count + 1
                    """,
                    (data.user_id, "/fake-news", confidence, confidence)
                )
                pg_conn.commit()
            except Exception as db_error:
                pg_conn.rollback()
                print(f"Database error in analytics: {db_error}")

        return {
            "result": result,
            "confidence": confidence,
            "fake_news_probability": float(prediction_proba[1]),
            "true_news_probability": float(prediction_proba[0])
        }
    except Exception as e:
        return {
            "error": str(e),
            "result": "Error",
            "confidence": 0.0,
            "fake_news_probability": 0.0,
            "true_news_probability": 0.0
        }
# PHISHING DETECTION
# ===============================

@app.post("/phishing")
def detect_phishing(data: URLInput):
    try:
        # Preprocess features using full feature extraction
        features = preprocess_phishing_features(data.url)
        
        # Make prediction
        prediction = phishing_model.predict(features)[0]
        prediction_proba = phishing_model.predict_proba(features)[0]
        
        # Use label encoder to get proper result
        result = phishing_encoder.inverse_transform([prediction])[0]
        confidence = float(max(prediction_proba))
        
        # Save raw input to MongoDB (optional)
        mongo_collection = get_mongo_collection()
        if mongo_collection is not None:
            try:
                mongo_collection.insert_one({
                    "type": "phishing",
                    "raw_input": {
                        "url": data.url,
                        "user_id": data.user_id
                    },
                    "timestamp": datetime.now(),
                    "ip_address": None,
                    "user_agent": None
                })
            except Exception as mongo_error:
                print(f"MongoDB error: {mongo_error}")
        
        # Save to PostgreSQL (result with full data)
        input_data = {
            "url": data.url,
            "user_id": data.user_id
        }
        
        ml_probabilities = {
            "phishing": float(prediction_proba[1]) if len(prediction_proba) > 1 else 0.0,
            "legitimate": float(prediction_proba[0]) if len(prediction_proba) > 1 else 0.0
        }
        
        cursor = get_pg_cursor()
        if cursor is not None:
            try:
                cursor.execute(
                    """
                    INSERT INTO reports (user_id, type, input_data, result, confidence, ml_probabilities, created_at) 
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    """,
                    (data.user_id, "phishing", json.dumps(input_data), result, confidence, json.dumps(ml_probabilities), datetime.now())
                )
                pg_conn.commit()
            except Exception as db_error:
                pg_conn.rollback()
                print(f"Database error in reports: {db_error}")
            
            # Update analytics with separate transaction
            try:
                cursor.execute(
                    """
                    INSERT INTO analytics (user_id, endpoint, request_count, avg_confidence, success_count, date, created_at)
                    VALUES (%s, %s, 1, %s, 1, CURRENT_DATE, CURRENT_TIMESTAMP)
                    ON CONFLICT (user_id, endpoint, date) 
                    DO UPDATE SET 
                        request_count = analytics.request_count + 1,
                        avg_confidence = (analytics.avg_confidence * analytics.request_count + %s) / (analytics.request_count + 1),
                        success_count = analytics.success_count + 1
                    """,
                    (data.user_id, "/phishing", confidence, confidence)
                )
                pg_conn.commit()
            except Exception as db_error:
                pg_conn.rollback()
                print(f"Database error in analytics: {db_error}")

        return {
            "result": result,
            "confidence": confidence,
            "phishing_probability": float(prediction_proba[1]) if len(prediction_proba) > 1 else 0.0,
            "legitimate_probability": float(prediction_proba[0]) if len(prediction_proba) > 1 else 0.0
        }
    except Exception as e:
        return {
            "error": str(e),
            "result": "Error",
            "confidence": 0.0,
            "phishing_probability": 0.0,
            "legitimate_probability": 0.0
        }
@app.post("/fraud")
def detect_fraud(data: TransactionInput):
    try:
        # Preprocess features with proper scaling
        features = preprocess_fraud_features(data)
        
        # Make prediction on scaled features
        prediction = fraud_model.predict(features)[0]
        prediction_proba = fraud_model.predict_proba(features)[0]
        
        result = "Fraud" if prediction == 1 else "Legitimate"
        confidence = float(max(prediction_proba))
        
        # Save raw input to MongoDB (optional)
        mongo_collection = get_mongo_collection()
        if mongo_collection is not None:
            try:
                mongo_collection.insert_one({
                    "type": "fraud",
                    "raw_input": {
                        "time": data.time,
                        "amount": data.amount,
                        "v1": data.v1, "v2": data.v2, "v3": data.v3, "v4": data.v4, "v5": data.v5,
                        "v6": data.v6, "v7": data.v7, "v8": data.v8, "v9": data.v9, "v10": data.v10,
                        "v11": data.v11, "v12": data.v12, "v13": data.v13, "v14": data.v14, "v15": data.v15,
                        "v16": data.v16, "v17": data.v17, "v18": data.v18, "v19": data.v19, "v20": data.v20,
                        "v21": data.v21, "v22": data.v22, "v23": data.v23, "v24": data.v24, "v25": data.v25,
                        "v26": data.v26, "v27": data.v27, "v28": data.v28,
                        "user_id": data.user_id
                    },
                    "timestamp": datetime.now(),
                    "ip_address": None,
                    "user_agent": None
                })
            except Exception as mongo_error:
                print(f"MongoDB error: {mongo_error}")
        
        # Save to PostgreSQL (result with full data)
        import json
        input_data = {
            "time": data.time,
            "amount": data.amount,
            "v1": data.v1, "v2": data.v2, "v3": data.v3, "v4": data.v4, "v5": data.v5,
            "v6": data.v6, "v7": data.v7, "v8": data.v8, "v9": data.v9, "v10": data.v10,
            "v11": data.v11, "v12": data.v12, "v13": data.v13, "v14": data.v14, "v15": data.v15,
            "v16": data.v16, "v17": data.v17, "v18": data.v18, "v19": data.v19, "v20": data.v20,
            "v21": data.v21, "v22": data.v22, "v23": data.v23, "v24": data.v24, "v25": data.v25,
            "v26": data.v26, "v27": data.v27, "v28": data.v28,
            "user_id": data.user_id
        }
        
        ml_probabilities = {
            "fraud": float(prediction_proba[1]),
            "legitimate": float(prediction_proba[0])
        }
        
        cursor = get_pg_cursor()
        if cursor is not None:
            try:
                cursor.execute(
                    """
                    INSERT INTO reports (user_id, type, input_data, result, confidence, ml_probabilities, created_at) 
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    """,
                    (data.user_id, "fraud", json.dumps(input_data, default=str), result, confidence, json.dumps(ml_probabilities), datetime.now())
                )
                pg_conn.commit()
            except Exception as db_error:
                pg_conn.rollback()
                print(f"Database error in reports: {db_error}")
            
            # Update analytics
            try:
                cursor.execute(
                    """
                    INSERT INTO analytics (user_id, endpoint, request_count, avg_confidence, success_count, date, created_at)
                    VALUES (%s, %s, 1, %s, 1, CURRENT_DATE, CURRENT_TIMESTAMP)
                    ON CONFLICT (user_id, endpoint, date) 
                    DO UPDATE SET 
                        request_count = analytics.request_count + 1,
                        avg_confidence = (analytics.avg_confidence * analytics.request_count + %s) / (analytics.request_count + 1),
                        success_count = analytics.success_count + 1
                    """,
                    (data.user_id, "/fraud", confidence, confidence)
                )
                pg_conn.commit()
            except Exception as db_error:
                pg_conn.rollback()
                print(f"Database error in analytics: {db_error}")

        return {
            "result": result,
            "confidence": confidence,
            "fraud_probability": float(prediction_proba[1]),
            "legitimate_probability": float(prediction_proba[0])
        }
    except Exception as e:
        return {
            "error": str(e),
            "result": "Error",
            "confidence": 0.0,
            "fraud_probability": 0.0,
            "legitimate_probability": 0.0
        }

# ===============================
# ROOT
# ===============================

@app.get("/")
def home():
    return {"message": "SahiCheck API Running - PostgreSQL Connected and Active!"}


# ============================
# Mongo db connection test
# ============================

@app.get("/test-mongo")
def test_mongo():
    try:
        mongo_collection = get_mongo_collection()
        if mongo_collection is None:
            return {
                "error": "MongoDB not configured or unreachable",
                "message": "Set MONGO_URI environment variable to connect"
            }
        mongo_collection.insert_one({"test": "working", "timestamp": datetime.now()})
        return {"message": "MongoDB connected and working!"}
    except Exception as e:
        return {"error": str(e), "message": "MongoDB connection failed"}

# ===============================
# LIVE NEWS (RSS) — new feature, does not change ML endpoints above
# ===============================

from live_api import router as live_router

app.include_router(live_router)

# uvicorn main:app --host 0.0.0.0 --port 8002 --reload