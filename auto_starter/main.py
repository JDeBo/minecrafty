import boto3
import os
import json

region = 'us-east-2'
instances = list(json.loads((os.environ['EC2_INSTANCES'])).values())
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    query = event['rawQueryString'].split("=")
    key = query[0]
    value = query[1]
    if key != "pwd":
        return {
            'statusCode': 401,
            'body': json.dumps('No Good')
        }
    if value == str(os.environ['PSWD']):
        ec2.start_instances(InstanceIds=instances)
        return {
            'statusCode': 200,
            'body': json.dumps('started your instance')
        }
    if value == str(os.environ['PSWD']) + 'stop':
        ec2.stop_instances(InstanceIds=instances)
        return {
            'statusCode': 200,
            'body': json.dumps('stopped your instance')
        }
    return {
        'statusCode': 403,
        'body': json.dumps('Definitely not')
    }