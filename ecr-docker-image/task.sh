#!/bin/bash

echo "Running ECS task for terraform commands"

echo "Pulling git repo for given project"
git clone https://github.com/${PROJECT}.git

PROJECT_DIR=$(echo ${PROJECT} | cut -d "/" -f 2)
cd ${PROJECT_DIR}

echo "Creating terraform project config"
echo ${PROJECT_CONFIG} > terraform.tfvars.json
cat terraform.tfvars.json

# TODO: This is not working, fix this by adding git config and ssh key
echo "Updating Github repo with latest TF input config/vars"
git add terraform.tfvars.json
git commit -m "Updating Terraform varibales with latest config"
git push origin main

# TODO: Run this from Github action
echo "Terraform init and apply"
terraform init --backend-config="bucket=${BACKEND_BUCKET}" --backend-config="key=${PROJECT}/terraform.tfstate"
if (( ${COMMAND} == "apply" ))
then
    terraform ${COMMAND} -auto-approve
fi
