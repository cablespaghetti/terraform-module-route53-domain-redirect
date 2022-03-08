variable "zone" {
  description = "Route53 zone name"
  type        = string
}

variable "target_url" {
  description = "URL to redirect to"
  type        = string
}

variable "source_subdomain" {
  description = "FQDN of subdomain that we want to redirect from."
  default     = ""
  type        = string
}