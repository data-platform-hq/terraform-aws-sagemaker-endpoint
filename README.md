# AWS SageMaker Endpoint Terraform module
Terraform module for AWS SageMaker Endpoint creation

## Usage

```hcl
module "sagemaker_endpoint" {
  source  = "data-platform-hq/sagemaker-endpoint/aws"
  version = "~> 1.0"
  
  name = "endpoint1"
  deployment_config = {
    blue_green_update_policy = {
      traffic_routing_configuration = {
        type                     = "ALL_AT_ONCE"
        wait_interval_in_seconds = "600"
        canary_size = {
          type  = "INSTANCE_COUNT"
          value = 3
        }
      }
    }
    auto_rollback_configuration_alarm_names = ["alarm1"]
  }
  
  production_variants = [
    {
      model_name = "model1"
    }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                        | Version  |
|-----------------------------------------------------------------------------|----------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)   | >= 1.0   |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                     | >= 5.1.0 |

## Providers

| Name                                                | Version  |
|-----------------------------------------------------|----------|
| <a name="provider_aws"></a> [aws](#provider\_aws)   | >= 5.1.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                      | Type     |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [aws_sagemaker_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_endpoint)                             | resource |
| [aws_sagemaker_endpoint_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_endpoint_configuration) | resource |

## Inputs

| Name                                                                                                                                                        | Description                                                                                                                                                                                 | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | Default | Required |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create)                                                                                                        | Controls if resources should be created (affects nearly all resources)                                                                                                                      | `bool`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `true`  |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                                                              | A map of tags to add to all resources                                                                                                                                                       | `map(string)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | `{}`    |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                                                                              | The name of the endpoint                                                                                                                                                                    | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | n/a     |   yes    |
| <a name="input_deployment_config"></a> [deployment\_config](#input\_deployment\_config)                                                                     | The deployment configuration for an endpoint, which contains the desired deployment strategy and rollback configurations                                                                    | <pre>object({<br/>  blue_green_update_policy = object({<br/>    traffic_routing_configuration = object({<br/>      type                     = string<br/>      wait_interval_in_seconds = number<br/>      canary_size = optional(object({<br/>        type  = string<br/>        value = number<br/>      }))<br/>      linear_step_size = optional(object({<br/>        type  = string<br/>        value = number<br/>      }))<br/>    })<br/>    maximum_execution_timeout_in_seconds = optional(number)<br/>    termination_wait_in_seconds          = optional(number)<br/>  })<br/>  auto_rollback_configuration_alarm_names = optional(list(string))<br/>})</pre>                                                                                                                                                                                                                                                                                                                 | `null`  |    no    |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn)                                                                                     | Amazon Resource Name (ARN) of a AWS Key Management Service key that Amazon SageMaker uses to encrypt data on the storage volume attached to the ML compute instance that hosts the endpoint | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `null`  |    no    |
| <a name="input_production_variants"></a> [production\_variants](#input\_production\_variants)                                                               | An list of ProductionVariant objects, one for each model that you want to host at this endpoint                                                                                             | <pre>list(object({<br/>  model_name                                        = string<br/>  accelerator_type                                  = optional(string)<br/>  container_startup_health_check_timeout_in_seconds = optional(number)<br/>  core_dump_config = optional(object({<br/>    destination_s3_uri = string<br/>    kms_key_id         = string<br/>  }))<br/>  enable_ssm_access                      = optional(bool)<br/>  initial_instance_count                 = optional(number)<br/>  instance_type                          = optional(string)<br/>  initial_variant_weight                 = optional(string)<br/>  model_data_download_timeout_in_seconds = optional(number)<br/>  serverless_config = optional(object({<br/>    max_concurrency         = number<br/>    memory_size_in_mb       = number<br/>    provisioned_concurrency = number<br/>  }))<br/>  variant_name      = optional(string)<br/>  volume_size_in_gb = optional(number)<br/>}))</pre> | `[]`    |    no    |
| <a name="input_data_capture_config"></a> [data\_capture\_config](#input\_data\_capture\_config)                                                             | Specifies the parameters to capture input/output of SageMaker models endpoints                                                                                                              | <pre>object({<br/>  initial_sampling_percentage = number<br/>  destination_s3_uri          = string<br/>  capture_mode                = string<br/>  kms_key_id                  = optional(string)<br/>  enable_capture              = optional(bool)<br/>  capture_content_type_header = optional(object({<br/>    csv_content_types  = optional(list(string))<br/>    json_content_types = optional(list(string))<br/>  }))<br/>})</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `null`  |    no    |
| <a name="input_async_inference_config"></a> [async\_inference\_config](#input\_async\_inference\_config)                                                    | Specifies configuration for how an endpoint performs asynchronous inference                                                                                                                 | <pre>object({<br/>  output_config = object({<br/>    s3_output_path  = string<br/>    s3_failure_path = optional(string)<br/>    kms_key_id      = optional(string)<br/>    notification_config = optional(object({<br/>      include_inference_response_in = optional(string)<br/>      error_topic                   = optional(string)<br/>      success_topic                 = optional(string)<br/>    }))<br/>  })<br/>  client_config = optional(object({<br/>    max_concurrent_invocations_per_instance = optional(number)<br/>  }))<br/>})</pre>                                                                                                                                                                                                                                                                                                                                                                                                                               | `null`  |    no    |

## Outputs

| Name                                                                                                              | Description                                                                   |
|-------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| <a name="output_arn"></a> [arn](#output\_arn)                                                                     | The Amazon Resource Name (ARN) assigned by AWS to this endpoint               |
| <a name="output_name"></a> [name](#output\_name)                                                                  | The name of the endpoint                                                      |
| <a name="output_config_arn"></a> [config\_arn](#output\_config\_arn)                                              | The Amazon Resource Name (ARN) assigned by AWS to this endpoint configuration |
| <a name="output_config_name"></a> [config\_name](#output\_config\_name)                                           | The name of the endpoint configuration                                        |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](https://github.com/data-platform-hq/terraform-azurerm-linux-web-app/tree/main/LICENSE)

