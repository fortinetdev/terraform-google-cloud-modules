# Project vars
variable "project" {
  type        = string
  description = "Your GCP project name."
}

variable "service_account_name" {
  type        = string
  description = "The account name you want to create."
}

variable "roles" {
  description = "List of roles to assign to the service account"
  type        = list(string)
  default     = []
}
