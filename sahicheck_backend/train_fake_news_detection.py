import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
from sklearn.pipeline import Pipeline
from sklearn.base import BaseEstimator, TransformerMixin
import re
import pickle
import os
import warnings
warnings.filterwarnings('ignore')

class TextFeatureExtractor(BaseEstimator, TransformerMixin):
    """
    Custom transformer to extract text features
    """
    def __init__(self):
        self.tfidf_vectorizer = TfidfVectorizer(
            max_features=5000,
            stop_words='english',
            ngram_range=(1, 2),
            min_df=2,
            max_df=0.8
        )
    
    def fit(self, X, y=None):
        # Combine title and text for better feature extraction
        combined_text = X['title'].fillna('') + ' ' + X['text'].fillna('')
        self.tfidf_vectorizer.fit(combined_text)
        return self
    
    def transform(self, X):
        # Combine title and text
        combined_text = X['title'].fillna('') + ' ' + X['text'].fillna('')
        tfidf_features = self.tfidf_vectorizer.transform(combined_text)
        
        # Add additional text features
        features = []
        for idx, row in X.iterrows():
            title = str(row['title']) if pd.notna(row['title']) else ''
            text = str(row['text']) if pd.notna(row['text']) else ''
            
            # Text-based features
            title_length = len(title)
            text_length = len(text)
            title_word_count = len(title.split())
            text_word_count = len(text.split())
            
            # Punctuation features
            title_exclamation = title.count('!')
            title_question = title.count('?')
            text_exclamation = text.count('!')
            text_question = text.count('?')
            
            # Capitalization features
            title_caps_ratio = sum(1 for c in title if c.isupper()) / max(len(title), 1)
            text_caps_ratio = sum(1 for c in text if c.isupper()) / max(len(text), 1)
            
            # Combine features
            text_features = [
                title_length, text_length, title_word_count, text_word_count,
                title_exclamation, title_question, text_exclamation, text_question,
                title_caps_ratio, text_caps_ratio
            ]
            
            features.append(text_features)
        
        # Combine TF-IDF features with text features
        text_features_array = np.array(features)
        combined_features = np.hstack([tfidf_features.toarray(), text_features_array])
        
        return combined_features

