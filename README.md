This is a demo Python app
=========================

The main idea to start this application on EC2 instances and test different AWS services based on it.

# Setup Application

Prerequisite
------------

MacOS:
* Python3
* Xcode
* PostgreSQL (https://postgresapp.com/)

Start Application
-----------------
    cd app
    make setup
    make run POSTGRES_URL="localhost:5432"

Init DB
-------
    http://localhost/init
