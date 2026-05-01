import psycopg2

conn = psycopg2.connect(
    host="localhost",
    database="sahicheck",
    user="postgres",
    password="abdul123"
)
cur = conn.cursor()

# Check current search path
cur.execute("SHOW search_path")
print("Current search_path:", cur.fetchone())

# Check tables in both schemas
cur.execute("""
    SELECT table_schema, table_name 
    FROM information_schema.tables 
    WHERE table_name IN ('reports', 'analytics') 
    ORDER BY table_schema, table_name
""")
print("\nTables:")
for row in cur.fetchall():
    print(f"  {row[0]}.{row[1]}")

# Check if there's data in the tables
cur.execute("SELECT COUNT(*) FROM reports")
print("\nReports count:", cur.fetchone()[0])

cur.execute("SELECT COUNT(*) FROM analytics")
print("Analytics count:", cur.fetchone()[0])

conn.close()