import psycopg2

conn = psycopg2.connect(
    host="localhost",
    database="sahicheck",
    user="postgres",
    password="abdul123"
)
cur = conn.cursor()

# Set search path to sahicheck_schema
cur.execute("SET search_path TO sahicheck_schema, public")
conn.commit()

# Try the exact insert that the backend does
import json

input_data = {
    "title": "test",
    "text": "test text",
    "user_id": "user123"
}

ml_probabilities = {
    "fake_news": 0.5,
    "true_news": 0.5
}

try:
    cur.execute(
        """
        INSERT INTO reports (user_id, type, input_data, result, confidence, ml_probabilities, created_at) 
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """,
        ("user123", "fake_news", json.dumps(input_data), "True News", 0.5, json.dumps(ml_probabilities), "2024-01-01")
    )
    conn.commit()
    print("Reports insert: SUCCESS")
except Exception as e:
    conn.rollback()
    print(f"Reports insert: FAILED - {e}")

# Try analytics insert
try:
    cur.execute(
        """
        INSERT INTO analytics (user_id, endpoint, request_count, avg_confidence, success_count, date, created_at)
        VALUES (%s, %s, 1, %s, 1, CURRENT_DATE, CURRENT_TIMESTAMP)
        ON CONFLICT (user_id, endpoint, date) 
        DO UPDATE SET 
            request_count = analytics.request_count + 1,
            avg_confidence = (analytics.avg_confidence * analytics.request_count + %s) / (analytics.request_count + 1),
            success_count = analytics.success_count + 1
        """,
        ("user123", "/fake-news", 0.5, 0.5)
    )
    conn.commit()
    print("Analytics insert: SUCCESS")
except Exception as e:
    conn.rollback()
    print(f"Analytics insert: FAILED - {e}")

conn.close()