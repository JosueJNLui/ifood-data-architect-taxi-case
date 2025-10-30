################################################################################################
# Data Source: to get the access to the Account ID, User ID, and ARN
################################################################################################

data "aws_caller_identity" "current" {}
data "aws_route53_zone" "domains" {

  for_each = toset(var.domain_names)
  name     = each.key

}
