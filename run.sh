#!/bin/bash

cd /rustdesk-api-server;

if [ ! -e "./db/db.sqlite3" ]; then
    cp "./db_bak/db.sqlite3" "./db/db.sqlite3"
    echo "First run, initialize the database"
fi

python manage.py runserver $HOST:21114;
