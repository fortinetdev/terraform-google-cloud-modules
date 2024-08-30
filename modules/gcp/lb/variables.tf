variable "prefix" {
  type        = string
  default     = ""
  description = "Prefix of all objects in this module."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.prefix)) || var.prefix == ""
    error_message = "The prefix must start with a letter and can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "region" {
  type        = string
  description = "Region to deploy LB."
}

variable "backends_list" {
  type        = list(string)
  description = "List of backend self link."
}

variable "schema" {
  type = string
  validation {
    condition     = contains(["EXTERNAL", "EXTERNAL_MANAGED", "INTERNAL", "INTERNAL_MANAGED"], var.schema)
    error_message = "Invalid load balancing scheme. Valid values are EXTERNAL, EXTERNAL_MANAGED, INTERNAL, INTERNAL_MANAGED."
  }
  description = "The load balancing scheme to use. Valid values are EXTERNAL, EXTERNAL_MANAGED, INTERNAL, INTERNAL_MANAGED."
}

variable "ilb" {
  type = object({
    network_id = optional(string, "")
    subnet_id  = optional(string, "")
  })
  default     = {}
  description = <<-EOF
    Configuration for internal load balancer. If schema is "INTERNAL", this ilb variable is needed.

    Options:

        - network_id : (Required if schema is "INTERNAL" | string | default:"") ID or self_link of the network to deploy internal load balancer.
        - subnet_id  : (Required if schema is "INTERNAL" | string | default:"") ID or self_link of the subnet to deploy internal load balancer.

    Example:

    ```
    ilb = {
      network_id = <ID or self_link of the network>
      subnet_id  = <ID or self_link of the subnet>
    }
    ```
    EOF
}

variable "front_end_ip" {
  type        = string
  default     = ""
  description = "Front end ip. If not set, the front end ip will be automatically assigned."
}

variable "health_check" {
  type = object({
    port                      = optional(number, 80)
    timeout_sec               = optional(number, 5)
    check_interval_sec        = optional(number, 5)
    use_existing_health_check = optional(bool, false)
    existing_self_link        = optional(string, "")
  })
  default     = {}
  description = <<-EOF
    Configuration for health check.

    Options:

        - port : (Optional | number| default:80) The port number for the TCP health check request. Invalid if use_existing is true.
        - timeout_sec : (Optional | number| default:5) How long (in seconds) to wait before claiming failure. Invalid if use_existing is true.
        - check_interval_sec : (Optional | number| default:5) How often (in seconds) to send a health check. Invalid if use_existing is true.
        - use_existing_health_check : (Optional | bool | default:false) If use_existing is true, the existing health check resource is used.
        - existing_self_link : (Optional | string | default:"") The self link of existing health check. Used if use_existing is true.

    Example:

    ```
    health_check = {
      port               = 80
      timeout_sec        = 5
      check_interval_sec = 5
    }
    ```
    ```
    health_check = {
      existing_self_link = "<self link of existing health check>"
    }
    ```
    EOF
}

variable "frontend_protocol" {
  type        = string
  default     = "TCP"
  description = <<-EOF
    Protocol of front end forwarding rule.

    Default is TCP, valid options are TCP, UDP, ESP, AH, SCTP, ICMP and L3_DEFAULT
    EOF
}

variable "backend_protocol" {
  type        = string
  default     = "TCP"
  description = <<-EOF
    The protocol the load balancer uses to communicate with the backend.

    Default is TCP, valid options are HTTP, HTTPS, HTTP2, SSL, TCP, UDP, GRPC, UNSPECIFIED.
    EOF
}

variable "network_tier" {
  type        = string
  default     = "PREMIUM"
  description = <<-EOF
  The networking tier used for configuring this load balancer.

  Default is PREMIUM, possible values are: PREMIUM, STANDARD.
  EOF
  validation {
    condition     = contains(["PREMIUM", "STANDARD"], var.network_tier)
    error_message = "Invalid network tier. Valid values are PREMIUM, STANDARD."
  }
}

variable "session_affinity" {
  type        = string
  default     = "NONE"
  description = <<-EOF
  Type of session affinity to use. The default is NONE.

  Session affinity is not applicable if the backend_protocol is UDP.

  Possible values are: NONE, CLIENT_IP, CLIENT_IP_PORT_PROTO, CLIENT_IP_PROTO, GENERATED_COOKIE, HEADER_FIELD, HTTP_COOKIE, CLIENT_IP_NO_DESTINATION.
  EOF
}

# LB port
variable "use_all_ports" {
  type        = bool
  default     = false
  description = <<-EOF
  The "use_all_ports", "ports", and "port_range" are mutually exclusive.

  Set use_all_ports to true to use all ports.
  
  If not set and neither ports nor port_range are specified, all ports are used by default.

  Using all ports requires frontend_protocol to be TCP, UDP, SCTP, or L3_DEFAULT.
  EOF
}

variable "ports" {
  type        = list(string)
  default     = []
  description = <<-EOF
  The "use_all_ports", "ports", and "port_range" are mutually exclusive.

  A list of ports or port ranges to use. Ignored if use_all_ports is true.

  Using ports requires frontend_protocol to be TCP, UDP, SCTP
  EOF
}

variable "port_range" {
  type        = string
  default     = ""
  description = <<-EOF
  The "use_all_ports", "ports", and "port_range" are mutually exclusive.

  The port range to use. Ignored if use_all_ports is true or ports is specified.

  Using port_range requires frontend_protocol to be TCP, UDP, SCTP
  EOF
}
