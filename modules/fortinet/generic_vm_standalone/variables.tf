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
  description = "Region to deploy VM."
}

variable "zone" {
  type        = string
  description = "Zone to deploy VM."
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
  description = "Your predefined host name. If not set, it will be <prefix>-instance."
}

variable "password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Your predefined password. This variable is not available for FortiGuest and FortiAIOps."
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


variable "image" {
  type = object({
    product = optional(string, "")
    version = optional(string, "")
    lic     = optional(string, "payg") # byol, payg
    arch    = optional(string, "x64")  # arm, x64
    family  = optional(string, "")
    source  = optional(string, "")
  })
  validation {
    condition     = var.image.product != "fortigate" || contains(["arm64", "x64"], var.image.arch)
    error_message = "When product is 'fortigate', image.arch must be either 'arm64' or 'x64' (default: 'x64')."
  }
  validation {
    condition     = var.image.product != "fortigate" || contains(["payg", "byol"], var.image.lic)
    error_message = "When product is 'fortigate', image.lic must be either 'payg' or 'byol' (default: 'payg'). If you use the license variable, choose 'byol'."
  }  
  validation {
    condition = (
      (var.image.product != null && var.image.product != "") ||
      (var.image.family != null && var.image.family != "") ||
      (var.image.source != null && var.image.source != "")
    )
    error_message = "At least one of 'product', 'family', or 'source' must be specified and non-empty."
  }
  description = <<-EOF
    Define the parameters for selecting the desired image.

    The `source` field takes the highest priority. If `source` is not specified, `family` will be used.  
    If neither `source` nor `family` is specified, the image will be determined based on the combination of `product`, `version`, `lic`, and `arch`.

    Options:

      - product : (Optional | required) The product name. E.g., "fortigate", "fortianalyzer", "fortimanager", "fortiaiops", "fortiguest".
      - version : (Optional | string | default: "") The desired image version. Example: "7.6.1"
      - lic     : (Optional | string | default: "payg") The license type. Applicable only to FortiGate. Example: "byol" or "payg"
      - arch    : (Optional | string | default: "x64") The architecture type. Applicable only to FortiGate. Example: "arm" or "x64"
      - family  : (Optional | string | default: "") The image family name. Example: "fortigate-76-byol" or "fortigate-76-payg"
      - source  : (Optional | string | default: "") The full source path of a custom image. Example: "projects/fortigcp-project-001/global/images/fortinet-fgt-760-20240726-001-w-license"

    Example:
    ```
    image = {
      product = "fortigate"
      version = "7.6.2"
      lic     = "payg"
      arch    = "x64"
    }
    ```
    OR
    ```
    image = {
      family = "fortigate-76-byol"
    }
    ```
    OR
    ```
    image = {
      source = "projects/fortigcp-project-001/global/images/fortinet-fgtondemand-762-20250130-001-w-license"
    }
    ```
    EOF
}

# licensing
variable "license" {
  type = object({
    license_file    = optional(string, "")
    fortiflex_token = optional(string, "")
  })
  default     = {}
  description = <<-EOF
    If your image.lic is byol (bring your own license), you can license your instance here.
    This variable is not available for FortiGuest and FortiAIOps.

    Options:

      - license_file : (Optional | string | default:"") Location of your own license.
      - fortiflex_token : (Optional | string | default:"") Fortiflex token to activate VM.

    Example:
    ```
    license = {
      license_file = "/path/to/license.lic"
    }
    ```
    OR
    ```
    license = {
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
variable "disks" {
  type = list(object({
    name = optional(string, "")
    size = optional(number, 0)
    type = optional(string, "pd-standard")
  }))
  default = []

  description = <<-EOF
    Additional disks for logging or data.

    Each item in the list represents one disk.

    - name : (Optional | string | default:"") Name of the disk.
    - size : (Optional | number | default:0) Size in GB. If 0, the disk won't be created.
    - type : (Optional | string | default:"pd-standard") Disk type, like "pd-ssd", "pd-balanced", "pd-standard".

    Example:
    ```
    disks = [
      {
        name = "logdisk-1"
        size = 30
        type = "pd-standard"
      },
      {
        size = 50
      }
    ]
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
        subnet_name   = "vpc-public" # The name of your existing subnet.
        private_ip    = "10.0.0.2"                # Optional. The private ip of your FortiGate in this subnet.
                                                  # If not specify private_ip, GCP will select a private IP for you.
        has_public_ip = true                      # Whether port 1 has public IP. Default is False.
      },
      # Port 2 of your FortiGate
      {
        subnet_name = "vpc-private"
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
  The list of network tags attached to this instance.
  GCP firewall rules have "target tags", and these firewall rules only apply to instances with the same tag.
  You can specify instance tags here.
  EOF
}
