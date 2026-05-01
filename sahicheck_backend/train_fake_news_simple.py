import pandas as pd
import numpy as np
import pickle
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score
import os

def train_simple_fake_news_model():
    """
    Train a simple fake news detection model with TF-IDF that can be easily loaded
    """
    print("Training Simple Fake News Detection Model...")
    
    # Load datasets
    try:
        fake_df = pd.read_csv('datasets/fake and true dataset/Fake.csv')
        true_df = pd.read_csv('datasets/fake and true dataset/True.csv')
        
        # Add labels
        fake_df['label'] = 1  # Fake news
        true_df['label'] = 0  # True news
        
        # Combine datasets
        df = pd.concat([fake_df, true_df], ignore_index=True)
        
        # Use title and text
        df['combined_text'] = df['title'] + ' ' + df['text']
        
        print(f"Dataset loaded: {len(df)} articles")
        print(f"Fake news: {len(fake_df)}, True news: {len(true_df)}")
        
    except Exception as e:
        print(f"Error loading datasets: {e}")
        return None
    
    # Create TF-IDF features
    print("Creating TF-IDF features...")
    tfidf = TfidfVectorizer(
        max_features=5000,
        stop_words='english',
        ngram_range=(1, 2),
        min_df=2,
        max_df=0.8
    )
    
    # Prepare features and labels
    X = tfidf.fit_transform(df['combined_text'])
    y = df['label']
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    # Train Random Forest
    print("Training Random Forest model...")
    model = RandomForestClassifier(
        n_estimators=100,
        random_state=42,
        max_depth=20,
        min_samples_split=5,
        min_samples_leaf=2
    )
    
    model.fit(X_train, y_train)
    
    # Evaluate
    print("Evaluating model...")
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    
    print(f"Accuracy: {accuracy:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=['True News', 'Fake News']))
    
    # Save model and vectorizer
    print("\nSaving model and components...")
    
    # Create saved_models directory if it doesn't exist
    os.makedirs('saved_models', exist_ok=True)
    
    # Save the model
    with open('saved_models/fake_news_simple_model.pkl', 'wb') as f:
        pickle.dump(model, f)
    
    # Save the TF-IDF vectorizer
    with open('saved_models/fake_news_simple_tfidf.pkl', 'wb') as f:
        pickle.dump(tfidf, f)
    
    print("Simple fake news model saved successfully!")
    print("Files saved:")
    print("- fake_news_simple_model.pkl (Random Forest model)")
    print("- fake_news_simple_tfidf.pkl (TF-IDF vectorizer)")
    
    return model, tfidf

def predict_fake_news_simple(title, text, model, tfidf):
    """
    Make prediction using the simple model
    """
    # Combine title and text
    combined_text = title + ' ' + text
    
    # Transform using the same TF-IDF vectorizer
    features = tfidf.transform([combined_text])
    
    # Make prediction
    prediction = model.predict(features)[0]
    prediction_proba = model.predict_proba(features)[0]
    
    result = "Fake News" if prediction == 1 else "True News"
    confidence = float(max(prediction_proba))
    
    return {
        'result': result,
        'prediction': int(prediction),
        'confidence': confidence,
        'fake_news_probability': float(prediction_proba[1]),
        'true_news_probability': float(prediction_proba[0])
    }

if __name__ == "__main__":
    model, tfidf = train_simple_fake_news_model()
    
    # Test with sample
    print("\n" + "="*50)
    print("TESTING WITH SAMPLE PREDICTIONS")
    print("="*50)
    
    test_samples = [
        {
            'title': 'Breaking: Scientists Discover Cure for Cancer',
            'text': 'Scientists have announced a groundbreaking discovery that could cure all forms of cancer.'
        },
        {
            'title': 'President Signs New Climate Bill',
            'text': 'The president today signed comprehensive climate legislation that aims to reduce carbon emissions.'
        },
        {
            'title': 'Local Bakery Wins Community Award',
            'text': 'Main Street Bakery was recognized for its contributions to the local community.'
        }
    ]
    
    for i, sample in enumerate(test_samples, 1):
        result = predict_fake_news_simple(
            sample['title'], 
            sample['text'], 
            model, 
            tfidf
        )
        print(f"\nTest {i}: {sample['title'][:50]}...")
        print(f"Result: {result['result']}")
        print(f"Confidence: {result['confidence']:.3f}")
        print(f"Probabilities - Fake: {result['fake_news_probability']:.3f}, True: {result['true_news_probability']:.3f}")
