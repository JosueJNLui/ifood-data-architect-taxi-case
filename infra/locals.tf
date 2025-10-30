################################################################################
# Locals
################################################################################

locals {
  dev_and_prod_envs = ["development", "production"]

  # Environment short name
  short_envs_map = {
    "development" = "dev",
    "production"  = "prod"
  }

  # Environment Short
  env = local.short_envs_map[terraform.workspace]

}