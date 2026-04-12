variable "acme" {
  type = object({
    domain = string
    server = string
  })
  description = "Acme object"
}
