""" Database operations. """

import time

import psycopg2


def connect_to_db(dbname, user, host, password):
    """ Establish the connection to PostgreSQL. """

    conn = None
    while not conn:
        try:
            conn = psycopg2.connect(
                dbname=dbname,
                user=user,
                host=host,
                password=password
            )
        except psycopg2.OperationalError:
            time.sleep(1)

    return conn


def execute_query(conn, query):
    """ Execute SQL-query. """

    query_success = True
    query_result = None

    cursor = conn.cursor()
    try:
        cursor.execute(query)
    except:
        query_success = False
        conn.rollback()
        cursor.close()

        return query_success, query_result

    if query.lower().startswith("select"):
        query_result = cursor.fetchall()
    conn.commit()
    cursor.close()

    return query_success, query_result
