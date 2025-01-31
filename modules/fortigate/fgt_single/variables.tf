# Project vars
variable "prefix" {
  type        = string
  description = "Prefix of the objects in this module"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.prefix)) || var.prefix == ""
    error_message = "The prefix must start with a letter and can only contain lower case letters, numbers, and hyphens."
  }
}

variable "region" {
  type        = string
  description = "Region to deploy FortiGate."
}

variable "zone" {
  type        = string
  description = "Zone to deploy FortiGate."
}

# IAM
variable "service_account_email" {
  type        = string
  default     = ""  
  description = <<-EOF
  The e-mail address of the service account used for VMs. Example value: 1234567-compute@developer.gserviceaccount.com
  If not given, the default Google Compute Engine service account is used.
  EOF 
}

# FGT vars
variable "hostname" {
  type        = string
  default     = ""
  description = "Host name. If not set, it will be <prefix>-instance."
}

variable "password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Password. If not set, it will be the instance id."
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
  default     = ""
  description = <<-EOF
  The type of public FortiGate Image. Example: "fortigate-76-byol" or "fortigate-76-payg"
  One of the variables "image_type" and "image_source" must be provided, otherwise an error occurs. If both are provided, "image_source" will be used.
  Use the following command to check all FortiGate image type:
  `gcloud compute images list --project=fortigcp-project-001 --filter="family:fortigate*" --format="table[no-heading](family)" | sort | uniq`

  fortigate-76-byol : FortiGate 7.6, bring your own licenses.
  
  fortigate-76-payg : FortiGate 7.6, don't need to provide licenses, pay as you go.
  EOF
}

variable "image_source" {
  type        = string
  default     = ""
  description = <<-EOF
  The source of the custom image. Example: "projects/fortigcp-project-001/global/images/fortinet-fgt-760-20240726-001-w-license"
  One of the variables "image_type" and "image_source" must be provided, otherwise an error occurs. If both are provided, "image_source" will be used.
  EOF
}

# licensing
variable "licensing" {
  type = object({
    license_file    = optional(string, "")
    fortiflex_token = optional(string, "")
  })
  default     = {}
  description = <<-EOF
    If your image type is byol (bring your own license), you can license your FortiGate here.

    Options:

        - license_file : (Optional | string | default:"") Location of your own license.
        - fortiflex_token : (Optional | string | default:"") Fortiflex token to activate VM.

    Example:
    ```
    licensing = {
      license_file = "/path/to/license.lic"
    }
    ```
    OR
    ```
    licensing = {
      fortiflex_token = "<fortiflex token>"
    }
    ```
  EOF
}

variable "config_script" {
  type        = string
  default     = ""
  description = "Additional FortiGate configuration script."
}

variable "config_file" {
  type        = string
  default     = ""
  description = "Additional FortiGate configuration script file."
}

# Disk
variable "additional_disk" {
  type = object({
    name = optional(string, "")
    size = optional(number, 0)
    type = optional(string, "pd-standard")
  })
  default     = {}
  description = <<-EOF
    Additional disk for logging.

    Options:

        - name : (Optional | string | default:"") Name of your log disk.
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
    public_ip     = optional(string, "")
    private_ip    = optional(string, "")
  }))
  default     = []
  description = <<-EOF
    Network interfaces.

    Options:

        - subnet_name   : (Required | string | default:"") The name of your existing subnet.
        - has_public_ip : (Optional | bool | default:false) Whether this port has public IP. Default is False.
        - public_ip     : (Optional | string | default:"") You can specify the public IP of your interface. Only available if has_public_ip is true.
        - private_ip    : (Optional | string | default:"") The private ip of your FortiGate in this subnet. If not specify private_ip, GCP will select a private IP for you.

    Example:
    ```
    network_interfaces = [                        # Network interface of your FortiGate
      # Port 1 of your FortiGate
      {
        subnet_name   = "single-fortigate-public" # The name of your existing subnet.
        private_ip    = "10.0.0.2"                # Optional. The private ip of your FortiGate in this subnet.
                                                  # If not specify private_ip, GCP will select a private IP for you.
        has_public_ip = true                      # Whether port 1 has public IP. Default is False.
      },
      # Port 2 of your FortiGate
      {
        subnet_name = "single-fortigate-private"
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
