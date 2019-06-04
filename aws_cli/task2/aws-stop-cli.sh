set -x

vpc=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=prod" --query 'Vpcs[0].VpcId' --output text)

aws rds delete-db-instance --db-instance-identifier prod --skip-final-snapshot

aws autoscaling delete-auto-scaling-group --auto-scaling-group-name web --force-delete
aws autoscaling delete-launch-configuration --launch-configuration-name web

aws rds wait db-instance-deleted --db-instance-identifier prod

aws rds delete-db-subnet-group --db-subnet-group-name prod

nat_id=$(aws ec2 describe-nat-gateways --filter "Name='tag:Name',Values='prod'" "Name=vpc-id,Values=${vpc}" --query 'NatGateways[0].NatGatewayId' --output text)

aws ec2 delete-nat-gateway --nat-gateway-id ${nat_id}

aws ec2 wait nat-gateway-available --filter "Name='state',Values='deleted'" "Name=vpc-id,Values=${vpc}" --nat-gateway-ids ${nat_id}

elb=$(aws elbv2 describe-load-balancers --names web --query 'LoadBalancers[0].LoadBalancerArn' --output text)

aws elbv2 delete-load-balancer --load-balancer-arn $elb

tg=$(aws elbv2 describe-target-groups --names web --query 'TargetGroups[0].TargetGroupArn' --output text)

aws elbv2 delete-target-group --target-group-arn $tg

ip=$(aws ec2 describe-addresses --filters "Name=tag:Name,Values=Nat" --query 'Addresses[0].AllocationId' --output text)

aws ec2 release-address --allocation-id $ip

# Delete subnets
for i in `aws ec2 describe-subnets --filters Name=vpc-id,Values="${vpc}" --query 'Subnets[*].SubnetId' --output text`; do aws ec2 delete-subnet --subnet-id=$i; done

# Detach and Delete internet gateways
for i in `aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values="${vpc}" --query 'InternetGateways[*].InternetGatewayId' --output text`; do aws ec2 detach-internet-gateway --internet-gateway-id=$i --vpc-id=$vpc; aws ec2 delete-internet-gateway --internet-gateway-id=$i; done

db_sg=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=db" --query 'SecurityGroups[0].GroupId' --output text)
web_sg=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=web" --query 'SecurityGroups[0].GroupId' --output text)

aws ec2 revoke-security-group-ingress --group-id ${db_sg} --protocol tcp --port 5432 --source-group ${web_sg}

# Delete security groups
for i in $db_sg $web_sg ; do aws ec2 delete-security-group --group-id $i; sleep 2; done

for i in `aws ec2 describe-route-tables --filters Name=vpc-id,Values="${vpc}" --query 'RouteTables[*].RouteTableId' --output text`; do aws ec2 delete-route-table --route-table-id $i; done

aws ec2 delete-vpc --vpc-id $vpc
