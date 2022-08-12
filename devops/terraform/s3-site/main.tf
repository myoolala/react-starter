# resource "aws_s3_bucket" "host_bucket" {
#   count  = var.create_s3_bucket ? 1 : 0
#   bucket = var.host_s3_bucket
#   acl    = "private"
#   # Add specefic S3 policy in the s3-policy.json on the same directory
#   #policy = file("s3-policy.json")

#   versioning {
#     enabled = false
#   }

#   website {
#     index_document = "index.html"
#     error_document = "index.html"

#     # Add routing rules if required
#     #routing_rules = <<EOF
#     #                [{
#     #                    "Condition": {
#     #                        "KeyPrefixEquals": "docs/"
#     #                    },
#     #                    "Redirect": {
#     #                        "ReplaceKeyPrefixWith": "documents/"
#     #                    }
#     #                }]
#     #                EOF
#   }

#   tags = merge(var.tags, {

#   })

# }



resource "aws_s3_bucket_website_configuration" "s3_site" {
  bucket = var.host_s3_bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
  
#   routing_rule {
    
#   }
}

#Upload files of your static website
resource "aws_s3_object" "html" {
  for_each = fileset(var.path_to_app, "/**/*.html")

  bucket       = var.host_s3_bucket
  key          = "${var.s3_prefix}${each.value}"
  source       = "${var.path_to_app}${each.value}"
  etag         = filemd5("${var.path_to_app}${each.value}")
  content_type = "text/html"

  depends_on = [aws_s3_bucket_website_configuration.s3_site]
}

# resource "aws_s3_bucket_object" "css" {
#   for_each = fileset("../../mywebsite/", "**/*.css")

#   bucket = aws_s3_bucket_website_configuration.s3_site.bucket
#   key    = each.value
#   source = "../../mywebsite/${each.value}"
#   etag   = filemd5("../../mywebsite/${each.value}")
#   content_type = "text/css"

#   depends_on = var.create_s3_bucket ? [aws_s3_bucket_website_configuration.s3_site] : []
# }

# resource "aws_s3_bucket_object" "js" {
#   for_each = fileset("../../mywebsite/", "**/*.js")

#   bucket = aws_s3_bucket_website_configuration.s3_site.bucket
#   key    = each.value
#   source = "../../mywebsite/${each.value}"
#   etag   = filemd5("../../mywebsite/${each.value}")
#   content_type = "application/javascript"

#   depends_on = var.create_s3_bucket ? [aws_s3_bucket_website_configuration.s3_site] : []
# }
# Add more aws_s3_bucket_object for the type of files you want to upload
# The reason for having multiple aws_s3_bucket_object with file type is to make sure
# we add the correct content_type for the file in S3. Otherwise website load may have issues

# locals {
#   s3_origin_id = "s3-my-webapp.example.com"
# }

# resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
#   comment = "s3-my-webapp.example.com"
# }

# resource "aws_cloudfront_distribution" "s3_distribution" {
#   origin {
#     domain_name = aws_s3_bucket_website_configuration.s3_site.bucket_regional_domain_name
#     origin_id   = local.s3_origin_id

#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
#     }
#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   comment             = "my-cloudfront"
#   default_root_object = "index.html"

#   # Configure logging here if required 	
#   #logging_config {
#   #  include_cookies = false
#   #  bucket          = "mylogs.s3.amazonaws.com"
#   #  prefix          = "myprefix"
#   #}

#   # If you have domain configured use it here 
#   #aliases = ["mywebsite.example.com", "s3-static-web-dev.example.com"]

#   default_cache_behavior {
#     allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "allow-all"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   # Cache behavior with precedence 0
#   ordered_cache_behavior {
#     path_pattern     = "/content/immutable/*"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false
#       headers      = ["Origin"]

#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl                = 0
#     default_ttl            = 86400
#     max_ttl                = 31536000
#     compress               = true
#     viewer_protocol_policy = "redirect-to-https"
#   }

#   # Cache behavior with precedence 1
#   ordered_cache_behavior {
#     path_pattern     = "/content/*"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#     compress               = true
#     viewer_protocol_policy = "redirect-to-https"
#   }

#   price_class = "PriceClass_200"

#   restrictions {
#     geo_restriction {
#       restriction_type = "whitelist"
#       locations        = ["US", "CA", "GB", "DE", "IN", "IR"]
#     }
#   }

#   tags = {
#     Environment = "development"
#     Name        = "my-tag"
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }
# }

# data "aws_iam_policy_document" "s3_policy" {
#   statement {
#     actions   = ["s3:GetObject"]
#     resources = ["${aws_s3_bucket.b.arn}/*"]

#     principals {
#       type        = "AWS"
#       identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
#     }
#   }
# }

# resource "aws_s3_bucket_policy" "host_bucket" {
#   bucket = aws_s3_bucket_website_configuration.s3_site.id
#   policy = data.aws_iam_policy_document.s3_policy.json
# }

# resource "aws_s3_bucket_public_access_block" "host_bucket" {
#   bucket = aws_s3_bucket_website_configuration.s3_site.id

#   block_public_acls       = true
#   block_public_policy     = true
#   //ignore_public_acls      = true
#   //restrict_public_buckets = true
# }