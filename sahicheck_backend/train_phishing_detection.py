import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
from sklearn.preprocessing import LabelEncoder
import pickle
import os

def train_phishing_detection():
    """
    Train a phishing detection model using the phishing dataset
    """
    print("Loading phishing dataset...")
    
    # Load the dataset
    dataset_path = 'datasets/phishing dataset/dataset_phishing.csv'
    df = pd.read_csv(dataset_path)
    
    print(f"Dataset shape: {df.shape}")
    print(f"Columns: {list(df.columns)}")
    
    # Check for missing values
    print(f"Missing values: {df.isnull().sum().sum()}")
    
    # Prepare features and target
    X = df.drop(['status', 'url'], axis=1)  # Drop URL column as it's not a feature
    y = df['status']
    
    # Encode the target variable
    le = LabelEncoder()
    y_encoded = le.fit_transform(y)
    
    print(f"Target distribution: {pd.Series(y_encoded).value_counts()}")
    print(f"Classes: {le.classes_}")
    
    # Split the data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y_encoded, test_size=0.2, random_state=42, stratify=y_encoded
    )
    
    print(f"Training set shape: {X_train.shape}")
    print(f"Test set shape: {X_test.shape}")
    
    # Train Random Forest model
    print("Training Random Forest model...")
    rf_model = RandomForestClassifier(
        n_estimators=100,
        random_state=42,
        max_depth=10,
        min_samples_split=5,
        min_samples_leaf=2
    )
    
    rf_model.fit(X_train, y_train)
    
    # Make predictions
    y_pred = rf_model.predict(X_test)
    
    # Evaluate the model
    print("\nModel Evaluation:")
    print(f"Accuracy: {accuracy_score(y_test, y_pred):.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=le.classes_))
    
    print("\nConfusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    
    # Feature importance
    feature_importance = pd.DataFrame({
        'feature': X.columns,
        'importance': rf_model.feature_importances_
    }).sort_values('importance', ascending=False)
    
    print("\nTop 10 Important Features:")
    print(feature_importance.head(10))
    
    # Save the model and label encoder
    models_dir = 'saved_models'
    os.makedirs(models_dir, exist_ok=True)
    
    model_path = os.path.join(models_dir, 'phishing_detection_model.pkl')
    encoder_path = os.path.join(models_dir, 'phishing_label_encoder.pkl')
    
    with open(model_path, 'wb') as f:
        pickle.dump(rf_model, f)
    
    with open(encoder_path, 'wb') as f:
        pickle.dump(le, f)
    
    print(f"\nModel saved to: {model_path}")
    print(f"Label encoder saved to: {encoder_path}")
    
    # Save feature names for later use
    feature_names_path = os.path.join(models_dir, 'phishing_feature_names.pkl')
    with open(feature_names_path, 'wb') as f:
        pickle.dump(list(X.columns), f)
    
    print(f"Feature names saved to: {feature_names_path}")
    
    return rf_model, le, feature_importance

def load_phishing_model():
    """
    Load the saved phishing detection model
    """
    models_dir = 'saved_models'
    model_path = os.path.join(models_dir, 'phishing_detection_model.pkl')
    encoder_path = os.path.join(models_dir, 'phishing_label_encoder.pkl')
    feature_names_path = os.path.join(models_dir, 'phishing_feature_names.pkl')
    
    with open(model_path, 'rb') as f:
        model = pickle.load(f)
    
    with open(encoder_path, 'rb') as f:
        encoder = pickle.load(f)
    
    with open(feature_names_path, 'rb') as f:
        feature_names = pickle.load(f)
    
    return model, encoder, feature_names

def predict_phishing(url_features):
    """
    Make prediction on new URL features
    """
    model, encoder, feature_names = load_phishing_model()
    
    # Ensure the features are in the correct order
    if isinstance(url_features, dict):
        features_df = pd.DataFrame([url_features])
        features_df = features_df[feature_names]  # Reorder columns
    else:
        features_df = url_features
    
    prediction = model.predict(features_df)
    prediction_proba = model.predict_proba(features_df)
    
    result = {
        'prediction': encoder.inverse_transform(prediction)[0],
        'confidence': np.max(prediction_proba),
        'probabilities': {
            encoder.inverse_transform([i])[0]: prob 
            for i, prob in enumerate(prediction_proba[0])
        }
    }
    
    return result

if __name__ == "__main__":
    # Train the model
    model, encoder, feature_importance = train_phishing_detection()
    
    # Test loading and prediction
    print("\n" + "="*50)
    print("Testing model loading and prediction...")
    
    # Get a sample from the test set
    dataset_path = 'datasets/phishing dataset/dataset_phishing.csv'
    df = pd.read_csv(dataset_path)
    sample_features = df.drop(['status', 'url'], axis=1).iloc[0:1]
    
    result = predict_phishing(sample_features)
    print(f"Sample prediction: {result}")
