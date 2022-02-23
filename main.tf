# ---------------------------------------------------------------------------------------------------------------------
# IAM Role for use by an EC2 instance of Nexus to give access to :
#   1) Register DNS record to Route53 for our ec2 host
#   2) Nexus get config files from S3
#   3) Cloudwatch logging and metrics
#   4) Check AutoScalingGroup for number of instances so can delay mounting EFS until no instances using it.
#   5) Send SNS messages for alerting
#   6) Send Update on instance health to the ASG
#   7) Get secret for nexus admin password
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "nexus" {
  name                 = "${var.resource_name_prefix}-nexus"
  max_session_duration = 43200
  assume_role_policy   = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags                 = var.tags
}

# 1) Register DNS record to Route53 for our ec2 host
resource "aws_iam_policy" "route53" {
  name        = "${var.resource_name_prefix}-nexus-route53"
  description = "RegisterDNSwithRoute53"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Route53registerDNS",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:GetHostedZone",
        "route53:ListResourceRecordSets"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:route53:::hostedzone/${var.route53_private_zone_id}"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "route53" {
  role       = aws_iam_role.nexus.name
  policy_arn = aws_iam_policy.route53.arn
}

# 2) Nexus get config files from S3
resource "aws_iam_policy" "nexus-s3" {
  name        = "${var.resource_name_prefix}-nexus-s3"
  description = "Read access to s3 bucket for Nexus config files"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "NexusReadS3",
      "Action": [
        "s3:List*",
        "s3:GetObject*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "nexus-s3" {
  role       = aws_iam_role.nexus.name
  policy_arn = aws_iam_policy.nexus-s3.arn
}

# 3) Cloudwatch logging and metrics - To allow output of metrics and logs to Cloudwatch
resource "aws_iam_role_policy_attachment" "nexus-cloudwatch" {
  role       = aws_iam_role.nexus.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# 4) Check AutoScalingGroup for number of instances so can delay mounting EFS until no instances using it.
resource "aws_iam_role_policy_attachment" "nexus-asg" {
  role       = aws_iam_role.nexus.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingReadOnlyAccess"
}

# 5) Send SNS messages for alerting
resource "aws_iam_policy" "nexus-sns" {
  name        = "${var.resource_name_prefix}-nexus-sns"
  description = "Add ability to send SNS alert message"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "nexus-sns" {
  role       = aws_iam_role.nexus.name
  policy_arn = aws_iam_policy.nexus-sns.arn
}

# 6) Send Update on instance health to the ASG
resource "aws_iam_policy" "nexus-asg-health" {
  name        = "${var.resource_name_prefix}-nexus-asg-health"
  description = "Send Update on instance health to the ASG"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:SetInstanceHealth"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "nexus-asg-health" {
  role       = aws_iam_role.nexus.name
  policy_arn = aws_iam_policy.nexus-asg-health.arn
}

# 7) Get secret for nexus admin password
resource "aws_iam_policy" "nexus-get-secrets" {
  name        = "${var.resource_name_prefix}-nexus-get-secrets"
  description = "Get secret for nexus admin password"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GetSecretsForNexus"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.secrets_arns
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "nexus-get-secrets" {
  role       = aws_iam_role.nexus.name
  policy_arn = aws_iam_policy.nexus-get-secrets.arn
}


resource "aws_iam_instance_profile" "nexus" {
  name = "nexus"
  role = aws_iam_role.nexus.name
}
