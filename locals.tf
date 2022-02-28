locals {
  domain                = redirect_to_subdomain ? var.origin_subdomain : var.zone
  redirect_to_subdomain = var.origin_subdomain != ""
}
