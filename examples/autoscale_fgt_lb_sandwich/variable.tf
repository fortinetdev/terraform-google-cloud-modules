# Project vars
variable "project" {
  type        = string
  description = "Your GCP project name."
}

variable "region" {
  type        = string
  description = "The region to deploy the project."
}

variable "zone" {
  type        = string
  description = "The zone to deploy the project."
}

variable "prefix" {
  type        = string
  description = "Prefix of the objects in this project. It should be unique to avoid name conflict between projects."
}

# FGT vars
variable "fgt_password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Password for all FGTs (user name is admin). If no password is set, the module will randomly generate a 16-character password."
}

variable "machine_type" {
  type        = string
  description = <<-EOF
    The Virtual Machine type to deploy FGT. Example of predefined type: n1-standard-4, n2-standard-8, ...

    Custom machine types can be formatted as custom-NUMBER_OF_CPUS-AMOUNT_OF_MEMORY_MB,
    e.g. custom-6-20480 for 6 vCPU and 20GB of RAM.

    There is a limit of 6.5 GB per CPU unless you add extended memory. You must do this explicitly by adding the suffix -ext,
    e.g. custom-2-15360-ext for 2 vCPU and 15 GB of memory.
  EOF
}

variable "image_type" {
  type        = string
  default     = "fortigate-74-byol"
  description = <<-EOF
  FGT Image type.
  Use the following command to check all FGT image type:
  "gcloud compute images list --project=fortigcp-project-001 --filter="family:fortigate*" --format="table[no-heading](family)" | sort | uniq"

  fortigate-74-byol : FortiGate 7.4, bring your own licenses.
  
  fortigate-74-payg : FortiGate 7.4, don't need to provide licenses, pay as you go.
  EOF
}

variable "fgt_has_public_ip" {
  type        = bool
  default     = false
  description = "If set to true, port1 of all FGTs will have a public IP."
}

variable "additional_disk" {
  type = object({
    size = optional(number, 0)
    type = optional(string, "pd-standard")
  })
  default = {
    size = 0
    type = "pd-standard"
  }
  description = <<-EOF
    Additional disk for logging.

    Options:

        - size : (Optional | number | default:0) Log disk size (GB) for each FGT. If set to 0, no additional log disk is created.
        - type : (Optional | string | default:"pd-standard") The Google Compute Engine disk type. Such as "pd-ssd", "local-ssd", "pd-balanced" or "pd-standard".

    Example:
    ```
    additional_disk = {
      size = 30
      type = "pd-standard"
    }
    ```
  EOF
}

# Network
variable "external_subnet" {
  type        = string
  description = "The CIDR of the external VPC for this project. This IP range is used only for FGTs."
}

variable "internal_subnet" {
  type        = string
  description = "The CIDR of the internal VPC for this project. This IP range is used only for FGTs and internal load balancer."
}

# User network information
variable "protected_vpc" {
  type = list(object({
    name = string
  }))
  default     = []
  description = <<-EOF
    List of your existing VPCs. These VPCs should not have a default route ("0.0.0.0/0"), otherwise their traffic will not be sent to the FGT.
  
    If specified, your VPC will be peered with the this project's internal VPC.
    And outbound and inbound traffic from these VPCs will first go through the FGTs.

    Options:

      - name : (Required | string) Name of your existing VPC.

  EOF
}

# LB
variable "load_balancer" {
  type = object({
    health_check_port = optional(number, 8008)
    internal_lb = optional(object({
      front_end_ip      = optional(string, "")
      frontend_protocol = optional(string, "TCP")
      backend_protocol  = optional(string, "TCP")
      }), {}
    )
    external_lb = optional(object({
      frontend_protocol = optional(string, "TCP")
      backend_protocol  = optional(string, "TCP")
      }), {}
    )
  })
  default     = {}
  description = <<-EOF
    Parameters for external and internal load balancers.

    Options:

        - health_check_port : (Optional | number | default:8008) The port to be used for health check.
        - internal_lb : (Optional | object) The parameters of internal load balancer.
            - front_end_ip : (Optional | string | default:"") Front end IP of the internal load balancer. It should be in the internal subnet IP range. Set by the API if undefined.
            - frontend_protocol : (Optional | string | default:"TCP") Protocol of the front-end forwarding rule. Valid options are TCP, UDP, ESP, AH, SCTP, ICMP and L3_DEFAULT.
            - backend_protocol : (Optional | string | default:"TCP") The protocol the load balancer uses to communicate with the backend. Valid options are HTTP, HTTPS, HTTP2, SSL, TCP, UDP, GRPC, UNSPECIFIED.
        - external_lb : (Optional | object) The parameters of external load balancer.
            - frontend_protocol : (Optional | string | default:"TCP") Protocol of the front-end forwarding rule. Valid options are TCP, UDP, ESP, AH, SCTP, ICMP and L3_DEFAULT.
            - backend_protocol : (Optional | string | default:"TCP") The protocol the load balancer uses to communicate with the backend. Valid options are HTTP, HTTPS, HTTP2, SSL, TCP, UDP, GRPC, UNSPECIFIED.

    Example:
    ```
    load_balancer = {
      health_check_port = 8008
      internal_lb = {
        front_end_ip      = "10.0.1.100"
        frontend_protocol = "TCP"
        backend_protocol  = "TCP"
      }
      external_lb = {
        frontend_protocol = "TCP"
        backend_protocol  = "TCP"
      }
    }
    ```
  EOF
}


