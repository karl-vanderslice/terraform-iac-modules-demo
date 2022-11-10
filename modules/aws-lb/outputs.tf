output "alb_security_group_id" {
  value       = aws_security_group.alb_sg.id
  description = "ID of the ALB security group."
}

output "alb_dns_record" {
  value       = aws_alb.alb.dns_name
  description = "DNS record for the created load balancer."
}

output "alb_target_group_arn" {
  value       = aws_alb_target_group.tg.arn
  description = "ARN of the created target group"
}