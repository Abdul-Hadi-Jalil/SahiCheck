import psycopg2

conn = psycopg2.connect(
    host="localhost",
    database="sahicheck",
    user="postgres",
    password="abdul123"
)
cur = conn.cursor()

# Check reports table structure
cur.execute("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'reports'")
print("Reports table columns:")
for col in cur.fetchall():
    print(f"  {col[0]}: {col[1]}")

# Check for constraints on reports
cur.execute("SELECT conname, contype FROM pg_constraint WHERE conrelid = 'reports'::regclass")
print("\nConstraints on reports table:")
for con in cur.fetchall():
    print(f"  {con[0]}: {con[1]}")

# Try inserting directly to see what happens
try:
    cur.execute("""
        INSERT INTO reports (user_id, type, input_data, result, confidence, ml_probabilities, created_at) 
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, 
        ("test_user", "fake_news", '{"title": "test"}', "True News", 0.9, '{"fake": 0.1, "true": 0.9}', "2024-01-01")
    )
    conn.commit()
    print("\nDirect insert to reports: SUCCESS")
except Exception as e:
    conn.rollback()
    print(f"\nDirect insert to reports: FAILED - {e}")

# Try inserting to analytics
try:
    cur.execute("""
        INSERT INTO analytics (user_id, endpoint, request_count, avg_confidence, success_count, date, created_at)
        VALUES (%s, %s, 1, %s, 1, CURRENT_DATE, CURRENT_TIMESTAMP)
        ON CONFLICT (user_id, endpoint, date) 
        DO UPDATE SET 
            request_count = analytics.request_count + 1
        """, 
        ("test_user", "/fake-news", 0.9)
    )
    conn.commit()
    print("Direct insert to analytics: SUCCESS")
except Exception as e:
    conn.rollback()
    print(f"Direct insert to analytics: FAILED - {e}")

conn.close()