resource "aws_s3_bucket" "this" {
  bucket = "${local.project}-${local.env}-${local.aws_region}-${local.aws_account_id}"

  tags = {
    "project_name"      = local.project
    "project_component" = local.projects_component
  }
}
