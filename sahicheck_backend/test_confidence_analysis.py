import requests
import json

def test_confidence_analysis():
    base_url = "http://localhost:8002"
    
    print("=== Confidence Analysis - Testing Different Inputs ===\n")
    
    # Test 1: Different URLs for phishing detection
    print("1. Testing Phishing Detection with Different URLs")
    test_urls = [
        "https://www.google.com",  # Legitimate
        "https://bit.ly/xyz123",  # Suspicious shortener
        "http://192.168.1.1/login",  # IP address
        "https://paypal.com.secure-update.com/login",  # Suspicious domain
        "https://www.microsoft.com"  # Legitimate
    ]
    
    for i, url in enumerate(test_urls, 1):
        data = {"url": url, "user_id": f"test{i}"}
        try:
            response = requests.post(f"{base_url}/phishing", json=data)
            result = response.json()
            print(f"  URL {i}: {url}")
            print(f"  Result: {result['result']} (Confidence: {result['confidence']:.3f})")
        except Exception as e:
            print(f"  URL {i}: FAILED - {e}")
    
    print("\n2. Testing Fraud Detection with Different Transaction Patterns")
    # Normal transaction
    normal_data = {
        "time": 1000.0,
        "v1": 0.1, "v2": -0.2, "v3": 0.3, "v4": -0.1, "v5": 0.2, "v6": -0.3, "v7": 0.4, "v8": -0.2, "v9": 0.1, "v10": -0.1,
        "v11": 0.2, "v12": -0.1, "v13": 0.3, "v14": -0.2, "v15": 0.1, "v16": -0.3, "v17": 0.2, "v18": -0.1, "v19": 0.3, "v20": -0.2,
        "v21": 0.1, "v22": -0.2, "v23": 0.3, "v24": -0.1, "v25": 0.2, "v26": -0.3, "v27": 0.1, "v28": -0.2,
        "amount": 25.50,
        "user_id": "normal_test"
    }
    
    # High amount transaction (potentially suspicious)
    high_amount_data = {
        "time": 2000.0,
        "v1": -2.5, "v2": 1.8, "v3": -1.2, "v4": 2.1, "v5": -1.8, "v6": 1.5, "v7": -2.2, "v8": 1.9, "v9": -1.6, "v10": 2.3,
        "v11": -1.9, "v12": 2.0, "v13": -1.7, "v14": 2.4, "v15": -1.3, "v16": 2.2, "v17": -1.8, "v18": 2.1, "v19": -1.5, "v20": 2.0,
        "v21": -1.6, "v22": 2.3, "v23": -1.4, "v24": 2.1, "v25": -1.9, "v26": 2.2, "v27": -1.7, "v28": 2.0,
        "amount": 5000.00,
        "user_id": "high_amount_test"
    }
    
    for name, data in [("Normal Transaction", normal_data), ("High Amount Transaction", high_amount_data)]:
        try:
            response = requests.post(f"{base_url}/fraud", json=data)
            result = response.json()
            print(f"  {name}:")
            print(f"  Result: {result['result']} (Confidence: {result['confidence']:.3f})")
        except Exception as e:
            print(f"  {name}: FAILED - {e}")
    
    print("\n3. Testing Fake News Detection with Different Articles")
    test_articles = [
        {
            "title": "President Signs New Climate Bill",
            "text": "The president today signed comprehensive climate legislation that aims to reduce carbon emissions by 40% over the next decade.",
            "user_id": "real_news_test"
        },
        {
            "title": "SHOCKING: Alien Spaceship Lands at White House!",
            "text": "In an unbelievable turn of events, a massive alien spacecraft has landed on the White House lawn! Witnesses report seeing strange beings emerge!",
            "user_id": "sensational_test"
        },
        {
            "title": "Local Bakery Wins Community Award",
            "text": "Main Street Bakery was recognized for its contributions to the local community over the past 15 years.",
            "user_id": "local_news_test"
        }
    ]
    
    for i, article in enumerate(test_articles, 1):
        try:
            response = requests.post(f"{base_url}/fake-news", json=article)
            result = response.json()
            print(f"  Article {i}: {article['title'][:50]}...")
            print(f"  Result: {result['result']} (Confidence: {result['confidence']:.3f})")
        except Exception as e:
            print(f"  Article {i}: FAILED - {e}")
    
    print("\n=== Analysis Complete ===")

if __name__ == "__main__":
    test_confidence_analysis()
