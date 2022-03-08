locals {
  domain                = local.redirect_to_subdomain ? var.source_subdomain : var.zone
  redirect_to_subdomain = var.source_subdomain != ""
}
