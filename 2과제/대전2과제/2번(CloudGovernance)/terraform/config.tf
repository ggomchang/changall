resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "wsi-config-port"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_configuration_recorder_status" "config_recorder_status" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true
  depends_on = [
    aws_config_delivery_channel.config_delivery_channel
    ]
}

resource "aws_config_delivery_channel" "config_delivery_channel" {
  name           = "config_delivery_channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
  depends_on = [
    aws_config_configuration_recorder.config_recorder
  ]
}


resource "aws_config_config_rule" "config_rule" {
  name = "wsi-config-port"

  scope {
    compliance_resource_id = aws_security_group.bastion_sg.id
    compliance_resource_types = [
      "AWS::EC2::SecurityGroup"
    ]
  }

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = aws_lambda_function.lambda_function.arn

    source_detail {
      message_type = "ConfigurationItemChangeNotification"
    }
  }

  depends_on = [
    aws_config_configuration_recorder.config_recorder,
    aws_lambda_permission.lambda_permission,
    aws_config_delivery_channel.config_delivery_channel
  ]
}
