#!/bin/bash

echo "Running ECS task for terraform commands"

echo "Pulling git repo for given resource"
git clone https://github.com/${GIT_ORG}/${GIT_REPO}.git

cd ${GIT_REPO}

echo "Creating terraform project config"
echo ${RESOURCE_CONFIG} > terraform.tfvars.json
cat terraform.tfvars.json

# TODO: This is not working, fix this by adding git config and ssh key
echo "Updating Github repo with latest TF input config/vars"
git add terraform.tfvars.json
git commit -m "Updating Terraform varibales with latest config"
git push origin main

# TODO: Run this from Github action
echo "Terraform init and apply"
terraform init --backend-config="bucket=${BACKEND_BUCKET}" --backend-config="key=${BACKEND_S3_KEY}"
if (( ${COMMAND} == "apply" ))
then
    terraform ${COMMAND} -auto-approve
fi
