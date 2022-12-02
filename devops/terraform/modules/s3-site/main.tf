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

  depends_on = [
    aws_s3_bucket.host_bucket
  ]
}

# Add more aws_s3_bucket_object for the type of files you want to upload
# The reason for having multiple aws_s3_bucket_object with file type is to make sure
# we add the correct content_type for the file in S3. Otherwise website load may have issues

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = var.cname
}

resource "aws_cloudfront_distribution" "distro" {
  origin {
    # We generate the name to keep the bucket requirement optional
    domain_name = "${var.host_s3_bucket}.s3.amazonaws.com"
    origin_path = "/${var.s3_prefix}"
    origin_id   = var.cname

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  dynamic "origin" {
    for_each = var.apigateway_origins

    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.id
      origin_path = origin.value.stage_name

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # Configure logging here if required 	
  #logging_config {
  #  include_cookies = false
  #  bucket          = "mylogs.s3.amazonaws.com"
  #  prefix          = "myprefix"
  #}

  # If you have domain configured use it here 
  aliases = [var.cname]

  # Redirect to https
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = var.cname

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }


  # Cache behavior with precedence 0
  # API's
  dynamic "ordered_cache_behavior" {
    for_each = var.apigateway_origins

    content {
      path_pattern     = ordered_cache_behavior.value.path_pattern
      allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods   = ["GET", "HEAD", "OPTIONS"]
      target_origin_id = ordered_cache_behavior.value.id

      forwarded_values {
        query_string = true
        # Define explicit headers, since API Gateway doesn't work otherwise
        # Aka host mismatch leads to 403's
        headers = [
          "Accept",
          "Referer",
          "Athorization",
          "Content-Type"
        ]

        cookies {
          forward = "all"
        }
      }

      min_ttl                = 0
      default_ttl            = 60
      max_ttl                = 60
      compress               = true
      viewer_protocol_policy = "https-only"
    }
  }

  # S3 frontend
  ordered_cache_behavior {
    path_pattern     = "*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.cname

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(var.tags, {

  })

  viewer_certificate {
    acm_certificate_arn      = var.acm_arn == null ? aws_acm_certificate.cname_cert[0].arn : var.acm_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [
    aws_acm_certificate.cname_cert
  ]
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::${var.host_s3_bucket}/${var.s3_prefix}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "host_bucket" {
  bucket = aws_s3_bucket_website_configuration.s3_site.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "host_bucket" {
  bucket = aws_s3_bucket_website_configuration.s3_site.id

  block_public_acls   = true
  block_public_policy = true
  //ignore_public_acls      = true
  //restrict_public_buckets = true
}