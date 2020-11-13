resource "aws_iam_role_policy" "policy_for_lambda" {
  name = "policy_for_lambda"
  role = aws_iam_role.role_for_lambda.id

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["arn:aws:s3:::${var.bucket_name}"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": ["arn:aws:s3:::${var.bucket_name}/*"]
        }
    ]
}
EOF
}

resource "aws_iam_role" "role_for_lambda" {
  name = "role_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "image_resizer_lambda" {
  function_name = "image_resizer_lambda"
  role          = aws_iam_role.role_for_lambda.arn
  handler       = "example.Handler::handleRequest"
  filename      = "s3-java/target/s3-java-1.0-SNAPSHOT.jar"
  timeout       = 60
  runtime       = "java11"
  environment {
    variables = {
      ENV_MAX_WIDTH = "200",
      ENV_MAX_HEIGHT = "200"
    }
  }
}