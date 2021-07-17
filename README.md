## Steps

### Docker
#### Pre-requisits
Install Docker and make sure Docker daemon is running.

#### steps
You'll find these steps on your ECR repository (tf-task)
* aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <your-account-number>.dkr.ecr.us-east-1.amazonaws.com
* docker build -t tf-task .
* docker tag tf-task:latest <your-account-number>.dkr.ecr.us-east-1.amazonaws.com/tf-task:latest
* docker push <your-account-number>.dkr.ecr.us-east-1.amazonaws.com/tf-task:latest

### Terraform

#### Pre-requisits
confifure `~/.aws/credentials`

#### steps
* Add your lambda function code in `lambda.py`
* run `zip lambda lambda.py`
* run `terraform init`
* run `terraform plan`
* run `terraform apply`


#TODO:
 - Create github repo - Done
 - Create Lambda, SQS, SQS to lambda event config and ECR repo using TF - Done
 - Create ECR image for DockerFile - Done
 - Create VPC, Subnet, InternetGateway and attach it to VPC, RouteTable and it's Route, SubnetRouteTableAssociation and SecurityGroup
 - Create ECS cluster and task definition
 - Trigger ECS task from SQS -> Lambda function
 - Test end to end flow
 - Add Arch diagram
