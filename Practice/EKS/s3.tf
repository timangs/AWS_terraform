# s3.tf (신규)

# Create the S3 bucket for kOps state store
resource "aws_s3_bucket" "kops_state" {
  bucket = var.s3_state_store # Use the variable for the bucket name

  # Prevent accidental deletion of the state store bucket
  lifecycle {
    prevent_destroy = false
  }

  tags = merge(var.instance_tags, {
    Name = var.s3_state_store
  })
}

# Enable versioning for the kOps state store bucket
resource "aws_s3_bucket_versioning" "kops_state_versioning" {
  bucket = aws_s3_bucket.kops_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enforce server-side encryption (AES256) for the kOps state store bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "kops_state_sse" {
  bucket = aws_s3_bucket.kops_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access to the kOps state store bucket
resource "aws_s3_bucket_public_access_block" "kops_state_public_access" {
  bucket = aws_s3_bucket.kops_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Output the name of the S3 bucket created
output "kops_state_store_bucket_name" {
  description = "Name of the S3 bucket created for kOps state store"
  value       = aws_s3_bucket.kops_state.bucket
}
