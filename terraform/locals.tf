locals {
  env                = var.env
  aws_region         = var.aws_region
  aws_profile        = var.aws_profile
  aws_account_id     = data.aws_caller_identity.current.account_id
  project            = var.project
  projects_component = var.projects_component
  data_sources       = ["fhvhv_tripdata", "fhv_tripdata", "green_tripdata", "yellow_tripdata"]
}
