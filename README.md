## Architecture 
 
![arch](static/images/arch.jpg?raw=true "Architecture")

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
- Configure `~/.aws/credentials`.
- Add below per project configurations in SSM parameter store (/terraform/provisioning/environment-vars)
```
{
   "projects":{
      "AWS_ACCESS_KEY_ID":"",
      "AWS_SECRET_ACCESS_KEY":"",
      "name":"project-1",
      "security_groups":[
         ""
      ],
      "subnets":[
         ""
      ]
   }
}
```

#### Deployment steps
* Add your lambda function code in `lambda.py`
* run `zip lambda lambda.py`
* run `terraform init`
* run `terraform plan`
* run `terraform apply`

### Usage
* Terraform apply for project-1:
Add below message in SQS queue to trigger terraform apply for project-1
```
{"project":"project-1","command":"apply"}
```

#TODO:
 - Create github repo - Done
 - Create Lambda, SQS, SQS to lambda event config and ECR repo using TF - Done
 - Create ECR image for DockerFile - Done
 - Create VPC, Subnet, InternetGateway and attach it to VPC, RouteTable and it's Route, SubnetRouteTableAssociation and SecurityGroup - Done
 - Create ECS cluster and task definition - Done
 - Trigger ECS task from SQS -> Lambda function - Done
 - Test end to end flow - Done
 - Add Arch diagram - Done
