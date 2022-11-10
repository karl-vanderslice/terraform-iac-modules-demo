variable "environment_name" {
  default     = "dev"
  type        = string
  description = "Name of the environment to provision."
}

variable "allowed_ingress_ips" {
  default     = ["0.0.0.0/0"]
  type        = list(any)
  description = "Allowed IP ranges for created AWS resources."
}

variable "tags" {
  default     = {}
  type        = map(any)
  description = "List of tags to add to the created resources."
}

variable "vpc_id" {
  default     = null
  type        = string
  description = "ID of the VPC to provision resources against."
}

variable "public_subnet_ids" {
  default     = null
  type        = list(any)
  description = "List of subnet IDs to provision against."
}

variable "target_group_port" {
  default     = 5000
  type        = number
  description = "Port number for the target group.  Should match what the app is running internally."
}

variable "target_group_protocol" {
  default     = "HTTP"
  type        = string
  description = "Protocol for traffic between the ALB and ECS.  Default this to HTTPS for now."
}

variable "ssl_cert_arn" {
  default     = null
  type        = string
  description = "ARN of the certificate to use for the HTTPS load balancer."
}