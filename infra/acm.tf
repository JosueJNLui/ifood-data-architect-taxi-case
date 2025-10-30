################################################################################
# AWS Certificate Manager (ACM)
# https://github.com/terraform-aws-modules/terraform-aws-acm
################################################################################

module "acm" {

  for_each = contains(local.dev_and_prod_envs, terraform.workspace) ? data.aws_route53_zone.domains : {}

  # Module source path
  source = "terraform-aws-modules/acm/aws"

  # Module version
  version = "~> 4.0"

  # A domain name for which the certificate should be issued    
  domain_name = each.value.name

  # The ID of the hosted zone to contain the record. Required when validating via Route53
  zone_id = each.value.zone_id

  # A list of domains that should be SANs in the issued certificate
  subject_alternative_names = [
    format("*.%s", each.value.name),
    format("%s", each.value.name),
  ]

  # Whether to wait for the validation complete
  wait_for_validation = false

  # A mapping tags to assign to the resource
  tags = {
    Name = format("%s", each.value.name)
  }

  depends_on = [module.route53_zones]

}
