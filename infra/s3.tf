################################################################################
# S3 Buckets
# https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master
################################################################################

module "s3_buckets" {

  for_each = contains(local.dev_and_prod_envs, terraform.workspace) ? var.s3_buckets : {}

  # Module source path
  source = "terraform-aws-modules/s3-bucket/aws"

  # Module version
  version = "~> 3.14.0"

  # (Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name.
  bucket = format("%s-%s", each.key, data.aws_caller_identity.current.account_id)

  # (Optional) The canned ACL to apply. Conflicts with `grant`
  # acl = each.value.acl
  acl = null

  # Whether to manage S3 Bucket Ownership Controls on this bucket.
  control_object_ownership = each.value.control_object_ownership

  # Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter.
  # 'BucketOwnerEnforced': ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket.
  # 'BucketOwnerPreferred': Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL.
  # 'ObjectWriter': The uploading account will own the object if the object is uploaded with the bucket-owner-full-control canned ACL.
  object_ownership = each.value.object_ownership

  # Controls if S3 bucket should have deny non-SSL transport policy attached
  attach_deny_insecure_transport_policy = each.value.attach_deny_insecure_transport_policy

  # Controls if S3 bucket should require the latest version of TLS
  attach_require_latest_tls_policy = each.value.attach_require_latest_tls_policy

  # Controls if S3 bucket should deny incorrect encryption headers policy attached
  attach_deny_incorrect_encryption_headers = each.value.attach_deny_incorrect_encryption_headers


  # Map containing versioning configuration
  versioning = {
    enabled = each.value.versioning_enabled
  }

  # Additional tags
  tags = {
    "Name" = format("%s-%s", each.key, data.aws_caller_identity.current.account_id)
  }
}
