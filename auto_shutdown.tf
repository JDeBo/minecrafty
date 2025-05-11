resource "aws_cloudwatch_metric_alarm" "cpu_utilization_low" {
  alarm_name          = "minecraft-low-cpu-utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 6  # 6 periods of 5 minutes = 30 minutes
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300  # 5 minutes
  statistic           = "Average"
  threshold           = 5    # 5% CPU utilization threshold
  alarm_description   = "This metric monitors EC2 CPU utilization and stops the instance when it's below 5% for 30 minutes"
  alarm_actions       = ["arn:aws:automate:${data.aws_region.current.name}:ec2:stop"]
  
  dimensions = {
    InstanceId = aws_spot_instance_request.main.spot_instance_id
  }
}

data "aws_region" "current" {}

# Create an IAM role for EventBridge to stop EC2 instances
resource "aws_iam_role" "eventbridge_stop_ec2" {
  name = "EventBridgeStopEC2Role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policy to allow stopping EC2 instances
resource "aws_iam_policy" "stop_ec2" {
  name        = "StopEC2Policy"
  description = "Allow EventBridge to stop EC2 instances"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:StopInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_stop_ec2" {
  role       = aws_iam_role.eventbridge_stop_ec2.name
  policy_arn = aws_iam_policy.stop_ec2.arn
}