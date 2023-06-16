################################################################################
# SageMaker endpoint
################################################################################
output "arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this endpoint"
  value       = try(aws_sagemaker_endpoint.this[0].arn, null)
}

output "name" {
  description = "The name of the endpoint"
  value       = try(aws_sagemaker_endpoint.this[0].name, null)
}

################################################################################
# SageMaker endpoint configuration
################################################################################

output "config_arn" {
  description = "The Amazon Resource Name (ARN) assigned by AWS to this endpoint configuration"
  value       = try(aws_sagemaker_endpoint_configuration.this[0].arn, null)
}

output "config_name" {
  description = "The name of the endpoint configuration"
  value       = try(aws_sagemaker_endpoint_configuration.this[0].name, null)
}
