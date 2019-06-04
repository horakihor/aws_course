#############
# Variables #
#############

set -x

region=us-east-1
vpc_cidr=172.21.0.0/16
instance_ami="ami-0c6b1d09930fac512"
###################
# VPC and subnets #
###################

# VPC

vpc_id=$(aws ec2 create-vpc \
--cidr-block ${vpc_cidr} \
--region ${region} \
--query 'Vpc.VpcId' \
--output text )

aws ec2 create-tags --resources ${vpc_id} --tags "Key=Name,Value=prod" --region ${region}

# Subnets

private_1_subnet=$(aws ec2 create-subnet \
--vpc-id ${vpc_id} \
--cidr-block 172.21.1.0/24 \
--availability-zone ${region}a \
--region ${region} \
--query 'Subnet.SubnetId' \
--output text )

aws ec2 create-tags --resources ${private_1_subnet} --tags "Key=Name,Value=private_1" --region ${region}

private_2_subnet=$(aws ec2 create-subnet \
--vpc-id ${vpc_id} \
--cidr-block 172.21.2.0/24 \
--availability-zone ${region}b \
--region ${region} \
--query 'Subnet.SubnetId' \
--output text )

aws ec2 create-tags --resources ${private_2_subnet} --tags "Key=Name,Value=private_2" --region ${region}

public_1_subnet=$(aws ec2 create-subnet \
--vpc-id ${vpc_id} \
--cidr-block 172.21.3.0/24 \
--availability-zone ${region}a \
--region ${region} \
--query 'Subnet.SubnetId' \
--output text )

aws ec2 create-tags --resources ${public_1_subnet} --tags "Key=Name,Value=public_1" --region ${region}

public_2_subnet=$(aws ec2 create-subnet \
--vpc-id ${vpc_id} \
--cidr-block 172.21.4.0/24 \
--availability-zone ${region}b \
--region ${region} \
--query 'Subnet.SubnetId' \
--output text )

aws ec2 create-tags --resources ${public_2_subnet} --tags "Key=Name,Value=public_2" --region ${region}

db_1_subnet=$(aws ec2 create-subnet \
--vpc-id ${vpc_id} \
--cidr-block 172.21.5.0/24 \
--availability-zone ${region}a \
--region ${region} \
--query 'Subnet.SubnetId' \
--output text )

aws ec2 create-tags --resources ${db_1_subnet} --tags "Key=Name,Value=db_1" --region ${region}

db_2_subnet=$(aws ec2 create-subnet \
--vpc-id ${vpc_id} \
--cidr-block 172.21.6.0/24 \
--availability-zone ${region}b \
--region ${region} \
--query 'Subnet.SubnetId' \
--output text )

aws ec2 create-tags --resources ${db_2_subnet} --tags "Key=Name,Value=db_2" --region ${region}

#Route tables

route_table_private=$(aws ec2 create-route-table \
--vpc-id ${vpc_id} \
--region ${region} \
--query 'RouteTable.RouteTableId' \
--output text )

aws ec2 create-tags --resources ${route_table_private} --tags "Key=Name,Value=private" --region ${region}

route_table_public=$(aws ec2 create-route-table \
--vpc-id ${vpc_id} \
--region ${region} \
--query 'RouteTable.RouteTableId' \
--output text )

aws ec2 create-tags --resources ${route_table_public} --tags "Key=Name,Value=public" --region ${region}

aws ec2 associate-route-table  --subnet-id ${private_1_subnet} --route-table-id ${route_table_private} --region ${region}
aws ec2 associate-route-table  --subnet-id ${private_2_subnet} --route-table-id ${route_table_private} --region ${region}
aws ec2 associate-route-table  --subnet-id ${db_1_subnet} --route-table-id ${route_table_private} --region ${region}
aws ec2 associate-route-table  --subnet-id ${db_2_subnet} --route-table-id ${route_table_private} --region ${region}
aws ec2 associate-route-table  --subnet-id ${public_1_subnet} --route-table-id ${route_table_public} --region ${region}
aws ec2 associate-route-table  --subnet-id ${public_2_subnet} --route-table-id ${route_table_public} --region ${region}

#Internet Gateway

internet_gateway=$(aws ec2 create-internet-gateway \
--region ${region} \
--query 'InternetGateway.InternetGatewayId' \
--output text )

aws ec2 attach-internet-gateway --vpc-id ${vpc_id} --internet-gateway-id ${internet_gateway} --region ${region}
aws ec2 create-route --route-table-id ${route_table_public} --destination-cidr-block 0.0.0.0/0 --gateway-id ${internet_gateway} --region ${region}

#NAT Gateway

elastic_ip=$(aws ec2 allocate-address \
--domain vpc \
--region ${region} \
--query 'AllocationId' \
--output text )

