#######################################################################################################
# AWS CloudFront Terraform module
# https://github.com/terraform-aws-modules/terraform-aws-cloudfront
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
#######################################################################################################

module "cloudfront_s3_buckets" {

  # Map for all records to create
  for_each = contains(local.dev_and_prod_envs, terraform.workspace) ? var.cloudfront_s3_buckets : {}

  # Module Source path
  source = "terraform-aws-modules/cloudfront/aws"

  # Module version
  version = "~> 3.2.1"

  # Extra CNAMEs (alternative domain names), if any, for this distribution
  aliases = each.value.aliases

  # Any comments you want to include about the distribution
  comment             = each.value.description
  enabled             = each.value.enabled
  is_ipv6_enabled     = each.value.is_ipv6_enabled
  price_class         = each.value.price_class # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html
  retain_on_delete    = each.value.retain_on_delete
  wait_for_deployment = each.value.wait_for_deployment

  create_origin_access_control = true
  origin_access_control = {
    "${module.s3_buckets[format("%s", each.value.bucket_name_prefix)].s3_bucket_bucket_domain_name}" = {
      description      = format("%s can access", each.value.description)
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {
    "${module.s3_buckets[format("%s", each.value.bucket_name_prefix)].s3_bucket_bucket_domain_name}" = {

      domain_name           = module.s3_buckets[format("%s", each.value.bucket_name_prefix)].s3_bucket_bucket_domain_name
      origin_access_control = "${module.s3_buckets[format("%s", each.value.bucket_name_prefix)].s3_bucket_bucket_domain_name}"
    }
  }

  default_cache_behavior = {
    cache_policy_id        = each.value.default_cache_behavior.cache_policy_id
    viewer_protocol_policy = each.value.default_cache_behavior.viewer_protocol_policy
    target_origin_id       = "${module.s3_buckets[format("%s", each.value.bucket_name_prefix)].s3_bucket_bucket_domain_name}"
    use_forwarded_values   = false

    allowed_methods = each.value.default_cache_behavior.allowed_methods
    cache_methods   = each.value.default_cache_behavior.cached_methods
    compress        = each.value.default_cache_behavior.compress
    query_string    = each.value.default_cache_behavior.query_string
  }

  viewer_certificate = {
    acm_certificate_arn      = module.acm[format("%s", each.value.domain)].acm_certificate_arn
    minimum_protocol_version = each.value.viewer_certificate.minimum_protocol_version
    ssl_support_method       = each.value.viewer_certificate.ssl_support_method
  }

}

# Policy for s3 bucket allow access control from CloudFront

data "aws_iam_policy_document" "cloudfront_s3_buckets" {

  for_each = contains(local.dev_and_prod_envs, terraform.workspace) ? var.cloudfront_s3_buckets : {}

  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    resources = ["${module.s3_buckets[format("%s", each.value.bucket_name_prefix)].s3_bucket_arn}/*"]
    actions   = ["s3:GetObject"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.cloudfront_s3_buckets[format("%s", each.key)].cloudfront_distribution_arn]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

  }

  statement {
    sid    = "denyOutdatedTLS"
    effect = "Deny"

    resources = [
      "${module.s3_buckets[format("%s", each.value.bucket_name_prefix)].s3_bucket_arn}/*",
      "${module.s3_buckets[format("%s", each.value.bucket_name_prefix)].s3_bucket_arn}"
    ]

    actions = ["s3:*"]

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  statement {
    sid    = "denyInsecureTransport"
    effect = "Deny"

    resources = [
      "${module.s3_buckets[format("%s", each.value.bucket_name_prefix)].s3_bucket_arn}/*",
      "${module.s3_buckets[format("%s", each.value.bucket_name_prefix)].s3_bucket_arn}"
    ]

    actions = ["s3:*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }

  }

  statement {
    sid       = "denyIncorrectEncryptionHeaders"
    effect    = "Deny"
    resources = ["${module.s3_buckets[format("%s", each.value.bucket_name_prefix)].s3_bucket_arn}/*"]
    actions   = ["s3:PutObject"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }

  }

}


# Policy for s3 bucket allow Access from CloudFront
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  for_each = contains(local.dev_and_prod_envs, terraform.workspace) ? var.cloudfront_s3_buckets : {}

  bucket = module.s3_buckets[format("%s", each.value.bucket_name_prefix)].s3_bucket_id
  policy = data.aws_iam_policy_document.cloudfront_s3_buckets[format("%s", each.key)].json

}