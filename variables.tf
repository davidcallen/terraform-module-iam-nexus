variable "resource_name_prefix" {
  description   = "Name prefix to apply to all created resources"
  default       = ""
  type          = string
}
variable "route53_private_zone_id" {
  description = "The ID of our Route53 Private Hosted Zone (for registering our DNS record)"
  type        = string
  default     = true
}
variable "secrets_arns" {
  description   = "ARNs of Secrets that need to get secret value for"
  type          = list(string)
  default       = []
}
variable "tags" {
  description   = "tags"
  type          = map(string)
  default       = {}
}
