#!/bin/bash

# Setup Global
sudo yum -y group install "Development Tools"

# Setup CloudWatch Logs
sudo yum -y install https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws_course/cloudwatch/cloudwatch-logs.json -s

# Setup App
sudo yum install -y python3 python3-devel git postgresql-devel
sudo git clone https://github.com/horakihor/aws_course.git /opt/aws_course && \
cd /opt/aws_course/app/ && \
sudo make setup && \
sudo make run POSTGRES_URL="<RDS-HOSTNAME>:5432"
