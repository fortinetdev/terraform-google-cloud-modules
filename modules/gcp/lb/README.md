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
| [google_compute_forwarding_rule.lb](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_region_backend_service.backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) | resource |
| [google_compute_region_health_check.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_protocol"></a> [backend\_protocol](#input\_backend\_protocol) | The protocol the load balancer uses to communicate with the backend.<br><br>Default is TCP, valid options are HTTP, HTTPS, HTTP2, SSL, TCP, UDP, GRPC, UNSPECIFIED. | `string` | `"TCP"` | no |
| <a name="input_backends_list"></a> [backends\_list](#input\_backends\_list) | List of backend self link. | `list(string)` | n/a | yes |
| <a name="input_front_end_ip"></a> [front\_end\_ip](#input\_front\_end\_ip) | Front end ip. If not set, the front end ip will be automatically assigned. | `string` | `""` | no |
| <a name="input_frontend_protocol"></a> [frontend\_protocol](#input\_frontend\_protocol) | Protocol of front end forwarding rule.<br><br>Default is TCP, valid options are TCP, UDP, ESP, AH, SCTP, ICMP and L3\_DEFAULT | `string` | `"TCP"` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | Configuration for health check.<br><br>Options:<br><br>    - port : (Optional \| number\| default:80) The port number for the TCP health check request. Invalid if use\_existing is true.<br>    - timeout\_sec : (Optional \| number\| default:5) How long (in seconds) to wait before claiming failure. Invalid if use\_existing is true.<br>    - check\_interval\_sec : (Optional \| number\| default:5) How often (in seconds) to send a health check. Invalid if use\_existing is true.<br>    - use\_existing\_health\_check : (Optional \| bool \| default:false) If use\_existing is true, the existing health check resource is used.<br>    - existing\_self\_link : (Optional \| string \| default:"") The self link of existing health check. Used if use\_existing is true.<br><br>Example:<pre>health_check = {<br>  port               = 80<br>  timeout_sec        = 5<br>  check_interval_sec = 5<br>}</pre><pre>health_check = {<br>  existing_self_link = "<self link of existing health check>"<br>}</pre> | <pre>object({<br>    port                      = optional(number, 80)<br>    timeout_sec               = optional(number, 5)<br>    check_interval_sec        = optional(number, 5)<br>    use_existing_health_check = optional(bool, false)<br>    existing_self_link        = optional(string, "")<br>  })</pre> | `{}` | no |
| <a name="input_ilb"></a> [ilb](#input\_ilb) | Configuration for internal load balancer. If schema is "INTERNAL", this ilb variable is needed.<br><br>Options:<br><br>    - network\_id : (Required if schema is "INTERNAL" \| string \| default:"") ID or self\_link of the network to deploy internal load balancer.<br>    - subnet\_id  : (Required if schema is "INTERNAL" \| string \| default:"") ID or self\_link of the subnet to deploy internal load balancer.<br><br>Example:<pre>ilb = {<br>  network_id = <ID or self_link of the network><br>  subnet_id  = <ID or self_link of the subnet><br>}</pre> | <pre>object({<br>    network_id = optional(string, "")<br>    subnet_id  = optional(string, "")<br>  })</pre> | `{}` | no |
| <a name="input_network_tier"></a> [network\_tier](#input\_network\_tier) | The networking tier used for configuring this load balancer.<br><br>Default is PREMIUM, possible values are: PREMIUM, STANDARD. | `string` | `"PREMIUM"` | no |
| <a name="input_port_range"></a> [port\_range](#input\_port\_range) | The "use\_all\_ports", "ports", and "port\_range" are mutually exclusive.<br><br>The port range to use. Ignored if use\_all\_ports is true or ports is specified.<br><br>Using port\_range requires frontend\_protocol to be TCP, UDP, SCTP | `string` | `""` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | The "use\_all\_ports", "ports", and "port\_range" are mutually exclusive.<br><br>A list of ports or port ranges to use. Ignored if use\_all\_ports is true.<br><br>Using ports requires frontend\_protocol to be TCP, UDP, SCTP | `list(string)` | `[]` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix of all objects in this module. | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to deploy LB. | `string` | n/a | yes |
| <a name="input_schema"></a> [schema](#input\_schema) | The load balancing scheme to use. Valid values are EXTERNAL, EXTERNAL\_MANAGED, INTERNAL, INTERNAL\_MANAGED. | `string` | n/a | yes |
| <a name="input_session_affinity"></a> [session\_affinity](#input\_session\_affinity) | Type of session affinity to use. The default is NONE.<br><br>Session affinity is not applicable if the backend\_protocol is UDP.<br><br>Possible values are: NONE, CLIENT\_IP, CLIENT\_IP\_PORT\_PROTO, CLIENT\_IP\_PROTO, GENERATED\_COOKIE, HEADER\_FIELD, HTTP\_COOKIE, CLIENT\_IP\_NO\_DESTINATION. | `string` | `"NONE"` | no |
| <a name="input_use_all_ports"></a> [use\_all\_ports](#input\_use\_all\_ports) | The "use\_all\_ports", "ports", and "port\_range" are mutually exclusive.<br><br>Set use\_all\_ports to true to use all ports.<br><br>If not set and neither ports nor port\_range are specified, all ports are used by default.<br><br>Using all ports requires frontend\_protocol to be TCP, UDP, SCTP, or L3\_DEFAULT. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_front_end_ip"></a> [front\_end\_ip](#output\_front\_end\_ip) | IP address of the front end. |
| <a name="output_health_check_self_link"></a> [health\_check\_self\_link](#output\_health\_check\_self\_link) | The self link of health check resource. |
| <a name="output_lb"></a> [lb](#output\_lb) | The load balancer resource. |
