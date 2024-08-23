import boto3
import json

def lambda_handler(event, context):
    iam = boto3.client('iam')
    role_name = 'wsc2024-instance-role'
    policy_to_keep = 'AmazonSSMManagedInstanceCore'

    try:
        # IAM 역할에 연결된 모든 정책 목록을 가져옵니다.
        attached_policies = iam.list_attached_role_policies(RoleName=role_name)['AttachedPolicies']
        
        # AmazonSSMManagedInstanceCore를 제외한 모든 정책을 제거합니다.
        for policy in attached_policies:
            policy_arn = policy['PolicyArn']
            policy_name = policy_arn.split('/')[-1]  # ARN에서 정책 이름 추출
            
            if policy_name != policy_to_keep:
                iam.detach_role_policy(RoleName=role_name, PolicyArn=policy_arn)
        
        return {
            'statusCode': 200,
            'body': json.dumps('successfully delete policy')
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error detaching policies: {str(e)}")
        }
