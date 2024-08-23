resource "aws_sqs_queue" "sqs" {
  name = "j-company-sqs"
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.sqs.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Id": "__default_policy_ID",
    "Statement": [
      {
        "Sid": "Allow",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "SQS:*",
        "Resource": "${aws_sqs_queue.sqs.arn}"
      }
    ]
  })
}