#!/bin/bash

echo "running ECS task for terraform commands"

cd ${PROJECT}

terraform init

if (( ${COMMAND} == "apply" ))
then
    terraform ${COMMAND} -auto-approve
fi
