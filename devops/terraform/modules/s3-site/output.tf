# to get the Cloud front URL if doamin/alias is not configured
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.distro.domain_name
}