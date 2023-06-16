variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# SageMaker endpoint
################################################################################
variable "name" {
  description = "The name of the endpoint"
  type        = string
}

variable "deployment_config" {
  description = "The deployment configuration for an endpoint, which contains the desired deployment strategy and rollback configurations"
  type = object({
    blue_green_update_policy = object({        # Update policy for a blue/green deployment
      traffic_routing_configuration = object({ # Defines the traffic routing strategy to shift traffic from the old fleet to the new fleet during an endpoint deployment
        type                     = string      # Traffic routing strategy type. Valid values are: ALL_AT_ONCE, CANARY, and LINEAR
        wait_interval_in_seconds = number      # The waiting time (in seconds) between incremental steps to turn on traffic on the new endpoint fleet. Valid values are between 0 and 3600
        canary_size = optional(object({        # Batch size for the first step to turn on traffic on the new endpoint fleet
          type  = string                       # Specifies the endpoint capacity type. Valid values are: INSTANCE_COUNT, or CAPACITY_PERCENT
          value = number                       # Defines the capacity size, either as a number of instances or a capacity percentage
        }))
        linear_step_size = optional(object({ # Batch size for each step to turn on traffic on the new endpoint fleet
          type  = string                     # Specifies the endpoint capacity type. Valid values are: INSTANCE_COUNT, or CAPACITY_PERCENT
          value = number                     # Defines the capacity size, either as a number of instances or a capacity percentage
        }))
      })
      maximum_execution_timeout_in_seconds = optional(number) # Maximum execution timeout for the deployment
      termination_wait_in_seconds          = optional(number) # Additional waiting time in seconds after the completion of an endpoint deployment before terminating the old endpoint fleet
    })
    auto_rollback_configuration_alarm_names = optional(list(string)) #  List of CloudWatch alarms in your account that are configured to monitor metrics on an endpoint
  })
  default = null
}

################################################################################
# SageMaker endpoint configuration
################################################################################
variable "kms_key_arn" {
  description = "Amazon Resource Name (ARN) of a AWS Key Management Service key that Amazon SageMaker uses to encrypt data on the storage volume attached to the ML compute instance that hosts the endpoint"
  type        = string
  default     = null
}

variable "production_variants" {
  description = "An list of ProductionVariant objects, one for each model that you want to host at this endpoint"
  type = list(object({
    model_name                                        = string           # The name of the model to use
    accelerator_type                                  = optional(string) # The size of the Elastic Inference (EI) instance to use for the production variant
    container_startup_health_check_timeout_in_seconds = optional(number) # The timeout value, in seconds, for your inference container to pass health check by SageMaker Hosting
    core_dump_config = optional(object({                                 # Specifies configuration for a core dump from the model container when the process crashes
      destination_s3_uri = string                                        # The Amazon S3 bucket to send the core dump to
      kms_key_id         = string                                        # The Amazon Web Services Key Management Service (Amazon Web Services KMS) key that SageMaker uses to encrypt the core dump data at rest using Amazon S3 server-side encryption
    }))
    enable_ssm_access                      = optional(bool)   # You can use this parameter to turn on native Amazon Web Services Systems Manager (SSM) access for a production variant behind an endpoint
    initial_instance_count                 = optional(number) # Initial number of instances used for auto-scaling
    instance_type                          = optional(string) # The type of instance to start
    initial_variant_weight                 = optional(string) #  Determines initial traffic distribution among all of the models that you specify in the endpoint configuration
    model_data_download_timeout_in_seconds = optional(number) # The timeout value, in seconds, to download and extract the model that you want to host from Amazon S3 to the individual inference instance associated with this production variant
    serverless_config = optional(object({                     # Specifies configuration for how an endpoint performs asynchronous inference
      max_concurrency         = number                        # The maximum number of concurrent invocations your serverless endpoint can process. Valid values are between 1 and 200
      memory_size_in_mb       = number                        # The memory size of your serverless endpoint. Valid values are in 1 GB increments: 1024 MB, 2048 MB, 3072 MB, 4096 MB, 5120 MB, or 6144 MB
      provisioned_concurrency = number                        # The amount of provisioned concurrency to allocate for the serverless endpoint. Should be less than or equal to max_concurrency. Valid values are between 1 and 200
    }))
    variant_name      = optional(string) # The name of the variant. If omitted, Terraform will assign a random, unique name
    volume_size_in_gb = optional(number) # The size, in GB, of the ML storage volume attached to individual inference instance associated with the production variant. Valid values between 1 and 512
  }))
  default = []
}

variable "data_capture_config" {
  description = "Specifies the parameters to capture input/output of SageMaker models endpoints"
  type = object({
    initial_sampling_percentage = number           # Portion of data to capture. Should be between 0 and 100
    destination_s3_uri          = string           # The URL for S3 location where the captured data is stored
    capture_mode                = string           # Specifies the data to be captured. Should be one of Input or Output
    kms_key_id                  = optional(string) # Amazon Resource Name (ARN) of a AWS Key Management Service key that Amazon SageMaker uses to encrypt the captured data on Amazon S3
    enable_capture              = optional(bool)   #  Flag to enable data capture
    capture_content_type_header = optional(object({
      csv_content_types  = optional(list(string)) # The CSV content type headers to capture
      json_content_types = optional(list(string)) # The JSON content type headers to capture
    }))
  })
  default = null
}

variable "async_inference_config" {
  description = "Specifies configuration for how an endpoint performs asynchronous inference"
  type = object({
    output_config = object({                             # Specifies the configuration for asynchronous inference invocation outputs
      s3_output_path  = string                           # The Amazon S3 location to upload inference responses to
      s3_failure_path = optional(string)                 # The Amazon S3 location to upload failure inference responses to
      kms_key_id      = optional(string)                 # The Amazon Web Services Key Management Service (Amazon Web Services KMS) key that Amazon SageMaker uses to encrypt the asynchronous inference output in Amazon S3
      notification_config = optional(object({            # Specifies the configuration for notifications of inference results for asynchronous inference
        include_inference_response_in = optional(string) #  The Amazon SNS topics where you want the inference response to be included. Valid values are SUCCESS_NOTIFICATION_TOPIC and ERROR_NOTIFICATION_TOPIC
        error_topic                   = optional(string) # Amazon SNS topic to post a notification to when inference fails
        success_topic                 = optional(string) # Amazon SNS topic to post a notification to when inference completes successfully
      }))
    })
    client_config = optional(object({                            # Configures the behavior of the client used by Amazon SageMaker to interact with the model container during asynchronous inference
      max_concurrent_invocations_per_instance = optional(number) # The maximum number of concurrent requests sent by the SageMaker client to the model container
    }))
  })
  default = null
}
