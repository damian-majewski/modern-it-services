# Before using the Lambda function, you need to add environment variables:
  `SERVICE_NOW_INSTANCE`
  `SERVICE_NOW_USERNAME`
  `SERVICE_NOW_PASSWORD`
  
The values of these variables will be used to authenticate requests to the ServiceNow API.
  
# This code creates a CloudWatch alarm that monitors CPU usage on an EC2 instance and triggers an SNS notification when it exceeds a specified threshold. The SNS notification is then passed to the Lambda function, which converts it into a ticket in the ServiceNow system.
  
# Remember to update the values in the above Terraform code, such as the EC2 instance identifier, to be appropriate for your infrastructure.
  
# After applying this Terraform code, you can test the integration by observing whether a ticket is created in the ServiceNow system when the CloudWatch alarm is triggered. Make sure you have sufficient permissions for the Lambda function and IAM role to access resources such as SNS and CloudWatch.
  