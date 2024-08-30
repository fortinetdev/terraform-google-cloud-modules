## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.firewall_rules](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.subnets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | The list of firewall rules being created.<br><br>Options:<br><br>    - name : (Required \| string) The name of the firewall rule.<br>    - description : (Optional \| string \| default:null) An optional description of this firewall rule.<br>    - direction : (Optional \| string \| default:"INGRESS") Direction of traffic to which this firewall applies. INGRESS or EGRESS.<br>    - priority : (Optional \| number \| default:null) Priority for this rule. When not specified, the value assumed is 1000.<br>    - destination\_ranges : (Optional \| list(string) \| default:[]) If specified, the firewall will apply only to traffic that has destination IP address in these ranges.<br>    - source\_ranges : (Optional \| list(string) \| default:[]) If specified, the firewall will apply only to traffic that has source IP address in there ranges.<br>    - source\_tags : (Optional \| list(string)) If specified, the firewall will apply only to traffic with source IP that belongs to a tag listed in source tags.<br>    - source\_service\_accounts : (Optional \| list(string)) If specified, the firewall will apply only to traffic originating from an instance with a service account in this list.<br>    - target\_tags : (Optional \| list(string)) If no target tags are specified, the firewall rule applies to all instance on the specified network.<br>    - target\_service\_accounts : (Optional \| list(string)) A list of service accounts indicating sets of instances located in the network that may make network connections as specified in allowed[].<br>    - allow : (Optional \| list(object) \| default:[]) Allowed firewall rule.<br>        - protocol : (Required \| string) The IP protocol to which this rule applies.<br>        - port     : (Optional \| list(string)) An optional list of ports to which this rule applies.<br>    - deny : (Optional \| list(object) \| default:[]) Denied firewall rule.<br>        - protocol : (Required \| string) The IP protocol to which this rule applies.<br>        - port     : (Optional \| list(string)) An optional list of ports to which this rule applies.<br><br>Example:<pre>firewall_rules = [<br>  {<br>    name          = "your-firewall-rule-name"<br>    source_ranges = ["0.0.0.0/0"]<br>    target_tags   = ["your-target-tag"]<br>    allow = [<br>      {<br>        protocol = "all"<br>      }<br>    ]<br>  }<br>]</pre> | <pre>list(object({<br>    name                    = string<br>    description             = optional(string, null)<br>    direction               = optional(string, "INGRESS")<br>    priority                = optional(number, null)<br>    destination_ranges      = optional(list(string), [])<br>    source_ranges           = optional(list(string), [])<br>    source_tags             = optional(list(string))<br>    source_service_accounts = optional(list(string))<br>    target_tags             = optional(list(string))<br>    target_service_accounts = optional(list(string))<br>    allow = optional(list(object({<br>      protocol = string<br>      ports    = optional(list(string))<br>    })), [])<br>    deny = optional(list(object({<br>      protocol = string<br>      ports    = optional(list(string))<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Name of the network. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | The list of subnets being created.<br><br>Options:<br><br>    - name : (Required \| string) The name of the subnet.<br>    - ip\_cidr\_range : (Required \| string) The range of internal addresses that are owned by this subnetwork.<br>    - region : (Required \| string) The GCP region for this subnetwork.<br>    - private\_ip\_google\_access : (Optional \| bool \| default:false) When enabled, VMs in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access.<br><br>Example:<pre>subnets = [<br>  {<br>    name          = "your-subnet-name-1"<br>    region        = "us-central1"<br>    ip_cidr_range = "10.0.0.0/24"<br>  },      <br>  {<br>    name          = "your-subnet-name-2"<br>    region        = "us-west1"<br>    ip_cidr_range = "10.0.1.0/24"<br>  }<br>]</pre> | <pre>list(object({<br>    name                     = string<br>    ip_cidr_range            = string<br>    region                   = string<br>    private_ip_google_access = optional(bool, false)<br>  }))</pre> | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | The settings of VPC.<br><br>Options:<br><br>    - delete\_default\_route : (Optional \| bool \| default:false) If set to "true", default routes ("0.0.0.0/0") will be deleted immediately after network creation.<br><br>Example:<pre>vpc = {<br>  delete_default_route = true<br>}</pre> | <pre>object({<br>    delete_default_route = optional(bool, false)<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network"></a> [network](#output\_network) | VPC Network. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Subnets. |
