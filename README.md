## Architecture

![arch](static/images/arch.jpg?raw=true "Architecture")

- [Installation Steps](#installation-steps)
  - [Terraform](#terraform)
    - [TF Pre-requisits](#tf-pre-requisits)
    - [TF Deployment steps](#tf-deployment-steps)
  - [Docker](#docker)
    - [Docker Pre-requisits](#docker-pre-requisits)
    - [Docker Deployment steps](#docker-deployment-steps)
- [Usage](#usage)

## Installation Steps

### Terraform
#### TF Pre-requisits
- Configure `~/.aws/credentials`.
- Add below per project configurations in SSM parameter store (/terraform/provisioning/environment-vars)
```
{
   "projects": {
      "my-app-sdc-dev" : {
         "application_name": "my-app-sdc",
         "application_env": "dev",
         "git_org": "yogingale",
         "AWS_ACCESS_KEY_ID":"",
         "AWS_SECRET_ACCESS_KEY":"",
         "security_groups":[
            ""
         ],
         "subnets":[
            ""
         ],
         "ami":{
            "redhat8-linux": "ami-0238411fb452f8275",
            "windows19": "ami-05912b6333beaa478",
            "windows22": "ami-027f2f92dac883acf",
            "amazon-linux2": "ami-090fa75af13c156b4"
         }
      }
   }
}
```

#### TF Deployment steps
* Add your lambda function code in `lambda.py`
* run `zip lambda lambda.py`
* run `terraform init --backend-config="bucket=BACKEND-BUCKET-NAME"` (Add this bucket name from terraform.tfvars.json file and SSM)
* run `terraform plan`
* run `terraform apply`

### Docker
#### Docker Pre-requisits
Install Docker and make sure Docker daemon is running.

#### Docker Deployment steps
You'll find these steps on your ECR repository (`tf-task`)
* aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <your-account-number>.dkr.ecr.us-east-1.amazonaws.com
* docker build --platform=linux/amd64 -t tf-task .
* docker tag tf-task:latest <your-account-number>.dkr.ecr.us-east-1.amazonaws.com/tf-task:latest
* docker push <your-account-number>.dkr.ecr.us-east-1.amazonaws.com/tf-task:latest

## Usage
* Terraform apply for project-1:
Add below message in SQS queue to trigger terraform apply for project-1
```
{
   "projects":[
      {
         "application_name": "my-app-sdc",
         "application_env": "dev",
         "resources": [
            {
               "id": "123",
               "provider": "aws",
               "resource_type": "s3",
               "config": {
                  "aws_region":"us-east-1",
                  "bucket_name":"my-tf-test-bucket-using-ecs-task",
                  "acl":"private"
               }
            },
            {
               "id": "456",
               "provider": "aws",
               "resource_type": "ec2",
               "config": {
                  "name": "N-abc",
                  "os": "amazon-linux2",
                  "instance_type": "t1.micro"
               }
            }
         ]
      }
   ]
}

## Template terraform repos:
- s3: https://github.com/yogingale/aws-s3-terraform
- ec2: https://github.com/yogingale/aws-ec2-terraform
