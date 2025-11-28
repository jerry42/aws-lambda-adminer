output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.adminer.function_name
}

output "api_gateway_invoke_url" {
  description = "Invoke URL for the Adminer API"
  value       = "https://${aws_api_gateway_rest_api.adminer.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/adminer.php"
}

output "custom_domain_url" {
  description = "Custom domain URL for the Adminer API"
  value       = "https://${var.domain_name}/adminer.php"
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.php_session_handler.name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.adminer.repository_url
}
