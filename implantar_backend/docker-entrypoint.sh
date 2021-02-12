#!/bin/bash

echo "Makemigrations"
python manage.py makemigrations

echo "Apply database migrations"
python manage.py migrate

echo "Criando grupos"
python manage.py appconfig

echo "Starting server"
python manage.py runserver 0.0.0.0:8001