provider "aws" {
  region = "us-east-1"
}

module "route53-domain-redirect" {
  source     = "https://github.com/Ibotta/terraform-module-route53-domain-redirect"
  zone       = "example.com"
  target_url = "https://google.com"
}

module "route53-domain-redirect-subdomain" {
  source           = "https://github.com/Ibotta/terraform-module-route53-domain-redirect"
  zone             = "example.com"
  source_subdomain = "foo.example.com"
  target_url       = "https://google.com"
}