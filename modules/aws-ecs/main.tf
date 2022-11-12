locals {
  environment_name = var.environment_name
}

# 1. Security Groups for ECS

resource "aws_security_group" "ecs_service" {
  name_prefix = local.environment_name
  description = "Security group for ECS service ${local.environment_name}"
  tags        = var.tags
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "allow_all_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all egress traffic from ${local.environment_name}"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs_service.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "alb" {
  description              = "Allow load balancer traffic to ECS service ${local.environment_name}"
  from_port                = var.container_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_service.id
  source_security_group_id = var.alb_security_group_id
  to_port                  = var.container_port
  type                     = "ingress"
}

# 2. IAM for Fargate

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.environment_name}-ecs-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${local.environment_name}-ecs-task-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_iam_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 3. Task Definition

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = local.environment_name
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 1024
  requires_compatibilities = ["FARGATE"]

  container_definitions = <<TASK_DEFINITION
  [
    {
      "image": "${var.container_image}",
      "name": "${local.environment_name}-container",
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ]
    }
  ]
  TASK_DEFINITION

  # Don't overwrite task changes for now, assume we'll have another operation doing that ie. github actions
  lifecycle {
    ignore_changes = [container_definitions]
  }

  tags = var.tags

}

# 4. Cluster

resource "aws_ecs_cluster" "cluster" {
  name = "${local.environment_name}-cluster"

  tags = var.tags

}

# 5. Service

resource "aws_ecs_service" "service" {
  cluster         = aws_ecs_cluster.cluster.name
  desired_count   = 1
  launch_type     = "FARGATE"
  name            = "${local.environment_name}-ecs-service"
  task_definition = aws_ecs_task_definition.ecs_task.arn

  network_configuration {
    assign_public_ip = true # for internet access to pull our github container
    security_groups = [
      aws_security_group.ecs_service.id
    ]

    subnets = var.ecs_subnets

  }

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = "${local.environment_name}-container"
    container_port   = var.container_port
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [task_definition]
  }
}