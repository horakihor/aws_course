This is a demo Python app
=========================

The main idea to start this application on EC2 instances and test different AWS services based on it.

# Setup Application Locally

Prerequisite
------------

MacOS:
* Python3
* Xcode
* PostgreSQL (https://postgresapp.com/)
* PostgreSQL libs
    brew install postgresql

Start Application
-----------------
    cd app
    make setup
    make run POSTGRES_URL="localhost:5432"

Init DB
-------
    http://localhost/init


Check App Status
----------------
    http://localhost

# Setup Application EC2 - Manually

Prerequisite
------------
    sudo yum -y group install "Development Tools"
    sudo yum -y install python3 python3-devel git

Setup PostgreSQL
------------
    sudo yum -y install postgresql-server postgresql-contrib postgresql postgresql-devel
    sudo postgresql-setup initdb
    sudo sed -i 's/peer/trust/g' /var/lib/pgsql/data/pg_hba.conf
    sudo sed -i 's/ident/trust/g' /var/lib/pgsql/data/pg_hba.conf
    sudo systemctl start postgresql && sudo systemctl enable postgresql

Start Application
------------
    sudo git clone https://github.com/horakihor/aws_course.git /opt/aws_course
    cd /opt/aws_course/app/
    sudo make setup
    sudo make run POSTGRES_URL="localhost:5432"

# Setup Application EC2 - User Data

We have 2 options to setup app with user-data:
- Local-DB (Setup local PostgreSQL)
- RDS-DB (Setup Application only)

Put one of the scripts to the User-data field in AWS.

Notes: Change RDS server hostname in user-data script before running.
