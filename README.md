# iam-nexus

Terraform module for creating IAM Role and Profile for attaching to Nexus EC2 instances to give access to :
1) EC2 instance create/start/stop/...
2) Nexus get config files from S3
3) Cloudwatch logging and metrics
4) Check AutoScalingGroup for number of instances so can delay mounting EFS until no instances using it.
5) Send SNS messages for alerting
6) Send Update on instance health to the ASG
7) Get secrets for nexus user passwords