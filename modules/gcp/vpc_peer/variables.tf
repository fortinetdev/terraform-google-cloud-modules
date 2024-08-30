variable "prefix" {
  type        = string
  description = "Prefix of all objects in this module. It can be empty string."
  default     = ""
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.prefix)) || var.prefix == ""
    error_message = "The prefix must start with a letter and can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "vpc1_name" {
  type        = string
  description = "If vpc1_network is specified, vpc1_name can be a nickname, otherwise, it should be the name of the first VPC."
}

variable "vpc2_name" {
  type        = string
  description = "If vpc2_network is specified, vpc2_name can be a nickname, otherwise, it should be the name of the second VPC."
}

variable "vpc1_network" {
  type        = string
  default     = ""
  description = "The self link of the first VPC. If not specified, vpc1_name is used to query its selflink."
}

variable "vpc2_network" {
  type        = string
  default     = ""
  description = "The self link of the second VPC. If not specified, vpc2_name is used to query its selflink."
}

variable "vpc1_to_vpc2" {
  type = object({
    export_custom_routes                = optional(bool, false)
    import_custom_routes                = optional(bool, false)
    export_subnet_routes_with_public_ip = optional(bool, true)
    import_subnet_routes_with_public_ip = optional(bool, false)
  })
  default     = {}
  description = <<-EOF
    Config export/import routing policy for forward direction.
    Options:

        - export_custom_routes : (Optional | bool | default:false) Whether to export the custom routes to the peer network.
        - import_custom_routes : (Optional | bool | default:false) Whether to import the custom routes from the peer network.
        - export_subnet_routes_with_public_ip : (Optional | bool | default:true) Whether subnet routes with public IP range are exported.
        - import_subnet_routes_with_public_ip : (Optional, | bool | default:false) Whether subnet routes with public IP range are imported.

    Example:

    ```
    vpc1_to_vpc2 = {
      export_custom_routes = true
      import_custom_routes = false
    }
    ```
  EOF
}

variable "vpc2_to_vpc1" {
  type = object({
    export_custom_routes                = optional(bool, false)
    import_custom_routes                = optional(bool, false)
    export_subnet_routes_with_public_ip = optional(bool, true)
    import_subnet_routes_with_public_ip = optional(bool, false)
  })
  default     = {}
  description = <<-EOF
    Config export/import routing policy for backforward direction.
    Options:

        - export_custom_routes : (Optional | bool | default:false) Whether to export the custom routes to the peer network.
        - import_custom_routes : (Optional | bool | default:false) Whether to import the custom routes from the peer network.
        - export_subnet_routes_with_public_ip : (Optional | bool | default:true) Whether subnet routes with public IP range are exported.
        - import_subnet_routes_with_public_ip : (Optional | bool | default:false) Whether subnet routes with public IP range are imported.

    Example:

    ```
    vpc2_to_vpc1 = {
      export_custom_routes = false
      import_custom_routes = true
    }
    ```
  EOF
}
