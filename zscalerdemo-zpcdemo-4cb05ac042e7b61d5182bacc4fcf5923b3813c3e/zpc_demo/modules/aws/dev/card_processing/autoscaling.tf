data "aws_availability_zones" "available" {}

resource "aws_autoscaling_group" "autoscaling-frontend" {
  name                      = "cardprocessing-dev-frontend-autoscaling"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = true
  placement_group           = aws_placement_group.cardprocessing-cluster.id
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = [aws_subnet.eks-subnet-1.id, aws_subnet.eks-subnet-2.id]

  initial_lifecycle_hook {
    name                 = "frontend-lifecycle-hook"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    notification_metadata = <<EOF
{
  "tier": "frontend"
}
EOF

    #notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
    #role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  }

  tag {
    key                 = "env"
    value               = "dev"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "tier"
    value               = "frontend"
    propagate_at_launch = false
  }
}

resource "aws_autoscalingplans_scaling_plan" "safemarch-scaling-plan" {
  name = "safemarch-cardprocessing-scaling-plan"

  application_source {
    tag_filter {
      key    = "application"
      values = ["cardprocessing"]
    }
  }

  scaling_instruction {
    max_capacity       = 3
    min_capacity       = 0
    resource_id        = format("autoScalingGroup/%s", aws_autoscaling_group.autoscaling-frontend.name)
    scalable_dimension = "autoscaling:autoScalingGroup:DesiredCapacity"
    service_namespace  = "autoscaling"

    target_tracking_configuration {
      predefined_scaling_metric_specification {
        predefined_scaling_metric_type = "ASGAverageCPUUtilization"
      }

      target_value = 70
    }
  }
}