# Cloud function
variable "cloud_function" {
  type = object({
    function_ip_range   = string
    license_source      = optional(string, "none")
    license_file_folder = optional(string, "./licenses")
    autoscale_psksecret = optional(string, "psksecret")
    print_debug_msg     = optional(bool, false)
    fortiflex = optional(object({
      retrieve_mode = optional(string, "use_stopped")
      username      = optional(string, "")
      password      = optional(string, "")
      config        = optional(string, "")
    }), {})
    service_config = optional(object({
      max_instance_count               = optional(number, 1)
      max_instance_request_concurrency = optional(number, 1)
      available_cpu                    = optional(string, "1")
      available_memory                 = optional(string, "1G")
      timeout_seconds                  = optional(number, 240)
    }), {})
  })
  description = <<-EOF
    Parameters for cloud function. The cloud function is used to inject licenses to FGTs,
    upload user-specified configurations and manage the FGT autoscale group.

    Options:

        - function_ip_range : (Required | string) Cloud function needs to have its only CIDR ip range ending with "/28", which cannot be used by other resources. Example "10.1.0.0/28".
          This IP range subnet cannot be used by other resources, such as VMs, Private Service Connect, or load balancers.
        - license_source : (Optional | string | default:"none") The source of license if your image_type is "byol".
            "none" : Don't inject licenses to FGTs.
            "file" : Injecting licenses based on license files. All license files should be in license_file_folder.
            "fortiflex" : Injecting licenses based on FortiFlex. Need to specify the parameter fortiflex if license_source is "fortiflex".
            "file_fortiflex" : Injecting licenses based on license files first. If all license files are in use, try FortiFlex next.
        - license_file_folder : (Optional | string | default:"./licenses") The folder where all ".lic" license files are located. Default is "./licenses" folder.
        - autoscale_psksecret : (Optional | string | default:"psksecret") The secret key used to synchronize information between FortiGates. If not set, the module will randomly generate a 16-character secret key.
        - print_debug_msg : (Optional | bool | default:false) If set to true, the cloud function will print debug messages. You can find these messages in Google Cloud Logs Explorer.
        - fortiflex: (Optional | object) You need to specify this parameter if your license_source is "fortiflex" or "file_fortiflex".
            - retrieve_mode : (Optional | string | default:"use_stopped") How to retrieve an existing fortiflex license (entitlement):
                "use_stopped" selects and reactivates a stopped entitlement where the description field is empty;
                "use_active" selects one active and unused entitlement where the description field is empty.
            - username : (Reuqired if license_source is "fortiflex" or "file_fortiflex" | string | default:"") The username of your FortiFlex account.
            - password : (Reuqired if license_source is "fortiflex" or "file_fortiflex" | string | default:"") The password of your FortiFlex account.
            - config : (Reuqired if license_source is "fortiflex" or "file_fortiflex" | string | default:"") The configuration ID of your FortiFlex configuration (product type should be FortiGate-VM).
        - service_config : (Optional | object) This parameter controls the instance that runs the cloud function.
            - max_instance_count : (Optional | number | default:1) The limit on the maximum number of function instances that may coexist at a given time.
            - max_instance_request_concurrency : (Optional | number | default:1) Sets the maximum number of concurrent requests that each instance can receive.
            - available_cpu : (Optional | string | default:"1") The number of CPUs used in a single container instance.
            - available_memory : (Optional | string | default:"1G") The amount of memory available for a function. Supported units are k, M, G, Mi, Gi. If no unit is supplied the value is interpreted as bytes.
            - timeout_seconds : (Optional | number | default:240) The function execution timeout. Execution is considered failed and can be terminated if the function is not completed at the end of the timeout period.
    
    Example:
    ```
    cloud_function = {
      function_ip_range      = "10.1.0.0/28"
      license_source         = "file_fortiflex" # "none", "fortiflex", "file", "file_fortiflex"
      license_file_folder    = "./licenses"
      autoscale_psksecret    = "psksecret"
      # Specify fortiflex parameters if license_source is "fortiflex" or "file_fortiflex"
      fortiflex = {
        retrieve_mode = "use_activate"
        username      = "Your fortiflex username"
        password      = "Your fortiflex password"
        config        = "Your fortiflex configuration ID"
      }
      # Parameters of google cloud function.
      service_config = {
        max_instance_request_concurrency = 2
        timeout_seconds                  = 360
      }
    }
    ```
  EOF
}

# AutoScaler
variable "autoscaler" {
  type = object({
    max_instances   = number
    min_instances   = optional(number, 2)
    cooldown_period = optional(number, 300)
    cpu_utilization = optional(number, 0.9)
  })
  description = <<-EOF
    Auto Scaler parameters. This variable controls when to autoscale and the maximum number of instances.
    Options:

        - max_instances   : (Required | number) The maximum number of FGT instances.
        - min_instances   : (Optional | number | default:2) The minimum number of FGT instances.
        - cooldown_period : (Optional | number | default:300) Specify how long (seconds) it takes for FGT to initialize from boot time until it is ready to serve.
        - cpu_utilization : (Optional | number | default:0.9) Autoscaling signal. If cpu utilization above this value, google cloud will create new FGT instance.

    Example:
    ```
    autoscaler = {
        max_instances   = 10
        min_instances   = 2
        cooldown_period = 300
        cpu_utilization = 0.9
    }
    ```
    EOF
}

variable "config_script" {
  type        = string
  default     = ""
  description = "Additional FGT configuration script."
}

variable "config_file" {
  type        = string
  default     = ""
  description = "Additional FGT configuration script file."
}
