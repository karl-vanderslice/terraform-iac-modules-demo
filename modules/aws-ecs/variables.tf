variable "environment_name" {
  default     = "dev"
  type        = string
  description = "Name of the environment (app) which will be used to isolate and provision resources"
}

variable "tags" {
  default     = {}
  type        = map(any)
  description = "Map of tags to apply to created resources."
}

variable "vpc_id" {
  default     = null
  type        = string
  description = "VPC to provision resources (security groups, EC2, etc.) into."
}

variable "container_port" {
  default     = 5000
  type        = number
  description = "Port to allow traffic from the ALB to the ECS service"
}

variable "alb_security_group_id" {
  default     = null
  type        = string
  description = "Security group attached to load balancer."
}

variable "container_image" {
  default     = null
  type        = string
  description = "Container image to pull and run.  Should be publically available."
}

variable "special_variable" {
  default     = "Hello world!"
  type        = string
  description = "Special variable to pass through to the ECS definition."
}

variable "lb_target_group_arn" {
  default     = null
  type        = string
  description = "ARN of the Target Group of the associated Load Balancer."
}

variable "ecs_subnets" {
  default     = []
  type        = list(any)
  description = "List of subnets to associate with the ECS service."
}