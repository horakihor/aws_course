#!/bin/bash

# Setup Global
sudo yum -y group install Development Tools

# Setup App
sudo yum install -y python3 python3-devel git postgresql-devel
sudo git clone https://github.com/horakihor/aws_course.git /opt/aws_course && cd /opt/aws_course/app/ && sudo make setup && sudo make run POSTGRES_URL=prod.cjv1hjeb2tln.us-east-1.rds.amazonaws.com:5432

