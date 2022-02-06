variable "resource_name_prefix" {
  description   = "Name prefix to apply to all created resources"
  default       = ""
  type          = string
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
