provider "acme" {
  for_each = local.acme

  alias = "alias"

  server_url = each.value.server
}
