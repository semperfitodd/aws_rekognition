locals {
  bucket_name = "${replace(var.environment, "_", "-")}-${random_string.this.result}"

  environment = replace(var.environment, "_", "-")
}