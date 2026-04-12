terraform {
  required_version = ">= 1.9"
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "2.36.0"
    }
  }
}
