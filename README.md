## Steps

### Docker


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
 - Create ECR image for DockerFile
 - Trigger ECS task from SQS -> Lambda function
 - Test end to end flow
 - Add Arch diagram
