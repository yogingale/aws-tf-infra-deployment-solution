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
