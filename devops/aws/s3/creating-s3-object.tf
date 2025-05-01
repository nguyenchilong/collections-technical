terraform {
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "5.81.0"
		}
	}
}
# Creating an S3 object using Terraform

# we will upload a couple of files to our created S3 bucket using Terraform. First, create a folder called uploads inside the s3_basics folder. I shall keep three files — dog.jpg, cat.jpg and rabbit.jpg inside this folder — to be uploaded to our S3 Bucket. Now add the following code to the main.tf file after the aws_s3_bucket resource block:
# We've used the aws_s3_object resource to create three S3 objects. Inside the resource block, we’ve used the for_each block to loop over the files inside our uploads folder using the fileset function and uploaded them to our S3 Bucket using the same filename as the key. The etag attribute ensures that updates get triggered only when there is a file change.

# AWS S3 Bucket Resource
# This creates an S3 bucket in AWS with basic configuration

resource "aws_s3_bucket" "bucket" {
	bucket = "my-terraform-bucket"  # Replace with your desired bucket name
	
	# Optional: Add tags to your bucket
	tags = {
		Name        = "My Terraform Bucket"
		Environment = "Dev"
		Managed_by  = "Terraform"
	}
}

# Optional: Configure bucket versioning
resource "aws_s3_bucket_versioning" "versioning" {
	bucket = aws_s3_bucket.bucket.id
	
	versioning_configuration {
		status = "Enabled"  # Can be "Enabled" or "Disabled"
	}
}

# Optional: Configure server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
	bucket = aws_s3_bucket.bucket.id
	
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
	}
}

# Optional: Configure public access block (recommended for security)
resource "aws_s3_bucket_public_access_block" "public_access" {
	bucket = aws_s3_bucket.bucket.id
	
	block_public_acls       = true
	block_public_policy     = true
	ignore_public_acls      = true
	restrict_public_buckets = true
}

# Uploads files from local directory to S3 bucket
resource "aws_s3_object" "object" {
	bucket = aws_s3_bucket.bucket.id
	for_each = fileset("uploads/", "*")
	key = each.value
	source = "uploads/${each.value}"
	etag = filemd5("uploads/${each.value}")
	depends_on = [
		aws_s3_bucket.bucket
	]
}


