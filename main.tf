################################################################################
# SageMaker endpoint
################################################################################
resource "aws_sagemaker_endpoint" "this" {
  count                = var.create ? 1 : 0
  endpoint_config_name = aws_sagemaker_endpoint_configuration.this[0].name
  name                 = var.name
  tags                 = var.tags
  dynamic "deployment_config" {
    for_each = var.deployment_config != null ? [1] : []
    content {
      blue_green_update_policy {
        maximum_execution_timeout_in_seconds = var.deployment_config.blue_green_update_policy.maximum_execution_timeout_in_seconds
        termination_wait_in_seconds          = var.deployment_config.blue_green_update_policy.termination_wait_in_seconds

        traffic_routing_configuration {
          type                     = var.deployment_config.blue_green_update_policy.traffic_routing_configuration.type
          wait_interval_in_seconds = var.deployment_config.blue_green_update_policy.traffic_routing_configuration.wait_interval_in_seconds
          dynamic "canary_size" {
            for_each = var.deployment_config.blue_green_update_policy.traffic_routing_configuration.canary_size != null ? [1] : []
            content {
              type  = var.deployment_config.blue_green_update_policy.traffic_routing_configuration.canary_size.type
              value = var.deployment_config.blue_green_update_policy.traffic_routing_configuration.canary_size.value
            }
          }
          dynamic "linear_step_size" {
            for_each = var.deployment_config.blue_green_update_policy.traffic_routing_configuration.linear_step_size != null ? [1] : []
            content {
              type  = var.deployment_config.blue_green_update_policy.traffic_routing_configuration.linear_step_size.type
              value = var.deployment_config.blue_green_update_policy.traffic_routing_configuration.linear_step_size.value
            }
          }
        }
      }
      dynamic "auto_rollback_configuration" {
        for_each = var.deployment_config.auto_rollback_configuration_alarm_names != null ? [1] : []
        content {
          dynamic "alarms" {
            for_each = var.deployment_config.auto_rollback_configuration_alarm_names
            content {
              alarm_name = alarms.value
            }
          }
        }
      }
    }
  }
}

################################################################################
# SageMaker endpoint configuration
################################################################################
resource "aws_sagemaker_endpoint_configuration" "this" {
  count       = var.create ? 1 : 0
  name_prefix = "${var.name}-config"
  tags        = var.tags
  kms_key_arn = var.kms_key_arn
  dynamic "production_variants" {
    for_each = var.production_variants
    content {
      model_name                                        = production_variants.value.model_name
      accelerator_type                                  = production_variants.value.accelerator_type
      container_startup_health_check_timeout_in_seconds = production_variants.value.container_startup_health_check_timeout_in_seconds
      enable_ssm_access                                 = production_variants.value.enable_ssm_access
      initial_instance_count                            = production_variants.value.initial_instance_count
      instance_type                                     = production_variants.value.instance_type
      initial_variant_weight                            = production_variants.value.initial_variant_weight
      model_data_download_timeout_in_seconds            = production_variants.value.model_data_download_timeout_in_seconds
      variant_name                                      = production_variants.value.variant_name
      volume_size_in_gb                                 = production_variants.value.volume_size_in_gb
      dynamic "serverless_config" {
        for_each = production_variants.value.serverless_config != null ? [1] : []
        content {
          max_concurrency         = production_variants.value.serverless_config.max_concurrency
          memory_size_in_mb       = production_variants.value.serverless_config.memory_size_in_mb
          provisioned_concurrency = production_variants.value.serverless_config.provisioned_concurrency
        }
      }
      dynamic "core_dump_config" {
        for_each = production_variants.value.core_dump_config != null ? [1] : []
        content {
          destination_s3_uri = production_variants.value.core_dump_config.destination_s3_uri
          kms_key_id         = production_variants.value.core_dump_config.kms_key_id
        }
      }
    }
  }

  dynamic "data_capture_config" {
    for_each = var.data_capture_config != null ? [1] : []
    content {
      initial_sampling_percentage = var.data_capture_config.initial_sampling_percentage
      destination_s3_uri          = var.data_capture_config.destination_s3_uri
      kms_key_id                  = var.data_capture_config.kms_key_id
      enable_capture              = var.data_capture_config.enable_capture
      dynamic "capture_content_type_header" {
        for_each = var.data_capture_config.capture_content_type_header != null ? [1] : []
        content {
          csv_content_types  = var.data_capture_config.capture_content_type_header.csv_content_types
          json_content_types = var.data_capture_config.capture_content_type_header.json_content_types
        }
      }
      dynamic "capture_options" {
        for_each = var.data_capture_config.capture_mode != null ? [1] : []
        content {
          capture_mode = var.data_capture_config.capture_mode
        }
      }
    }
  }
  dynamic "async_inference_config" {
    for_each = var.async_inference_config != null ? [1] : []
    content {
      output_config {
        s3_output_path  = var.async_inference_config.output_config.s3_output_path
        s3_failure_path = var.async_inference_config.output_config.s3_failure_path
        kms_key_id      = var.async_inference_config.output_config.kms_key_id
        dynamic "notification_config" {
          for_each = var.async_inference_config.output_config.notification_config != null ? [1] : []
          content {
            include_inference_response_in = var.async_inference_config.output_config.notification_config.include_inference_response_in
            error_topic                   = var.async_inference_config.output_config.notification_config.error_topic
            success_topic                 = var.async_inference_config.output_config.notification_config.success_topic
          }
        }
      }
      dynamic "client_config" {
        for_each = var.async_inference_config.client_config != null ? [1] : []
        content {
          max_concurrent_invocations_per_instance = var.async_inference_config.client_config.max_concurrent_invocations_per_instance
        }
      }
    }
  }
}
