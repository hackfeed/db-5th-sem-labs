import os
import time

from psycopg2 import connect, OperationalError

conn = None
while not conn:
    try:
        conn = connect(
            dbname=os.getenv("POSTGRES_DB"),
            user=os.getenv("POSTGRES_USER"),
            host="db",
            password=os.getenv("POSTGRES_PASSWORD")
        )
    except OperationalError:
        print(f"{os.getenv('POSTGRES_DB')} is not available, waiting 1 second...")
        time.sleep(1)

print(f"{os.getenv('POSTGRES_DB')} is available now, connected")

cursor = conn.cursor()
cursor.execute("CREATE TABLE test (id serial PRIMARY KEY, num integer, data varchar);")
cursor.execute("INSERT INTO test (num, data) VALUES (%s, %s)", (100, "abc'def"))
cursor.execute("SELECT * FROM test;")
print(cursor.fetchall())

conn.commit()
cursor.close()
conn.close()
