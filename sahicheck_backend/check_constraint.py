import psycopg2

conn = psycopg2.connect(
    host="localhost",
    database="sahicheck",
    user="postgres",
    password="abdul123"
)
cur = conn.cursor()

# Check if constraint exists
cur.execute("SELECT conname FROM pg_constraint WHERE conname = 'analytics_user_endpoint_date_key'")
result = cur.fetchone()

if result:
    print("Constraint exists:", result)
else:
    print("Constraint does NOT exist")

# Check table structure
cur.execute("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'analytics'")
print("\nAnalytics table columns:")
for col in cur.fetchall():
    print(f"  {col[0]}: {col[1]}")

# Check for unique constraints on analytics
cur.execute("SELECT conname, contype FROM pg_constraint WHERE conrelid = 'analytics'::regclass")
print("\nConstraints on analytics table:")
for con in cur.fetchall():
    print(f"  {con[0]}: {con[1]}")

conn.close()