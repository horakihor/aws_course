#!/bin/bash

# Setup Global
sudo yum -y group install "Development Tools"

# Setup Postgres
sudo yum -y install postgresql-server postgresql-contrib postgresql postgresql-devel
sudo postgresql-setup initdb
sudo sed -i 's/peer/trust/g' /var/lib/pgsql/data/pg_hba.conf
sudo systemctl start postgresql && sudo systemctl enable postgresql

# Setup App
sudo yum install -y python3 python3-devel git
sudo git clone https://github.com/horakihor/aws_course.git /opt/aws_course && \
cd /opt/aws_course/app/ && \
sudo make setup && \
sudo make run POSTGRES_URL="localhost:5432"
