#Define S3
resource "aws_s3_bucket" "bucketo"{
  bucket        = var.s3_bucket_name
  force_destroy = "true"
}

#Bucket Policy
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.bucketo.id #ID of bucket
  #set bucket policy JSON code
  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": {
        "Sid": "AllowCloudFrontServicePrincipalReadWrite",
        "Effect": "Allow",
        "Principal": {
            "Service": "cloudfront.amazonaws.com"
        },
        "Action": [
            "s3:GetObject",
            "s3:PutObject"
        ],
        "Resource": "arn:aws:s3:::${var.s3_bucket_name}/*",
        "Condition": {
            "StringEquals": {
                "AWS:SourceArn": "arn:aws:cloudfront::686255964212:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
            }
        }
    }
}
  )
}

#Static Website Configuration
resource "aws_s3_bucket_website_configuration" "enable_website"{
  bucket = aws_s3_bucket.bucketo.id

  index_document {
    suffix = "index.html"
  }
}

#S3 Objects upload HTML file
resource "aws_s3_object" "upload_html" {
  bucket = aws_s3_bucket.bucketo.id
  key    = "index.html"
  source = "index.html"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("index.html")
}

