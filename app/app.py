import os

from psycopg2 import connect

conn = connect(
    dbname=os.getenv("POSTGRES_DB"),
    user=os.getenv("POSTGRES_USER"),
    host="db",
    password=os.getenv("POSTGRES_PASSWORD")
)

cursor = conn.cursor()
cursor.execute("CREATE TABLE test (id serial PRIMARY KEY, num integer, data varchar);")
cursor.execute("INSERT INTO test (num, data) VALUES (%s, %s)", (100, "abc'def"))
cursor.execute("SELECT * FROM test;")
print(cursor.fetchall())

conn.commit()
cursor.close()
conn.close()
