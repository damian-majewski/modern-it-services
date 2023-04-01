provider "aws" {
  region = "us-west-2"
}

resource "aws_cloudwatch_metric_alarm" "cpu_usage" {
  alarm_name          = "CPUUsage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "80"
  alarm_description   = "CPU usage exceeds 80%"
  alarm_actions       = [aws_sns_topic.example.arn]
  dimensions = {
    InstanceId = aws_instance.example.id
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_usage" {
  # You'll need to replace the "Namespace" and "MetricName" with the correct values based on your instance configuration.
  alarm_name          = "MemoryUsage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/YourCustomNamespace"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "80"
  alarm_description   = "Memory usage exceeds 80%"
  alarm_actions       = [aws_sns_topic.example.arn]
  dimensions = {
    InstanceId = aws_instance.example.id
  }
}

resource "aws_cloudwatch_metric_alarm" "filesystem_usage" {
  alarm_name          = "FilesystemUsage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "20"
  alarm_description   = "Free filesystem space is less than 20%"
  alarm_actions       = [aws_sns_topic.example.arn]
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.example.id
  }
}

resource "aws_cloudwatch_metric_alarm" "db_connections" {
  alarm_name          = "DBConnections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "100"
  alarm_description   = "Database connections exceed 100"
  alarm_actions       = [aws_sns_topic.example.arn]
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.example.id
  }
}

resource "aws_sns_topic" "example" {
  name = "example"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.example.arn
protocol = "email"
endpoint = "you@example.com"
}

resource "aws_instance" "example" {
ami = "ami-0c94855ba95b798c7" # This is an example Amazon Linux 2 AMI ID; replace with the appropriate ID for your region and desired OS.
instance_type = "t2.micro"

tags = {
Name = "example-instance"
}
}

resource "aws_db_instance" "example" {
allocated_storage = 20
storage_type = "gp2"
engine = "mysql"
engine_version = "5.7"
instance_class = "db.t2.micro"
name = "mydb"
username = "exampleuser"
password = "examplepassword"
parameter_group_name = "default.mysql5.7"
skip_final_snapshot = true

tags = {
Name = "example-instance"
}
}

resource "aws_lambda_function" "service_now_integration" {
  function_name = "service_now_integration"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_execution_role.arn

  environment {
    variables = {
      SERVICE_NOW_INSTANCE = "your_service_now_instance"
      SERVICE_NOW_USERNAME = "your_service_now_username"
      SERVICE_NOW_PASSWORD = "your_service_now_password"
    }
  }

  filename = "your_lambda_function_package.zip"
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.example.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.service_now_integration.arn
}

resource "aws_cloudwatch_metric_alarm" "example" {
  alarm_name          = "example"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "1"
  alarm_description   = "This metric checks for high CPU usage"
  alarm_actions       = [aws_sns_topic.example.arn]
  dimensions = {
    InstanceId = aws_instance.example.id
  }
}

resource "aws_sns_topic" "example" {
  name = "example"
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.example.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.service_now_integration.arn
}
