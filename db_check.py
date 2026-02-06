import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

def test_postgres_connection():
    try:
        print("Testing PostgreSQL connection...")
        
        # Test connection to default postgres database
        conn = psycopg2.connect(
            host="localhost",
            port="5432",
            user="postgres",
            password="1234",
            database="postgres"
        )
        
        print("SUCCESS: Successfully connected to PostgreSQL!")
        
        # Test if we can execute a simple query
        cursor = conn.cursor()
        cursor.execute("SELECT version();")
        version = cursor.fetchone()
        print(f"PostgreSQL version: {version[0]}")
        
        # Check if app_db exists
        cursor.execute("SELECT 1 FROM pg_database WHERE datname = 'app_db';")
        exists = cursor.fetchone()
        
        if exists:
            print("SUCCESS: Database 'app_db' already exists!")
        else:
            print("INFO: Database 'app_db' does not exist yet.")
        
        cursor.close()
        conn.close()
        
        print("SUCCESS: Connection test completed successfully!")
        
    except psycopg2.OperationalError as e:
        print(f"ERROR: Connection failed: {e}")
        print("Please check:")
        print("1. PostgreSQL is running")
        print("2. Connection details are correct")
        print("3. PostgreSQL accepts connections from localhost")
    except Exception as e:
        print(f"ERROR: Unexpected error: {e}")

if __name__ == "__main__":
    test_postgres_connection()