def train_fake_news_detection():
    """
    Train a fake news detection model using the fake and true news datasets
    """
    print("Loading fake news datasets...")
    
    # Load the datasets
    fake_path = 'datasets/fake and true dataset/Fake.csv'
    true_path = 'datasets/fake and true dataset/True.csv'
    
    df_fake = pd.read_csv(fake_path)
    df_true = pd.read_csv(true_path)
    
    print(f"Fake news dataset shape: {df_fake.shape}")
    print(f"True news dataset shape: {df_true.shape}")
    
    # Add labels
    df_fake['label'] = 1  # Fake news
    df_true['label'] = 0  # True news
    
    # Combine datasets
    df = pd.concat([df_fake, df_true], ignore_index=True)
    
    print(f"Combined dataset shape: {df.shape}")
    print(f"Columns: {list(df.columns)}")
    
    # Check for missing values
    print(f"Missing values:\n{df.isnull().sum()}")
    
    # Drop rows with missing title or text
    df = df.dropna(subset=['title', 'text'])
    print(f"Dataset shape after dropping missing values: {df.shape}")
    
    # Check class distribution
    print("\nClass distribution:")
    print(df['label'].value_counts())
    print(f"Fake news percentage: {df['label'].mean()*100:.2f}%")
    
    # Prepare features and target
    X = df[['title', 'text']]
    y = df['label']
    
    # Split the data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    print(f"Training set shape: {X_train.shape}")
    print(f"Test set shape: {X_test.shape}")
    
    # Create pipeline with text feature extraction and model
    print("Training Random Forest model with text features...")
    
    # Create the text feature extractor
    text_extractor = TextFeatureExtractor()
    
    # Extract features
    X_train_features = text_extractor.fit_transform(X_train)
    X_test_features = text_extractor.transform(X_test)
    
    # Train Random Forest model
    rf_model = RandomForestClassifier(
        n_estimators=100,
        random_state=42,
        max_depth=20,
        min_samples_split=5,
        min_samples_leaf=2,
        class_weight='balanced'
    )
    
    rf_model.fit(X_train_features, y_train)
    
    # Make predictions
    y_pred = rf_model.predict(X_test_features)
    y_pred_proba = rf_model.predict_proba(X_test_features)[:, 1]
    
    # Evaluate the model
    print("\nModel Evaluation:")
    print(f"Accuracy: {accuracy_score(y_test, y_pred):.4f}")
    
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=['True News', 'Fake News']))
    
    print("\nConfusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    
    # Save the model and text extractor
    models_dir = 'saved_models'
    os.makedirs(models_dir, exist_ok=True)
    
    model_path = os.path.join(models_dir, 'fake_news_detection_model.pkl')
    text_extractor_path = os.path.join(models_dir, 'fake_news_text_extractor.pkl')
    
    with open(model_path, 'wb') as f:
        pickle.dump(rf_model, f)
    
    with open(text_extractor_path, 'wb') as f:
        pickle.dump(text_extractor, f)
    
    print(f"\nModel saved to: {model_path}")
    print(f"Text extractor saved to: {text_extractor_path}")
    
    return rf_model, text_extractor

def load_fake_news_model():
    """
    Load the saved fake news detection model
    """
    models_dir = 'saved_models'
    model_path = os.path.join(models_dir, 'fake_news_detection_model.pkl')
    text_extractor_path = os.path.join(models_dir, 'fake_news_text_extractor.pkl')
    
    with open(model_path, 'rb') as f:
        model = pickle.load(f)
    
    with open(text_extractor_path, 'rb') as f:
        text_extractor = pickle.load(f)
    
    return model, text_extractor

def predict_fake_news(title, text):
    """
    Make prediction on new news article
    """
    model, text_extractor = load_fake_news_model()
    
    # Create DataFrame with the input
    input_data = pd.DataFrame({
        'title': [title],
        'text': [text]
    })
    
    # Extract features
    features = text_extractor.transform(input_data)
    
    # Make prediction
    prediction = model.predict(features)
    prediction_proba = model.predict_proba(features)
    
    result = {
        'prediction': 'Fake News' if prediction[0] == 1 else 'True News',
        'confidence': np.max(prediction_proba),
        'fake_news_probability': prediction_proba[0][1],
        'true_news_probability': prediction_proba[0][0]
    }
    
    return result

def preprocess_text(text):
    """
    Basic text preprocessing
    """
    if pd.isna(text):
        return ""
    
    # Convert to lowercase
    text = str(text).lower()
    
    # Remove URLs
    text = re.sub(r'http\S+|www\S+|https\S+', '', text, flags=re.MULTILINE)
    
    # Remove HTML tags
    text = re.sub(r'<.*?>', '', text)
    
    # Remove special characters and numbers
    text = re.sub(r'[^a-zA-Z\s]', '', text)
    
    # Remove extra whitespace
    text = re.sub(r'\s+', ' ', text).strip()
    
    return text

if __name__ == "__main__":
    # Train the model
    model, text_extractor = train_fake_news_detection()
    
    # Test loading and prediction
    print("\n" + "="*50)
    print("Testing model loading and prediction...")
    
    # Test with sample data
    sample_title = "Breaking: Major Scientific Discovery Changes Everything"
    sample_text = "Scientists have made a groundbreaking discovery that could revolutionize our understanding of the universe. The research team found evidence that supports previously unproven theories about dark matter and energy."
    
    result = predict_fake_news(sample_title, sample_text)
    print(f"Sample prediction: {result}")
    
    # Test with another sample
    fake_title = "SHOCKING! Celebrity Caught in Scandal You Won't Believe!"
    fake_text = "You won't believe what happened when cameras caught this famous person doing something absolutely outrageous! This exclusive footage will leave you speechless. Click here to see the shocking evidence that everyone is talking about!"
    
    result2 = predict_fake_news(fake_title, fake_text)
    print(f"Fake sample prediction: {result2}")
