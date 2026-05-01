# Machine Learning Models Summary

## Overview
Successfully trained and saved three machine learning models for detecting phishing, fraud, and fake news using the datasets in the datasets folder.

## Dataset Analysis

### 1. Phishing Detection Dataset
- **File**: `datasets/phishing dataset/dataset_phishing.csv`
- **Samples**: 11,430 URLs
- **Features**: 87 URL-based features (excluding URL string)
- **Target**: Binary classification (legitimate/phishing)
- **Class Balance**: Perfectly balanced (5,715 each)

### 2. Fraud Detection Dataset
- **File**: `datasets/fraud detection/creditcard.csv`
- **Samples**: 284,807 transactions
- **Features**: 30 features (28 PCA features + Time + Amount)
- **Target**: Binary classification (legitimate/fraud)
- **Class Imbalance**: Highly imbalanced (0.17% fraud)
- **Handling**: Applied undersampling (5:1 ratio)

### 3. Fake News Detection Dataset
- **Files**: `datasets/fake and true dataset/Fake.csv` and `True.csv`
- **Samples**: 44,919 articles (23,502 fake, 21,417 true)
- **Features**: Text-based features using TF-IDF + linguistic features
- **Target**: Binary classification (true/fake news)
- **Class Balance**: Slightly imbalanced (52.3% fake)

## Model Performance

### 1. Phishing Detection Model
- **Algorithm**: Random Forest
- **Accuracy**: 95.10%
- **Precision**: 95% (both classes)
- **Recall**: 95% (both classes)
- **F1-Score**: 95% (both classes)
- **Top Features**: google_index, page_rank, nb_hyperlinks, web_traffic

### 2. Fraud Detection Model
- **Algorithm**: Random Forest with class balancing
- **Accuracy**: 96.79%
- **ROC AUC**: 98.20%
- **Precision**: 97% (legitimate), 98% (fraud)
- **Recall**: 100% (legitimate), 83% (fraud)
- **Top Features**: V14, V10, V4, V12, V17 (PCA components)

### 3. Fake News Detection Model
- **Algorithm**: Random Forest with TF-IDF text features
- **Accuracy**: 99.84%
- **Precision**: 100% (both classes)
- **Recall**: 100% (true news), 99.7% (fake news)
- **F1-Score**: 100% (both classes)
- **Features**: TF-IDF (5000 features) + linguistic features

## Saved Models

All models are saved in the `saved_models/` directory:

### Phishing Detection
- `phishing_detection_model.pkl` - Main model
- `phishing_label_encoder.pkl` - Target encoder
- `phishing_feature_names.pkl` - Feature names

### Fraud Detection
- `fraud_detection_model.pkl` - Main model
- `fraud_scaler.pkl` - Feature scaler
- `fraud_feature_names.pkl` - Feature names

### Fake News Detection
- `fake_news_detection_model.pkl` - Main model
- `fake_news_text_extractor.pkl` - Text feature extractor

## Usage

Each training script includes:
1. **Training function** - Trains and saves the model
2. **Loading function** - Loads saved models
3. **Prediction function** - Makes predictions on new data
4. **Example usage** - Demonstrates how to use the models

### Example Usage:

```python
# Phishing Detection
from train_phishing_detection import predict_phishing
result = predict_phishing(url_features_dict)

# Fraud Detection
from train_fraud_detection import predict_fraud
result = predict_fraud(transaction_features_dict)

# Fake News Detection
from train_fake_news_detection import predict_fake_news
result = predict_fake_news(title, text)
```

## Training Scripts
- `train_phishing_detection.py` - Phishing detection training and prediction
- `train_fraud_detection.py` - Fraud detection training and prediction
- `train_fake_news_detection.py` - Fake news detection training and prediction

## Dependencies
- pandas >= 1.3.0
- numpy >= 1.21.0
- scikit-learn >= 1.0.0
- joblib >= 1.0.0

All models are ready to be loaded and used for predictions!
