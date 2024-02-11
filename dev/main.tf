
resource "random_id" "server" {
  byte_length = 2
}

locals {
  unique_id = "DEV-${random_id.server.hex}"
}

output "test" {
  value = local.unique_id
}