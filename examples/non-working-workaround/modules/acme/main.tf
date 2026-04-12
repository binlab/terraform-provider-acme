resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "acme_registration" "this" {
  account_key_pem = tls_private_key.this.private_key_pem
  email_address   = format("acme@%s", var.acme.domain)
}

resource "acme_certificate" "this" {
  account_key_pem = acme_registration.this.account_key_pem
  common_name     = var.acme.domain
}
