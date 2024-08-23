# IAM MFA Denying

태그: IAM
Priority: ⠀P3 - Low⠀
Status: ⠀⠀⠀Done⠀⠀⠀
상위 항목: IAM (https://www.notion.so/IAM-523332878ffe4bf29f652401ece944db?pvs=21)

# IAM MFA Denying

## MFA required Policy

<aside>
💡 MultiFactorAuthPresent: false 값이 존재한다면 s3:DeleteBucket 권한을 Deny 시킴.

</aside>

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Action": "s3:DeleteBucket",
            "Resource": "*",
            "Condition": {
                "BoolIfExists": {
                    "aws:MultiFactorAuthPresent": "false"
                }
            }
        }
    ]
}
```

## Region restrict access Policy

<aside>
💡 apne2 리전이 아닌 경우 전체 서비스의 접근 권한을 Deny 시킴.

</aside>

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Action": "*",
            "Resource": "*",
            "Condition": {
                "StringNotEquals": {
                    "aws:RequestedRegion": "ap-northeast-2"
                }
            }
        }
    ]
}
```