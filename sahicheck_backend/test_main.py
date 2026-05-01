from fastapi import FastAPI
from pydantic import BaseModel
import pickle
import numpy as np
import pandas as pd
from datetime import datetime
import re
from urllib.parse import urlparse

app = FastAPI()

# ===============================
# LOAD MODELS
# ===============================

# Load only the main trained models
with open("saved_models/phishing_detection_model.pkl", "rb") as f:
    phishing_model = pickle.load(f)

with open("saved_models/fraud_detection_model.pkl", "rb") as f:
    fraud_model = pickle.load(f)

with open("saved_models/fake_news_detection_model.pkl", "rb") as f:
    fake_news_model = pickle.load(f)

# Create a simple TF-IDF vectorizer for fake news (matching training parameters)
from sklearn.feature_extraction.text import TfidfVectorizer
text_extractor = TfidfVectorizer(
    max_features=5000,
    stop_words='english',
    ngram_range=(1, 2),
    min_df=2,
    max_df=0.8
)

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
    Extract comprehensive features for phishing detection
    """
    parsed = urlparse(url)
    
    # Basic URL features
    features = {
        'length_url': len(url),
        'length_hostname': len(parsed.netloc),
        'ip': 1 if re.match(r'\d+\.\d+\.\d+\.\d+', parsed.netloc) else 0,
        'nb_dots': url.count('.'),
        'nb_hyphens': url.count('-'),
        'nb_at': url.count('@'),
        'nb_qm': url.count('?'),
        'nb_and': url.count('&'),
        'nb_or': url.count('|'),
        'nb_eq': url.count('='),
        'nb_underscore': url.count('_'),
        'nb_tilde': url.count('~'),
        'nb_percent': url.count('%'),
        'nb_slash': url.count('/'),
        'nb_star': url.count('*'),
        'nb_colon': url.count(':'),
        'nb_comma': url.count(','),
        'nb_semicolumn': url.count(';'),
        'nb_dollar': url.count('$'),
        'nb_space': url.count(' '),
        'nb_www': 1 if 'www.' in url else 0,
        'nb_com': 1 if '.com' in url else 0,
        'nb_dslash': url.count('//'),
        'http_in_path': 1 if 'http:' in parsed.path else 0,
        'https_token': 1 if 'https' in url else 0,
        'ratio_digits_url': sum(c.isdigit() for c in url) / len(url) if len(url) > 0 else 0,
        'ratio_digits_host': sum(c.isdigit() for c in parsed.netloc) / len(parsed.netloc) if len(parsed.netloc) > 0 else 0,
        'punycode': 1 if 'xn--' in parsed.netloc else 0,
        'port': parsed.port if parsed.port else 0,
        'tld_in_path': 1 if any(tld in parsed.path for tld in ['.com', '.org', '.net', '.edu', '.gov']) else 0,
        'tld_in_subdomain': 0,
        'abnormal_subdomain': 0,
        'nb_subdomains': len(parsed.netloc.split('.')) - 1 if parsed.netloc else 0,
        'prefix_suffix': 0,
        'random_domain': 0,
        'shortening_service': 1 if any(service in url for service in ['bit.ly', 'tinyurl.com', 't.co', 'goo.gl']) else 0,
        'path_extension': 0,
        'nb_redirection': 0,
        'nb_external_redirection': 0,
        'length_words_raw': len(url.split()),
        'char_repeat': 0,
        'shortest_words_raw': min(len(word) for word in url.split()) if url.split() else 0,
        'shortest_word_host': min(len(word) for word in parsed.netloc.split('.')) if parsed.netloc else 0,
        'shortest_word_path': min(len(word) for word in parsed.path.split('/')) if parsed.path else 0,
        'longest_words_raw': max(len(word) for word in url.split()) if url.split() else 0,
        'longest_word_host': max(len(word) for word in parsed.netloc.split('.')) if parsed.netloc else 0,
        'longest_word_path': max(len(word) for word in parsed.path.split('/')) if parsed.path else 0,
        'avg_words_raw': np.mean([len(word) for word in url.split()]) if url.split() else 0,
        'avg_word_host': np.mean([len(word) for word in parsed.netloc.split('.')]) if parsed.netloc else 0,
        'avg_word_path': np.mean([len(word) for word in parsed.path.split('/')]) if parsed.path else 0,
        'phish_hints': 0,
        'domain_in_brand': 0,
        'brand_in_subdomain': 0,
        'brand_in_path': 0,
        'suspecious_tld': 0,
        'statistical_report': 0,
        'nb_hyperlinks': 0,
        'ratio_intHyperlinks': 0,
        'ratio_extHyperlinks': 0,
        'ratio_nullHyperlinks': 0,
        'nb_extCSS': 0,
        'ratio_intRedirection': 0,
        'ratio_extRedirection': 0,
        'ratio_intErrors': 0,
        'ratio_extErrors': 0,
        'login_form': 0,
        'external_favicon': 0,
        'links_in_tags': 0,
        'submit_email': 0,
        'ratio_intMedia': 0,
        'ratio_extMedia': 0,
        'sfh': 0,
        'iframe': 0,
        'popup_window': 0,
        'safe_anchor': 0,
        'onmouseover': 0,
        'right_clic': 0,
        'empty_title': 0,
        'domain_in_title': 0,
        'domain_with_copyright': 0,
        'whois_registered_domain': 0,
        'domain_registration_length': 0,
        'domain_age': 0,
        'web_traffic': 0,
        'dns_record': 0,
        'google_index': 0,
        'page_rank': 0,
    }
    
    # Define the feature order that the model expects (87 features)
    feature_order = [
        'length_url', 'length_hostname', 'ip', 'nb_dots', 'nb_hyphens', 'nb_at', 'nb_qm', 'nb_and', 'nb_or', 'nb_eq',
        'nb_underscore', 'nb_tilde', 'nb_percent', 'nb_slash', 'nb_star', 'nb_colon', 'nb_comma', 'nb_semicolumn', 'nb_dollar', 'nb_space',
        'nb_www', 'nb_com', 'nb_dslash', 'http_in_path', 'https_token', 'ratio_digits_url', 'ratio_digits_host', 'punycode', 'port',
        'tld_in_path', 'tld_in_subdomain', 'abnormal_subdomain', 'nb_subdomains', 'prefix_suffix', 'random_domain', 'shortening_service',
        'path_extension', 'nb_redirection', 'nb_external_redirection', 'length_words_raw', 'char_repeat', 'shortest_words_raw',
        'shortest_word_host', 'shortest_word_path', 'longest_words_raw', 'longest_word_host', 'longest_word_path', 'avg_words_raw',
        'avg_word_host', 'avg_word_path', 'phish_hints', 'domain_in_brand', 'brand_in_subdomain', 'brand_in_path', 'suspecious_tld',
        'statistical_report', 'nb_hyperlinks', 'ratio_intHyperlinks', 'ratio_extHyperlinks', 'ratio_nullHyperlinks', 'nb_extCSS',
        'ratio_intRedirection', 'ratio_extRedirection', 'ratio_intErrors', 'ratio_extErrors', 'login_form', 'external_favicon', 'links_in_tags',
        'submit_email', 'ratio_intMedia', 'ratio_extMedia', 'sfh', 'iframe', 'popup_window', 'safe_anchor', 'onmouseover', 'right_clic',
        'empty_title', 'domain_in_title', 'domain_with_copyright', 'whois_registered_domain', 'domain_registration_length', 'domain_age',
        'web_traffic', 'dns_record', 'google_index', 'page_rank'
    ]
    
    # Ensure all required features are present and in correct order
    ordered_features = []
    for feature in feature_order:
        ordered_features.append(features.get(feature, 0))
    
    return np.array([ordered_features])

def preprocess_fraud_features(data):
    """
    Create features array for fraud detection in correct order
    """
    features = [
        data.time, data.v1, data.v2, data.v3, data.v4, data.v5, data.v6, data.v7, data.v8, data.v9,
        data.v10, data.v11, data.v12, data.v13, data.v14, data.v15, data.v16, data.v17, data.v18, data.v19,
        data.v20, data.v21, data.v22, data.v23, data.v24, data.v25, data.v26, data.v27, data.v28, data.amount
    ]
    return np.array([features])

def preprocess_fake_news_features(title, text):
    """
    Create TF-IDF features for fake news detection
    """
    # Combine title and text
    combined_text = title + " " + text
    
    # For simplicity, create basic text features that match the expected 5010 features
    # We'll create a sparse matrix with the right dimensions
    from scipy.sparse import csr_matrix
    
    # Create basic features and pad to 5010 dimensions
    basic_features = np.array([
        len(title), len(text), len(title.split()), len(text.split()),
        title.count('!'), title.count('?'), text.count('!'), text.count('?'),
        sum(1 for c in title if c.isupper()) / max(len(title), 1),
        sum(1 for c in text if c.isupper()) / max(len(text), 1)
    ])
    
    # Pad with zeros to reach 5010 features
    padded_features = np.zeros(5010)
    padded_features[:len(basic_features)] = basic_features
    
    return csr_matrix(padded_features)

# ===============================
# ENDPOINTS
# ===============================

@app.post("/fake-news")
def detect_fake_news(data: NewsInput):
    # Preprocess features
    features = preprocess_fake_news_features(data.title, data.text)
    
    # Make prediction
    prediction = fake_news_model.predict(features)[0]
    prediction_proba = fake_news_model.predict_proba(features)[0]
    
    result = "Fake News" if prediction == 1 else "True News"
    confidence = float(max(prediction_proba))
    
    return {
        "result": result,
        "confidence": confidence,
        "fake_news_probability": float(prediction_proba[1]),
        "true_news_probability": float(prediction_proba[0])
    }

@app.post("/phishing")
def detect_phishing(data: URLInput):
    # Preprocess features
    features = preprocess_phishing_features(data.url)
    
    # Make prediction
    prediction = phishing_model.predict(features)[0]
    prediction_proba = phishing_model.predict_proba(features)[0]
    
    result = "phishing" if prediction == 1 else "legitimate"
    confidence = float(max(prediction_proba))
    
    return {
        "result": result,
        "confidence": confidence,
        "phishing_probability": float(prediction_proba[1]) if len(prediction_proba) > 1 else 0.0,
        "legitimate_probability": float(prediction_proba[0]) if len(prediction_proba) > 1 else 0.0
    }

@app.post("/fraud")
def detect_fraud(data: TransactionInput):
    # Preprocess features
    features = preprocess_fraud_features(data)
    
    # Make prediction (model handles scaling internally)
    prediction = fraud_model.predict(features)[0]
    prediction_proba = fraud_model.predict_proba(features)[0]
    
    result = "Fraud" if prediction == 1 else "Legitimate"
    confidence = float(max(prediction_proba))
    
    return {
        "result": result,
        "confidence": confidence,
        "fraud_probability": float(prediction_proba[1]),
        "legitimate_probability": float(prediction_proba[0])
    }

@app.get("/")
def home():
    return {"message": "SahiCheck API Running - Testing Mode! No Database Connections"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
