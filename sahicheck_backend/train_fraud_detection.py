import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, roc_auc_score
from sklearn.preprocessing import StandardScaler
from sklearn.utils import resample
import pickle
import os
import warnings
warnings.filterwarnings('ignore')

def train_fraud_detection():
    """
    Train a fraud detection model using the credit card dataset
    """
    print("Loading fraud detection dataset...")
    
    # Load the dataset
    dataset_path = 'datasets/fraud detection/creditcard.csv'
    df = pd.read_csv(dataset_path)
    
    print(f"Dataset shape: {df.shape}")
    print(f"Columns: {list(df.columns)}")
    
    # Check for missing values
    print(f"Missing values: {df.isnull().sum().sum()}")
    
    # Check class distribution
    print("\nClass distribution:")
    print(df['Class'].value_counts())
    print(f"Fraud percentage: {df['Class'].mean()*100:.4f}%")
    
    # Prepare features and target
    X = df.drop('Class', axis=1)
    y = df['Class']
    
    # Handle class imbalance using undersampling
    print("\nHandling class imbalance...")
    
    # Separate majority and minority classes
    df_majority = df[df['Class'] == 0]
    df_minority = df[df['Class'] == 1]
    
    # Undersample majority class
    df_majority_undersampled = resample(df_majority, 
                                       replace=False, 
                                       n_samples=len(df_minority)*5,  # 5:1 ratio
                                       random_state=42)
    
    # Combine minority class with undersampled majority class
    df_balanced = pd.concat([df_majority_undersampled, df_minority])
    
    # Shuffle the dataset
    df_balanced = df_balanced.sample(frac=1, random_state=42).reset_index(drop=True)
    
    print(f"Balanced dataset shape: {df_balanced.shape}")
    print("Balanced class distribution:")
    print(df_balanced['Class'].value_counts())
    
    # Prepare features and target from balanced dataset
    X_balanced = df_balanced.drop('Class', axis=1)
    y_balanced = df_balanced['Class']
    
    # Scale the features (important for Time and Amount)
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X_balanced)
    
    # Split the data
    X_train, X_test, y_train, y_test = train_test_split(
        X_scaled, y_balanced, test_size=0.2, random_state=42, stratify=y_balanced
    )
    
    print(f"Training set shape: {X_train.shape}")
    print(f"Test set shape: {X_test.shape}")
    
    # Train Random Forest model
    print("Training Random Forest model...")
    rf_model = RandomForestClassifier(
        n_estimators=100,
        random_state=42,
        max_depth=15,
        min_samples_split=10,
        min_samples_leaf=5,
        class_weight='balanced'
    )
    
    rf_model.fit(X_train, y_train)
    
    # Make predictions
    y_pred = rf_model.predict(X_test)
    y_pred_proba = rf_model.predict_proba(X_test)[:, 1]
    
    # Evaluate the model
    print("\nModel Evaluation:")
    print(f"Accuracy: {accuracy_score(y_test, y_pred):.4f}")
    print(f"ROC AUC Score: {roc_auc_score(y_test, y_pred_proba):.4f}")
    
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=['Legitimate', 'Fraud']))
    
    print("\nConfusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    
    # Feature importance
    feature_importance = pd.DataFrame({
        'feature': X_balanced.columns,
        'importance': rf_model.feature_importances_
    }).sort_values('importance', ascending=False)
    
    print("\nTop 10 Important Features:")
    print(feature_importance.head(10))
    
    # Save the model, scaler, and feature names
    models_dir = 'saved_models'
    os.makedirs(models_dir, exist_ok=True)
    
    model_path = os.path.join(models_dir, 'fraud_detection_model.pkl')
    scaler_path = os.path.join(models_dir, 'fraud_scaler.pkl')
    feature_names_path = os.path.join(models_dir, 'fraud_feature_names.pkl')
    
    with open(model_path, 'wb') as f:
        pickle.dump(rf_model, f)
    
    with open(scaler_path, 'wb') as f:
        pickle.dump(scaler, f)
    
    with open(feature_names_path, 'wb') as f:
        pickle.dump(list(X_balanced.columns), f)
    
    print(f"\nModel saved to: {model_path}")
    print(f"Scaler saved to: {scaler_path}")
    print(f"Feature names saved to: {feature_names_path}")
    
    return rf_model, scaler, feature_importance

def load_fraud_model():
    """
    Load the saved fraud detection model
    """
    models_dir = 'saved_models'
    model_path = os.path.join(models_dir, 'fraud_detection_model.pkl')
    scaler_path = os.path.join(models_dir, 'fraud_scaler.pkl')
    feature_names_path = os.path.join(models_dir, 'fraud_feature_names.pkl')
    
    with open(model_path, 'rb') as f:
        model = pickle.load(f)
    
    with open(scaler_path, 'rb') as f:
        scaler = pickle.load(f)
    
    with open(feature_names_path, 'rb') as f:
        feature_names = pickle.load(f)
    
    return model, scaler, feature_names

def predict_fraud(transaction_features):
    """
    Make prediction on new transaction features
    """
    model, scaler, feature_names = load_fraud_model()
    
    # Ensure the features are in the correct order
    if isinstance(transaction_features, dict):
        features_df = pd.DataFrame([transaction_features])
        features_df = features_df[feature_names]  # Reorder columns
    else:
        features_df = transaction_features
    
    # Scale the features
    features_scaled = scaler.transform(features_df)
    
    prediction = model.predict(features_scaled)
    prediction_proba = model.predict_proba(features_scaled)
    
    result = {
        'prediction': 'Fraud' if prediction[0] == 1 else 'Legitimate',
        'confidence': np.max(prediction_proba),
        'fraud_probability': prediction_proba[0][1],
        'legitimate_probability': prediction_proba[0][0]
    }
    
    return result

if __name__ == "__main__":
    # Train the model
    model, scaler, feature_importance = train_fraud_detection()
    
    # Test loading and prediction
    print("\n" + "="*50)
    print("Testing model loading and prediction...")
    
    # Get a sample from the test set
    dataset_path = 'datasets/fraud detection/creditcard.csv'
    df = pd.read_csv(dataset_path)
    sample_features = df.drop('Class', axis=1).iloc[0:1]
    
    result = predict_fraud(sample_features)
    print(f"Sample prediction: {result}")
