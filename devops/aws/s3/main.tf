
# step 1: Define Your S3 Buckets
resource "aws_s3_bucket" "source_bucket" {
	bucket = "my-source-bucket-example"
	
	tags = {
		Name        = "SourceBucket"
		Environment = "Production"
	}
}

resource "aws_s3_bucket_versioning" "enable_versioning_s3" {
	bucket = aws_s3_bucket.source_bucket.id
	versioning_configuration {
		status = "Enabled"
	}
}

resource "aws_s3_bucket_acl" "s3_grant_permission" {
	bucket = aws_s3_bucket.source_bucket.id
	acl    = "private"
}

resource "aws_s3_bucket" "destination_bucket" {
	bucket = "my-destination-bucket-example"
	
	tags = {
		Name        = "DestinationBucket"
		Environment = "Production"
	}
}

resource "aws_s3_bucket_versioning" "enable_versioning_s3_dest" {
	bucket = aws_s3_bucket.destination_bucket.id
	versioning_configuration {
		status = "Enabled"
	}
}

resource "aws_s3_bucket_acl" "s3_grant_permission_dest" {
	bucket = aws_s3_bucket.destination_bucket.id
	acl    = "private"
}

# step 2: Create an IAM Role for Replication
resource "aws_iam_role" "replication_role" {
	name = "s3-replication-role"
	
	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Action = "sts:AssumeRole"
				Effect = "Allow"
				Principal = {
					Service = "s3.amazonaws.com"
				}
			}
		]
	})
}

resource "aws_iam_policy" "replication_policy" {
	name        = "s3-replication-policy"
	description = "Allows S3 to replicate objects"
	
	policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Action = [
					"s3:GetObject",
					"s3:ListBucket",
					"s3:ReplicateObject",
					"s3:ReplicateDelete",
					"s3:ReplicateTags"
				]
				Effect   = "Allow"
				Resource = [
					"arn:aws:s3:::my-source-bucket-example/*",
					"arn:aws:s3:::my-source-bucket-example"
				]
			},
			{
				Action = "s3:PutObject"
				Effect = "Allow"
				Resource = "arn:aws:s3:::my-destination-bucket-example/*"
			}
		]
	})
}

resource "aws_iam_role_policy_attachment" "replication_role_attachment" {
	role       = aws_iam_role.replication_role.name
	policy_arn = aws_iam_policy.replication_policy.arn
}

# Step 3: S3 Replication Configuration
resource "aws_s3_bucket_replication_configuration" "replication_config" {
	bucket = aws_s3_bucket.source_bucket.id
	
	role = aws_iam_role.replication_role.arn
	
	rule {
		id     = "ReplicationRule1"
		status = "Enabled"
		
		filter {
			prefix = ""
		}
		
		destination {
			bucket        = aws_s3_bucket.destination_bucket.arn
			storage_class = "STANDARD"
		}
	}
}
