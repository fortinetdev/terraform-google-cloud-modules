# Project vars
variable "prefix" {
  type        = string
  description = "Prefix of all objects in this module. It should be unique to avoid name conflict between projects."
  validation {
    condition     = (can(regex("^[a-z][a-z0-9-]*$", var.prefix)) || var.prefix == "") && length(var.prefix) <= 15
    error_message = "The prefix must start with a letter, can only contain lowercase letters, numbers, and hyphens, and must not exceed 15 characters."
  }
}

variable "region" {
  type        = string
  description = "Region to deploy VM."
}

variable "zones" {
  type        = list(string)
  description = <<-EOF
  Deploy the project to multiple zones for higher availability.
  Two zone are required. If it is not specified, this module will select 2 zones for you.
  EOF  
  default     = []
}

variable "ha_mode" {
  type        = string
  default     = null
  description = <<-EOF
  HA mode of FortiGate. Options: "fgcp-ap" (FGCP active-passive) or "fgsp-aa" (FGSP active-active).
  EOF
  validation {
    condition     = can(regex("^(fgcp-ap|fgsp-aa)$", var.ha_mode))
    error_message = "The ha_mode must be either 'fgcp-ap' (FGCP active-passive) or 'fgsp-aa' (FGSP active-active)."
  }
}

# IAM
variable "service_account_email" {
  type        = string
  default     = ""
  description = <<-EOF
  Example value: 1234567-compute@developer.gserviceaccount.com
  The e-mail address of the service account. This service account will control the cloud function created by this project.
  If this variable is not specified, the default Google Compute Engine service account is used.
  EOF 
}

# FGT vars
variable "hostname" {
  type        = string
  default     = ""
  description = "FGT hostname. If not set, an FGT's hostname will be its license ID."
}

variable "fgt_password" {
  type        = string
  default     = ""
  sensitive   = true
  description = <<-EOF
  Password for all FGTs (user name is admin). It must be at lease 8 characters long if specified.
  If this variable is not set, an FGT's password will be its instance ID.
  EOF

  validation {
    condition = (
      var.fgt_password == "" || length(var.fgt_password) > 8
    )
    error_message = "The fgt_password must be at least 8 characters long if specified."
  }
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
  default     = "fortigate-76-byol"
  description = <<-EOF
  The type of public FortiGate Image. Example: "fortigate-76-byol" or "fortigate-76-payg"
  One of the variables "image_type" and "image_source" must be provided, otherwise an error occurs. If both are provided, "image_source" will be used.
  Use the following command to check all FGT image type:
  `gcloud compute images list --project=fortigcp-project-001 --filter="family:fortigate*" --format="table[no-heading](family)" | sort | uniq`

  fortigate-76-byol : FortiGate 7.6, bring your own licenses.
  
  fortigate-76-payg : FortiGate 7.6, don't need to provide licenses, pay as you go.
  EOF
}

variable "image_source" {
  type        = string
  default     = ""
  description = <<-EOF
  The source of the custom image. Example: "projects/fortigcp-project-001/global/images/fortinet-fgt-763-20250423-001-w-license"
  One of the variables "image_type" and "image_source" must be provided, otherwise an error occurs. If both are provided, "image_source" will be used.
  EOF
}

# Disk
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
variable "network_interfaces" {
  type = list(object({
    subnet_name   = string
    has_public_ip = optional(bool, false)
    elb_ip        = optional(list(string), [])
    ilb_ip        = optional(list(string), [])
  }))
  description = <<-EOF
  List of Network Interfaces.

  Options:

      - subnet_name   : (Required | string) The name of your existing subnet.
      - has_public_ip : (Optional | bool | default:false) Whether this port has public IP. Default is False.
      - elb_ip        : (Optional | list of string | default:[]) If this interface connects to an external load balancer (ELB), specify the IP of the existing ELB here.
      - ilb_ip        : (Optional | list of string | default:[]) If this interface connects to an internal load balancer (ILB), specify the IP of the existing ILB here.

  Example:
  ```
  network_interfaces = [
    # Port 1 of your FortiGate
    {
      subnet_name   = "vpc-external"
      has_public_ip = true
      elb_ip        = google_compute_address.elb_ip.address
    },
    # Port 2 of your FortiGate.
    {
      subnet_name   = "vpc-internal"
      ilb_ip        = google_compute_address.ilb_ip.address
    },
    # You can specify more ports here
    # ...
  ]
  ```
  EOF
}

variable "network_tags" {
  type        = list(string)
  default     = []
  description = <<-EOF
  The list of network tags attached to FortiGates.
  GCP firewall rules have "target tags", and these firewall rules only apply to instances with the same tag.
  You can specify instance tags here.
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
  description = "Additional FortiGate configuration script file."
}

# license
variable "license" {
  type = object({
    license_file    = optional(list(string), ["", ""])
    fortiflex_token = optional(list(string), ["", ""])
  })
  default     = {}
  description = <<-EOF
    If your image type is byol (bring your own license), you can license your FortiGate here.

    Options:

        - license_file : (Optional | list of string | default:["", ""]) Location of your own license.
        - fortiflex_token : (Optional | list of string | default:["", ""]) Fortiflex tokens to activate VM.

    Example:
    ```
    license = {
      license_file = ["/path/to/license1.lic", "/path/to/license2.lic"]
    }
    ```
    OR
    ```
    license = {
      fortiflex_token = ["<fortiflex token 1>", "<fortiflex token 2>"]
    }
    ```
  EOF
}

# port
variable "ha_port" {
  type        = string
  nullable    = true
  default     = null
  description = <<-EOF
  HA port. Provide value as FortiGate port name (eg. \"port4\").
  By default, it is the last port of your FGTs. It is not recommended to set it to port1.
EOF
}

variable "mgmt_port" {
  type        = string
  nullable    = true
  default     = null
  description = <<-EOF
  The management port. Provide value as FortiGate port name (eg. \"port4\").
  By default, it is the last port of your FGTs. It is not recommended to set it to port1.
EOF
}

variable "ha_password" {
  type        = string
  default     = ""
  sensitive   = true
  description = <<-EOF
  Password used for HA. This variable is only used when ha_mode is "fgcp-ap".
  EOF
}
