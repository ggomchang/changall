import boto3
import json
import datetime
import os
import time

def lambda_handler(event, context):

    security_group_id = os.environ['SECURITY_GROUP_ID']
    instance_id = os.environ['INSTANCE_ID']

    ec2 = boto3.resource('ec2')
    logs = boto3.client('logs')
    config = boto3.client('config')
    
    security_group = ec2.SecurityGroup(security_group_id)
    
    non_compliant = False  # 미준수 여부 초기화
    
    # 인바운드 포트 삭제
    for permission in security_group.ip_permissions:
        if permission['FromPort'] not in [80, 22]:
            security_group.revoke_ingress(IpPermissions=[permission])
            log_event(logs, instance_id, f"Inbound {permission['FromPort']} Deleted Port!")
            non_compliant = False
    
    # 아웃바운드 포트 삭제
    for permission in security_group.ip_permissions_egress:
        if permission['FromPort'] not in [80, 22, 443]:
            security_group.revoke_egress(IpPermissions=[permission])
            log_event(logs, instance_id, f"Outbound {permission['FromPort']} Deleted Port!")
            non_compliant = False
    
    # AWS Config 룰 준수 여부 기록
    if non_compliant:
        compliance_type = 'NON_COMPLIANT'
    else:
        compliance_type = 'COMPLIANT'
    
    invoking_event = json.loads(event['invokingEvent'])
    invoking_event['configurationItem']['configurationItemCaptureTime']
    
    config.put_evaluations(
        Evaluations=[
            {
                'ComplianceResourceType': 'AWS::EC2::SecurityGroup',
                'ComplianceResourceId': security_group_id,
                'ComplianceType': compliance_type,
                'Annotation': 'delete port',
                'OrderingTimestamp': invoking_event['configurationItem']['configurationItemCaptureTime']
            },
        ],
        ResultToken=event['resultToken']
    )
    
    return ''

def log_event(logs_client, instance_id, message):
    logs_client.put_log_events(
        logGroupName='/ec2/deny/port',
        logStreamName=f'deny-{instance_id}',
        logEvents=[
            {
                'timestamp': int(datetime.datetime.now().timestamp() * 1000),
                'message': f"{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} {message}"
            },
        ],
    )
