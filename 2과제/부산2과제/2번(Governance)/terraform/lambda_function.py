import boto3
import json
import datetime
import os
import time
import base64
import gzip
import io

def lambda_handler(event, context):
    logs = boto3.client('logs')
    encoded_data = event['awslogs']['data']
    decoded_data = base64.b64decode(encoded_data)
    
    with gzip.GzipFile(fileobj=io.BytesIO(decoded_data)) as f:
        decompressed_data = f.read()
    
    data = json.loads(decompressed_data.decode('utf-8'))
    logs_events = data['logEvents']
    for event in logs_events:
        logs.put_log_events(
                logGroupName='wsi-project-login',
                logStreamName='wsi-project-login-stream',
                logEvents=[
                    {
                        'timestamp': int(datetime.datetime.now().timestamp() * 1000),
                        'message': "{ USER: wsi-project-user has logged in! }"
                    },
                ],
            )
    
