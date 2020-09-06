import os
import sys
import time

import psycopg2


def connect_to_postgres(dbname, user, host, password):
    postgres = None
    while not postgres:
        try:
            postgres = psycopg2.connect(
                dbname=dbname,
                user=user,
                host=host,
                password=password
            )
        except psycopg2.OperationalError:
            time.sleep(1)

    return postgres


def execute_query(postgres, query):
    query_success = True
    query_result = None

    cursor = postgres.cursor()
    try:
        cursor.execute(query)
    except:
        query_success = False
        postgres.rollback()
        cursor.close()

        return query_success, query_result

    if query.lower().startswith("select"):
        query_result = cursor.fetchall()
    postgres.commit()
    cursor.close()

    return query_success, query_result
