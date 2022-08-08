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
   "projects":{
      "yogingale/tf-sample-project-1": {
         "AWS_ACCESS_KEY_ID":"",
         "AWS_SECRET_ACCESS_KEY":"",
         "name":"tf-sample-project-1",
         "security_groups":[
            ""
         ],
         "subnets":[
            ""
         ],
         "s3_backend_bucket": "Name of s3 bucket used for backend (Check s3-backend.tf)"
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
   "project":"yogingale/tf-sample-project-1",
   "command":"apply",
   "project_config":{
      "aws_region":"us-east-1",
      "bucket_name":"my-tf-test-bucket-using-ecs-task",
      "acl":"private"
   }
}
```
- `project`: Name of project
- `command`: Terraform command 
- `project_config`: Terraform config to be passed as variables