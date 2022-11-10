output "acm_arn" {
  value       = aws_acm_certificate.cert.arn
  description = "ARN of the created certificate."
}

output "acm_id" {
  value       = aws_acm_certificate.cert.id
  description = "ID of the created certificate."
}