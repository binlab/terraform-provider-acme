# ACME Certificate and Account Provider

-> **Note:** This is a maintained fork of the `vancluever/acme` provider.
This fork is actively maintained to provide critical enhancements and features
that are currently missing or unaddressed in the upstream repository.

> **Key Enhancements:**
>
> - **Resource-Level `server_url`** (see
>   [Issue #534](https://github.com/vancluever/terraform-provider-acme/issues/534)
>   or the [feat/resource-level-server-url](https://github.com/binlab/terraform-provider-acme/tree/feat/resource-level-server-url)
>   branch):
>   Added the ability to specify the ACME `server_url` directly on resources
>   (`acme_certificate` and `acme_registration`). This allows overriding the
>   provider-level URL, preventing legacy module restrictions when managing
>   resources across multiple ACME endpoints.
> - **Insecure Recreate** (see the
>   [feat/certificate-insecure-recreate](https://github.com/binlab/terraform-provider-acme/tree/feat/certificate-insecure-recreate)
>   branch):
>   Added the `insecure_recreate` flag to the `acme_certificate` resource. This
>   enables automatic recreation of the certificate if the associated ACME
>   account (registration) is missing or deleted on the server. This is
>   critical for local testing with stateless ACME servers (like Pebble)
>   that do not persist state across restarts.

The Automated Certificate Management Environment (ACME) is an evolving standard
for the automation of a domain-validated certificate authority. Clients register
themselves on an authority using a private key and contact information, and
answer challenges for domains that they own by supplying response data issued by
the authority via either HTTP or DNS. Via this process, they prove that they own
the domains in question, and can then request certificates for them via the CA.
No part of this process requires user interaction, a traditional blocker in
obtaining a domain validated certificate.

Currently the major ACME CA is [Let's Encrypt][lets-encrypt], but the ACME
support in Terraform can be configured to use any ACME CA, including an
internal one that is set up using [Boulder][boulder-gh], or another CA
that implements the ACME standard with Let's Encrypt's
[divergences][lets-encrypt-divergences].

[lets-encrypt]: https://letsencrypt.org
[boulder-gh]: https://github.com/letsencrypt/boulder
[lets-encrypt-divergences]: https://github.com/letsencrypt/boulder/blob/main/docs/acme-divergences.md

For more detail on the ACME process, see [here][lets-encrypt-how-it-works]. For
the ACME spec, click [here][about-acme]. Note that as mentioned in the last
paragraph, the ACME provider may [diverge][lets-encrypt-divergences] from the
current ACME spec to account for the real-world divergences that are made by
CAs such as Let's Encrypt.

[lets-encrypt-how-it-works]: https://letsencrypt.org/how-it-works/
[about-acme]: https://ietf-wg-acme.github.io/acme/draft-ietf-acme-acme.html

## Basic Example

The following example can be used to create an account using the
[`acme_registration`][resource-acme-registration] resource, and a certificate
using the [`acme_certificate`][resource-acme-certificate] resource. DNS
validation is performed by using [Amazon Route 53][aws-route-53], for which
appropriate credentials are assumed to be in your environment.

[resource-acme-registration]: ./resources/registration.md
[resource-acme-certificate]: ./resources/certificate.md
[aws-route-53]: https://aws.amazon.com/route53/

-> The directory URLs in all examples in this provider reference Let's Encrypt's
staging server endpoint. For production use, change the directory URLs to the
production endpoints, which can be found [here][lets-encrypt-endpoints].

[lets-encrypt-endpoints]: https://letsencrypt.org/docs/acme-protocol-updates/

```hcl
terraform {
  required_providers {
    acme = {
      source  = "binlab/acme"
      version = "~> 2.0"
    }
  }
}

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

resource "acme_registration" "reg" {
  email_address   = "nobody@example.com"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = "www.example.com"
  subject_alternative_names = ["www2.example.com"]

  dns_challenge {
    provider = "route53"
  }
}
```

## Argument Reference

The following arguments are required:

* `server_url` - (Required) The URL to the ACME endpoint's directory.

-> Note that the account key is not a provider-level config value at this time
to allow the management of accounts and certificates within the same provider.
