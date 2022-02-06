# Output values
#
output "nexus-role" {
  value = aws_iam_role.nexus
}
output "nexus-profile" {
  value = aws_iam_instance_profile.nexus
}