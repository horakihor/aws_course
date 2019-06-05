This is a demo Python app
=========================

The main idea to start this application on EC2 instances and test different AWS services based on it.

Architecture Diagram
-------------------

![Alt text](diagrams/architecture.png?raw=true "Architecture Diagram")

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

We have a few options to setup app with user-data:
- Local-DB (Setup local PostgreSQL)
- RDS-DB (Setup Application only)
- RDS-CloudWatch (Setup Application + CloudWatch Agent)

Put one of the scripts to the User-data field in AWS.

Notes: Change RDS server hostname in user-data script before running.

# Tips
Connect to private network with Bastion host
--------------------------------------------
    ssh-agent
    ssh-add <key-name>.pem
    ssh -A ec2-user@<public-ip of bastion>
    ssh <private ip of web server>
    
 Setup CloudWatch logs manully
 -----------------------------
    sudo yum -y install https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws_course/cloudwatch/cloudwatch-logs.json -s
