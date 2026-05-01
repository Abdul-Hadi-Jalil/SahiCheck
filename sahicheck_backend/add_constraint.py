import psycopg2

conn = psycopg2.connect(
    host="localhost",
    database="sahicheck",
    user="postgres",
    password="abdul123"
)
cur = conn.cursor()

# Add the unique constraint to sahicheck_schema.analytics
try:
    cur.execute("""
        ALTER TABLE sahicheck_schema.analytics 
        ADD CONSTRAINT analytics_user_endpoint_date_key 
        UNIQUE (user_id, endpoint, date)
    """)
    conn.commit()
    print("Constraint added successfully!")
except Exception as e:
    print(f"Error: {e}")

conn.close()