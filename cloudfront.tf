#CloudFront

locals {
  s3_origin_id = "${var.s3_bucket_name}-origin"
}
#Define origin access control
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = local.s3_origin_id
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#Full Setting for CloudFront
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    domain_name              = aws_s3_bucket.bucketo.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id  # Using the local variable

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}





 