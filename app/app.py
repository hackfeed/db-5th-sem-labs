""" Flask Web-application for Database Course, ICS7, 2020. """

import os

from flask import Flask, render_template, request, g

from utils import db

app = Flask(__name__)


@app.before_request
def before_request():
    """ Establish the connection to PostgreSQL before request. """
    postgres = db.connect_to_db(
        os.getenv("POSTGRES_DB"),
        os.getenv("POSTGRES_USER"),
        "db",
        os.getenv("POSTGRES_PASSWORD")
    )
    g.db = postgres


@app.after_request
def after_request(response):
    """ Close the connection to PostgreSQL before request. """
    if g.db is not None:
        g.db.close()

    return response


@app.route("/")
def get_index():
    """ GET Index page. """
    return render_template(
        "index.html",
        message="Enter the SQL-query",
        query="",
        result=""
    )


@app.route("/query", methods=["POST"])
def post_query():
    """ POST query to execute. """
    query = request.form["query"]
    query_success, query_result, query_message = db.execute_query(g.db, query)

    if not query_success:
        return render_template(
            "index.html",
            message="Bad SQL-query, try again",
            query=query,
            result=query_message
        )

    query_result = "" if query_result is None else query_result

    return render_template(
        "index.html",
        message="SQL-query executed successfully",
        query=query,
        result=query_result
    )


@app.errorhandler(404)
def page_not_found(error):
    """ GET error page. """
    return render_template("error.html", error=error), 404


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
