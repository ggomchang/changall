import boto3
import datetime
import json
import os

ec2 = boto3.client('ec2')
logs = boto3.client('logs')

instance_id = os.environ['INSTANCE_ID']

allowed_inbound_ports = [
    {'port': 22, 'source': '0.0.0.0/0'},
    {'port': 80, 'source': '0.0.0.0/0'},
    {'port': 3306, 'source': '0.0.0.0/0'}
]

allowed_outbound_ports = [
    {'port': 22, 'destination': '0.0.0.0/0'},
    {'port': 80, 'destination': '0.0.0.0/0'},
    {'port': 443, 'destination': '0.0.0.0/0'}
]

def log_to_cloudwatch(message):
    timestamp = int(datetime.datetime.now().timestamp() * 1000)
    logs.put_log_events(
        logGroupName='/seoul/ec2/deny/port',
        logStreamName='deny-aaaa',
        logEvents=[
            {
                'timestamp': timestamp,
                'message': message
            },
        ],
    )

def get_security_groups(instance_id):
    response = ec2.describe_instances(InstanceIds=[instance_id])
    security_groups = response['Reservations'][0]['Instances'][0]['SecurityGroups']
    return [sg['GroupId'] for sg in security_groups]

def revoke_security_group_rules(security_group_id):
    response = ec2.describe_security_groups(GroupIds=[security_group_id])
    security_group = response['SecurityGroups'][0]

    current_inbound_rules = []
    current_outbound_rules = []

    def get_ip_permission(ip):
        if '/' in ip:
            return {'CidrIp': ip}
        elif ip.startswith('sg-'):
            return {'SourceSecurityGroupId': ip}
        else:
            raise ValueError(f"Invalid IP or security group ID: {ip}")

    # Revoke Inbound Rules and gather existing ports
    for rule in security_group['IpPermissions']:
        from_port = rule.get('FromPort', -1)
        to_port = rule.get('ToPort', -1)
        protocol = rule.get('IpProtocol', 'tcp')
        ip_ranges = rule.get('IpRanges', [])
        user_id_group_pairs = rule.get('UserIdGroupPairs', [])

        for ip_range in ip_ranges:
            cidr_ip = ip_range.get('CidrIp')
            if protocol != '-1':
                if from_port == to_port:
                    current_inbound_rules.append({'port': from_port, 'source': cidr_ip})
                    if {'port': from_port, 'source': cidr_ip} not in allowed_inbound_ports:
                        ec2.revoke_security_group_ingress(
                            GroupId=security_group_id,
                            IpPermissions=[rule]
                        )
                        message = f"{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} Inbound {from_port} from {cidr_ip} Deleted!"
                        log_to_cloudwatch(message)
                else:
                    if {'port': -1, 'source': cidr_ip} not in allowed_inbound_ports:
                        ec2.revoke_security_group_ingress(
                            GroupId=security_group_id,
                            IpPermissions=[rule]
                        )
                        message = f"{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} Inbound All Traffic from {cidr_ip} Deleted!"
                        log_to_cloudwatch(message)
            else:
                current_inbound_rules.append({'port': -1, 'source': cidr_ip})

        for user_id_group_pair in user_id_group_pairs:
            sg_id = user_id_group_pair.get('GroupId')
            current_inbound_rules.append({'port': from_port, 'source': sg_id})
            if {'port': from_port, 'source': sg_id} not in allowed_inbound_ports:
                ec2.revoke_security_group_ingress(
                    GroupId=security_group_id,
                    IpPermissions=[rule]
                )
                message = f"{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} Inbound {from_port} from {sg_id} Deleted!"
                log_to_cloudwatch(message)

    # Revoke Outbound Rules and gather existing ports
    for rule in security_group['IpPermissionsEgress']:
        from_port = rule.get('FromPort', -1)
        to_port = rule.get('ToPort', -1)
        protocol = rule.get('IpProtocol', 'tcp')
        ip_ranges = rule.get('IpRanges', [])
        user_id_group_pairs = rule.get('UserIdGroupPairs', [])

        for ip_range in ip_ranges:
            cidr_ip = ip_range.get('CidrIp')
            if protocol != '-1':
                if from_port == to_port:
                    current_outbound_rules.append({'port': from_port, 'destination': cidr_ip})
                    if {'port': from_port, 'destination': cidr_ip} not in allowed_outbound_ports:
                        ec2.revoke_security_group_egress(
                            GroupId=security_group_id,
                            IpPermissions=[rule]
                        )
                        message = f"{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} Outbound {from_port} to {cidr_ip} Deleted!"
                        log_to_cloudwatch(message)
                else:
                    if {'port': -1, 'destination': cidr_ip} not in allowed_outbound_ports:
                        ec2.revoke_security_group_egress(
                            GroupId=security_group_id,
                            IpPermissions=[rule]
                        )
                        message = f"{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} Outbound All Traffic to {cidr_ip} Deleted!"
                        log_to_cloudwatch(message)
            else:
                current_outbound_rules.append({'port': -1, 'destination': cidr_ip})

        for user_id_group_pair in user_id_group_pairs:
            sg_id = user_id_group_pair.get('GroupId')
            current_outbound_rules.append({'port': from_port, 'destination': sg_id})
            if {'port': from_port, 'destination': sg_id} not in allowed_outbound_ports:
                ec2.revoke_security_group_egress(
                    GroupId=security_group_id,
                    IpPermissions=[rule]
                )
                message = f"{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} Outbound {from_port} to {sg_id} Deleted!"
                log_to_cloudwatch(message)

    for rule in allowed_inbound_ports:
        if rule not in current_inbound_rules:
            if rule['port'] == -1:
                ec2.authorize_security_group_ingress(
                    GroupId=security_group_id,
                    IpPermissions=[
                        {
                            'IpProtocol': '-1',
                            'IpRanges': [get_ip_permission(rule['source'])] if '/' in rule['source'] else [],
                            'UserIdGroupPairs': [{'GroupId': rule['source']}] if rule['source'].startswith('sg-') else []
                        }
                    ]
                )
                message = f"{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} Inbound All Traffic from {rule['source']} Added!"
                log_to_cloudwatch(message)
            else:
                ec2.authorize_security_group_ingress(
                    GroupId=security_group_id,
                    IpPermissions=[
                        {
                            'IpProtocol': 'tcp',
                            'FromPort': rule['port'],
                            'ToPort': rule['port'],
                            'IpRanges': [get_ip_permission(rule['source'])] if '/' in rule['source'] else [],
                            'UserIdGroupPairs': [{'GroupId': rule['source']}] if rule['source'].startswith('sg-') else []
                        }
                    ]
                )
                message = f"{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} Inbound {rule['port']} from {rule['source']} Added!"
                log_to_cloudwatch(message)

    for rule in allowed_outbound_ports:
        if rule not in current_outbound_rules:
            if rule['port'] == -1:
                ec2.authorize_security_group_egress(
                    GroupId=security_group_id,
                    IpPermissions=[
                        {
                            'IpProtocol': '-1',
                            'IpRanges': [get_ip_permission(rule['destination'])] if '/' in rule['destination'] else [],
                            'UserIdGroupPairs': [{'GroupId': rule['destination']}] if rule['destination'].startswith('sg-') else []
                        }
                    ]
                )
                message = f"{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} Outbound All Traffic to {rule['destination']} Added!"
                log_to_cloudwatch(message)
            else:
                ec2.authorize_security_group_egress(
                    GroupId=security_group_id,
                    IpPermissions=[
                        {
                            'IpProtocol': 'tcp',
                            'FromPort': rule['port'],
                            'ToPort': rule['port'],
                            'IpRanges': [get_ip_permission(rule['destination'])] if '/' in rule['destination'] else [],
                            'UserIdGroupPairs': [{'GroupId': rule['destination']}] if rule['destination'].startswith('sg-') else []
                        }
                    ]
                )
                message = f"{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')} Outbound {rule['port']} to {rule['destination']} Added!"
                log_to_cloudwatch(message)

def lambda_handler(event, context):
    security_groups = get_security_groups(instance_id)
    
    for sg_id in security_groups:
        revoke_security_group_rules(sg_id)