import json
import boto3

client = boto3.client('ecs')

def handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))