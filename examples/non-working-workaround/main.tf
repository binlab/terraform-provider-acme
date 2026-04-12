locals {
  acme = {
    prd = {
      domain = "example.com"
      server = "https://acme-v02.api.letsencrypt.org/directory"
    }
    stg = {
      domain = "stg.example.com"
      server = "https://acme-staging-v02.api.letsencrypt.org/directory"
    }
    dev = {
      domain = "dev.example.com"
      server = "https://acme.internal.local/directory"
    }
  }
}

module "acme" {
  for_each = local.acme

  source = "./modules/acme"

  acme = each.value
}
