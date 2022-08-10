import json
import boto3
from pprint import pprint

ecs = boto3.client('ecs')
ssm = boto3.client('ssm')

def get_resource_config(type, config, app_config, app_env):
    """Get resource config based on resource type."""
    resource_config = config["config"]
    if type == "s3":
        return resource_config
    elif type == "ec2":
        app_os = resource_config["os"]
        return {
            "ami":app_config["ami"][app_os],
            "instance_type":resource_config["instance_type"],
            "security_group":app_config["security_groups"][0],
            "subnet_id":app_config["subnets"][0],
            "resource_tags":{
                "Name": resource_config["name"],
                "environment":app_env
            }
        }


def handler(event, context):
    pprint("Received event: " + json.dumps(event, indent=2))

    config = ssm.get_parameter(Name='/terraform/provisioning/environment-vars',WithDecryption=True)["Parameter"]["Value"]
    config = json.loads(config)

    payload = json.loads(event["Records"][0]["body"])
    projects = payload["projects"]

    for project in projects:
        app_name = project["application_name"]
        app_env = project["application_env"]
        resources = project["resources"]
        project_name = f"{app_name}-{app_env}"
        app_config = config["projects"][project_name]

        for resource in resources:
            provider = resource['provider']
            resource_type = resource['resource_type']
            id = resource["id"]

            git_repo = f"{provider}-{resource_type}-terraform"
            git_org = app_config["git_org"]

            backend_s3_key = f"{app_name}-{app_env}-{resource_type}-{id}/terraform.tfstate"
            resource_config = get_resource_config(resource_type, resource, app_config, app_env)

            ecs.run_task(
                cluster='tf-provisioning',
                count=1,
                enableECSManagedTags=True,
                launchType='FARGATE',
                networkConfiguration={
                    'awsvpcConfiguration': {
                        'subnets': app_config["subnets"],
                        'securityGroups': app_config["security_groups"],
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
                                    'value': app_config["AWS_ACCESS_KEY_ID"]
                                },
                                {
                                    'name': 'AWS_SECRET_ACCESS_KEY',
                                    'value': app_config["AWS_SECRET_ACCESS_KEY"]
                                },
                                {
                                    'name': 'COMMAND',
                                    'value': "apply"
                                },
                                {
                                    'name': 'PROJECT',
                                    'value': project_name
                                },
                                {
                                    'name': 'BACKEND_BUCKET',
                                    'value': app_config["s3_backend_bucket"]
                                },
                                {
                                    'name': 'BACKEND_S3_KEY',
                                    'value': backend_s3_key
                                },
                                {
                                    'name': 'RESOURCE_CONFIG',
                                    'value': json.dumps(resource_config)
                                },
                                {
                                    'name': 'GIT_ORG',
                                    'value': git_org
                                },
                                {
                                    'name': 'GIT_REPO',
                                    'value': git_repo
                                },
                            ]
                        },
                    ]
                },
                taskDefinition='tf-deployment-task-def'
            )