aws ec2 create-tags --resources ${elastic_ip} --tags "Key=Name,Value=Nat" --region ${region}

nat_gateway=$(aws ec2 create-nat-gateway \
--subnet-id ${public_1_subnet} \
--allocation-id ${elastic_ip} \
--region ${region} \
--query 'NatGateway.NatGatewayId' \
--output text )

aws ec2 create-tags --resources ${nat_gateway} --tags "Key=Name,Value=prod" --region ${region}

aws ec2 wait nat-gateway-available --nat-gateway-ids ${nat_gateway}
aws ec2 create-route --route-table-id ${route_table_private} --destination-cidr-block 0.0.0.0/0 --nat-gateway-id ${nat_gateway} --region ${region}

# Subnet groups and Securtity groups
rds_subnet_group=$(aws rds create-db-subnet-group \
--db-subnet-group-name prod \
--db-subnet-group-description prod \
--subnet-ids ${db_1_subnet} ${db_2_subnet} \
--region ${region} \
--query 'DBSubnetGroup.DBSubnetGroupName' \
--output text )

web_security_group=$(aws ec2 create-security-group \
--group-name web \
--description "web" \
--vpc-id ${vpc_id} \
--region ${region} \
--query 'GroupId' \
--output text )

db_security_group=$(aws ec2 create-security-group \
--group-name db \
--description "db" \
--vpc-id ${vpc_id} \
--region ${region} \
--query 'GroupId' \
--output text )

aws ec2 authorize-security-group-ingress --group-id ${web_security_group} --protocol tcp --port 80 --cidr 0.0.0.0/0 --region ${region}
aws ec2 authorize-security-group-ingress --group-id ${web_security_group} --protocol tcp --port 22 --cidr 0.0.0.0/0 --region ${region}
aws ec2 authorize-security-group-ingress --group-id ${db_security_group} --protocol tcp --port 5432 --source-group ${web_security_group} --region ${region}

# RDS

rds_db=$(aws rds create-db-instance \
  --db-name prod \
  --db-instance-identifier prod \
  --allocated-storage 20 \
  --db-instance-class db.t2.micro \
  --engine postgres \
  --master-username postgres \
  --master-user-password postgres \
  --db-subnet-group-name prod \
  --no-publicly-accessible \
  --region ${region} \
  --vpc-security-group-ids ${db_security_group} \
  --query 'DBInstance.{DBInstanceIdentifier:DBInstanceIdentifier}' \
  --output text)

aws rds wait db-instance-available --db-instance-identifier ${rds_db}

# EC2

# Create userdata

db_hostname=$(aws rds describe-db-instances \
--db-instance-identifier ${rds_db} \
--query 'DBInstances[0].Endpoint.Address' \
--output text )

echo "#!/bin/bash

# Setup Global
sudo yum -y group install "Development Tools"

# Setup App
sudo yum install -y python3 python3-devel git postgresql-devel
sudo git clone https://github.com/horakihor/aws_course.git /opt/aws_course && \
cd /opt/aws_course/app/ && \
sudo make setup && \
sudo make run POSTGRES_URL="${db_hostname}:5432"
" > userdata.sh

# Create web servers

web1=$(aws ec2 run-instances \
--image-id ${instance_ami} \
--count 1 \
--instance-type t2.micro \
--security-group-ids ${web_security_group} \
--subnet-id ${private_1_subnet} \
--user-data file://userdata.sh \
--region ${region} \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-1}]' \
--query 'Instances[0].InstanceId' \
--output text )

web2=$(aws ec2 run-instances \
--image-id ${instance_ami} \
--count 1 \
--instance-type t2.micro \
--security-group-ids ${web_security_group} \
--subnet-id ${private_1_subnet} \
--user-data file://userdata.sh \
--region ${region} \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web-2}]' \
--query 'Instances[0].InstanceId' \
--output text )

aws ec2 wait instance-status-ok --instance-ids ${web1}
aws ec2 wait instance-status-ok --instance-ids ${web2}

#TargetGroups and ELB

target_group=$(aws elbv2 create-target-group \
--vpc-id ${vpc_id} \
--name web \
--port 80 \
--protocol HTTP \
--region ${region} \
--query 'TargetGroups[0].TargetGroupArn' \
--output text )

aws elbv2 register-targets --target-group-arn ${target_group} --targets Id=$web1 Id=$web2

elb=$(aws elbv2 create-load-balancer \
--name web \
--region ${region} \
--security-groups ${web_security_group} \
--query 'LoadBalancers[0].LoadBalancerArn' \
--output text \
--subnets ${public_1_subnet} ${public_2_subnet})

aws elbv2 create-listener --load-balancer-arn ${elb} \
--protocol HTTP \
--region ${region} \
--port 80  \
--default-actions Type=forward,TargetGroupArn=${target_group}
