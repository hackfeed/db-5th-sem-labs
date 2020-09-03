# Database Course Environment
# Made by Sergey @hackfeed Kononenko, ICS7-53B, 2020

FROM python:3.8-alpine
LABEL maintainer="Sergey @hackfeed Kononenko"

ENV PYTHONBUFFERED 1

RUN apk add --update --no-cache postgresql-client
RUN apk add --update --no-cache --virtual .tmp-build-deps \
    gcc postgresql-dev musl-dev

COPY ./requirements.txt /requirements.txt
RUN python -m pip install -r /requirements.txt

RUN apk del .tmp-build-deps

RUN mkdir /app
WORKDIR /app

RUN adduser -D hackfeed
USER hackfeed
