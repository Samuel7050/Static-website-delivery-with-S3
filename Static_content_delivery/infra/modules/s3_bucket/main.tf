# create S3 bucket
resource "aws_s3_bucket" "static_bucket" {
  bucket = var.bucket_name
}

# Bucket ownership control
resource "aws_s3_bucket_ownership_controls" "bucket_control" {
  bucket = aws_s3_bucket.static_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "lambda_access_policy" {
  bucket = aws_s3_bucket.static_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "LambdaS3ReadAccess",
        Effect    = "Allow",
        Principal = {
          AWS = "${var.lambda_exec_role}"  
        },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.static_bucket.arn}/*"
      }
    ]
  })
}

# Bucket website configurations
resource "aws_s3_bucket_website_configuration" "bucket_website_config" {
  bucket = aws_s3_bucket.static_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# Upload an object
resource "aws_s3_object" "file" {
  bucket       = aws_s3_bucket.static_bucket.id
  key          = var.bucket_key    
  source       = "${path.module}/index.html"   
  content_type = "text/html"
}
