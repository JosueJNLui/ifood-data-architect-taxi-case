provider "aws" {
  region  = local.aws_region
  profile = local.aws_profile
}

# resource "aws_s3_bucket" "tf_state" {
#   bucket        = "josu-personal-projects-us-east-2"
#   force_destroy = false
# }

# resource "aws_s3_bucket_versioning" "tf_state" {
#   bucket = aws_s3_bucket.tf_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_dynamodb_table" "tf_lock" {
#   name         = "josu-personal-projects-tfstate-dynamo"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }