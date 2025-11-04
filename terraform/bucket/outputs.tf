output "website_endpoint" {
  description = "URL pública do site hospedado no S3"
  value       = aws_s3_bucket_website_configuration.site.website_endpoint
}
