import json
import boto3
from pprint import pprint

ecs = boto3.client('ecs')
ssm = boto3.client('ssm')

def handler(event, context):
    pprint("Received event: " + json.dumps(event, indent=2))

    config = ssm.get_parameter(Name='/terraform/provisioning/environment-vars',WithDecryption=True)["Parameter"]["Value"]
    config = json.loads(config)

    payload = json.loads(event["Records"][0]["body"])
    project = payload["project"]

    ecs.run_task(
        cluster='tf-provisioning',
        count=1,
        enableECSManagedTags=True,
        launchType='FARGATE',
        networkConfiguration={
            'awsvpcConfiguration': {
                'subnets': config["projects"][project]["subnets"],
                'securityGroups': config["projects"][project]["security_groups"],
                'assignPublicIp': 'ENABLED'
            }
        },
        overrides={
            'containerOverrides': [
                {
                    'name': 'tf-deployment-task',
                    'environment': [
                        {
                            'name': 'AWS_ACCESS_KEY_ID',
                            'value': config["projects"][project]["AWS_ACCESS_KEY_ID"]
                        },
                        {
                            'name': 'AWS_SECRET_ACCESS_KEY',
                            'value': config["projects"][project]["AWS_SECRET_ACCESS_KEY"]
                        },
                        {
                            'name': 'COMMAND',
                            'value': payload["command"]
                        },
                        {
                            'name': 'PROJECT',
                            'value': project
                        },
                        {
                            'name': 'PROJECT_CONFIG',
                            'value': json.dumps(payload["project_config"])
                        },
                    ]
                },
            ]
        },
        taskDefinition='tf-deployment-task-def'
    )