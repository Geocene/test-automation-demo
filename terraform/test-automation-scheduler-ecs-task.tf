resource "aws_ecs_task_definition" "test-automation-scheduler" {
  family                   = "test-automation"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 8192
  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn      = aws_iam_role.ecs-test-automation-task-role.arn
  container_definitions = <<DEFINITION
[
  {
    "image": "${aws_ecr_repository.test-automation.repository_url}:latest",
    "name": "test-automation-scheduler",
    "networkMode": "awsvpc",
    "environment": [
        {
          "name": "TESTRAIL_DOMAIN",
          "value": "exampletestrail.testrail.io"
        },
        {
          "name": "TESTRAIL_USERNAME",
          "value": "name@example.com"
        },
        {
          "name": "TESTRAIL_PASSWORD",
          "value": "secret"
        },
        {
          "name": "TESTRAIL_APIKEY",
          "value": "TestRail Api Key"
        },
        {
          "name": "TESTRAIL_PROJECTID",
          "value": "1"
        },
        {
          "name": "NODE_OPTIONS",
          "value": "--max-old-space-size=8192"
        },
        {
          "name": "TESTRAIL_INCLUDEALL",
          "value": "false"
        },
        {
          "name": "POSTMAN_API_KEY",
          "value": "Postman Api Key"
        },
        {
          "name": "COLLECTION_NAME",
          "value": "Collection Name"
        },
        {
          "name": "ENVIRONMENT_NAME",
          "value": "Postman Environment name"
        }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.test-automation-scheduler.name}",
            "awslogs-region": "${var.AWS_REGION}",
            "awslogs-stream-prefix": "ecs"
        }
    }

  }
]
DEFINITION
}


## Cloudwatch event role

resource "aws_iam_role" "scheduled_task_cloudwatch" {
  name               = "test-automation-st-cloudwatch-role"
  assume_role_policy = file("${path.module}/policies/scheduled-task-cloudwatch-assume-role-policy.json")
}

data "template_file" "scheduled_task_cloudwatch_policy" {
  template = "${file("${path.module}/policies/scheduled-task-cloudwatch-policy.json")}"

  vars = {
    task_execution_role_arn = aws_iam_role.scheduled_task_cloudwatch.arn
  }
}


resource "aws_iam_role_policy" "scheduled_task_cloudwatch_policy" {
  name   = "test-automation-st-cloudwatch-policy"
  role   = aws_iam_role.scheduled_task_cloudwatch.id
  policy = data.template_file.scheduled_task_cloudwatch_policy.rendered
}




resource "aws_cloudwatch_log_group" "test-automation-scheduler" {
  name = "/ecs/test-automation"
}


resource "aws_cloudwatch_event_rule" "test-automation-rule" {
  name        = "test-automation"
  description = "Run every day at 5am"
  schedule_expression = "cron(0 5 * * ? *)"
}

resource "aws_ecs_cluster" "test-automation" {
  name = "test-automation"
}


resource "aws_cloudwatch_event_target" "test-automation-target" {
  target_id = "test-automation-scheduler"
  arn  =      aws_ecs_cluster.test-automation.arn
  rule      = aws_cloudwatch_event_rule.test-automation-rule.name
  role_arn  = aws_iam_role.scheduled_task_cloudwatch.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.test-automation-scheduler.arn
    launch_type         = "FARGATE"

 network_configuration {
    subnets          = slice(module.vpc.public_subnets, 1, 2)
    security_groups  = [aws_security_group.ecs-demo.id]
    assign_public_ip = true
  }

  }
}


# security group
resource "aws_security_group" "ecs-demo" {
  name        = "ECS demo"
  vpc_id      = module.vpc.vpc_id
  description = "ECS demo"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}