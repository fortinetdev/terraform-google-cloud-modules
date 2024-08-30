variable "network_name" {
  type        = string
  description = "Name of the network."
}

variable "vpc" {
  type = object({
    delete_default_route = optional(bool, false)
  })
  default     = {}
  description = <<-EOF
    The settings of VPC.

    Options:

        - delete_default_route : (Optional | bool | default:false) If set to "true", default routes ("0.0.0.0/0") will be deleted immediately after network creation.

    Example:

    ```
    vpc = {
      delete_default_route = true
    }
    ```
  EOF
}


variable "subnets" {
  type = list(object({
    name                     = string
    ip_cidr_range            = string
    region                   = string
    private_ip_google_access = optional(bool, false)
  }))
  description = <<-EOF
    The list of subnets being created.

    Options:

        - name : (Required | string) The name of the subnet.
        - ip_cidr_range : (Required | string) The range of internal addresses that are owned by this subnetwork.
        - region : (Required | string) The GCP region for this subnetwork.
        - private_ip_google_access : (Optional | bool | default:false) When enabled, VMs in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access.

    Example:
    ```
    subnets = [
      {
        name          = "your-subnet-name-1"
        region        = "us-central1"
        ip_cidr_range = "10.0.0.0/24"
      },      
      {
        name          = "your-subnet-name-2"
        region        = "us-west1"
        ip_cidr_range = "10.0.1.0/24"
      }
    ]
    ```
  EOF
}

variable "firewall_rules" {
  type = list(object({
    name                    = string
    description             = optional(string, null)
    direction               = optional(string, "INGRESS")
    priority                = optional(number, null)
    destination_ranges      = optional(list(string), [])
    source_ranges           = optional(list(string), [])
    source_tags             = optional(list(string))
    source_service_accounts = optional(list(string))
    target_tags             = optional(list(string))
    target_service_accounts = optional(list(string))
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [])
  }))
  default     = []
  description = <<-EOF
    The list of firewall rules being created.
    
    Options:

        - name : (Required | string) The name of the firewall rule.
        - description : (Optional | string | default:null) An optional description of this firewall rule.
        - direction : (Optional | string | default:"INGRESS") Direction of traffic to which this firewall applies. INGRESS or EGRESS.
        - priority : (Optional | number | default:null) Priority for this rule. When not specified, the value assumed is 1000.
        - destination_ranges : (Optional | list(string) | default:[]) If specified, the firewall will apply only to traffic that has destination IP address in these ranges.
        - source_ranges : (Optional | list(string) | default:[]) If specified, the firewall will apply only to traffic that has source IP address in there ranges.
        - source_tags : (Optional | list(string)) If specified, the firewall will apply only to traffic with source IP that belongs to a tag listed in source tags.
        - source_service_accounts : (Optional | list(string)) If specified, the firewall will apply only to traffic originating from an instance with a service account in this list.
        - target_tags : (Optional | list(string)) If no target tags are specified, the firewall rule applies to all instance on the specified network.
        - target_service_accounts : (Optional | list(string)) A list of service accounts indicating sets of instances located in the network that may make network connections as specified in allowed[].
        - allow : (Optional | list(object) | default:[]) Allowed firewall rule.
            - protocol : (Required | string) The IP protocol to which this rule applies.
            - port     : (Optional | list(string)) An optional list of ports to which this rule applies.
        - deny : (Optional | list(object) | default:[]) Denied firewall rule.
            - protocol : (Required | string) The IP protocol to which this rule applies.
            - port     : (Optional | list(string)) An optional list of ports to which this rule applies.

    Example:
    ```
    firewall_rules = [
      {
        name          = "your-firewall-rule-name"
        source_ranges = ["0.0.0.0/0"]
        target_tags   = ["your-target-tag"]
        allow = [
          {
            protocol = "all"
          }
        ]
      }
    ]
    ```
  EOF
  validation {
    condition     = alltrue([for rule in var.firewall_rules : rule.direction == "INGRESS" || rule.direction == "EGRESS"])
    error_message = "The direction must be either INGRESS or EGRESS.\n"
  }
}
