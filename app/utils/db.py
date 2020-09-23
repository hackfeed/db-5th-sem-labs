""" Database operations. """

import time

import psycopg2
from tabulate import tabulate


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


def pretty_query(cursor, query):
    """ Return pretty format for psycopg2 query fetch. """

    return tabulate(query, headers=[desc[0] for desc in cursor.description], tablefmt="psql")


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
        query_result = pretty_query(cursor, cursor.fetchall())

    conn.commit()
    cursor.close()

    return query_success, query_result
