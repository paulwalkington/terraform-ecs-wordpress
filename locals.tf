locals {
  region      = "eu-west-2"
  project     = "pw-101"
  environment = terraform.workspace
  prefix      = "${local.project}-${local.environment}"
}
