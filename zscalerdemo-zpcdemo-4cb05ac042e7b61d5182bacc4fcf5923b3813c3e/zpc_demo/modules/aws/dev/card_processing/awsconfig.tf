resource "aws_config_config_rule" "r" {
  name = "safemarch-awsconfig-dev"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.safemarch-config-recorder]
}

resource "aws_config_configuration_recorder" "safemarch-config-recorder" {
  name     = "safemarch-config-recorder"
  role_arn = aws_iam_role.safemarch-config-iam-role.arn
}

resource "aws_iam_role" "safemarch-config-iam-role" {
  name = "safemarch-awsconfig-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "safemarch-config-iam-role-policy" {
  name = "safemarch-awsconfig-policy"
  role = aws_iam_role.safemarch-config-iam-role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "config:Put*",
          "Effect": "Allow",
          "Resource": "*"

      }
  ]
}
POLICY
}