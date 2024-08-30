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
| [google_compute_network_peering.vpc1_to_vpc2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network_peering.vpc2_to_vpc1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering) | resource |
| [google_compute_network.vpc1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_network.vpc2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix of all objects in this module. It can be empty string. | `string` | `""` | no |
| <a name="input_vpc1_name"></a> [vpc1\_name](#input\_vpc1\_name) | If vpc1\_network is specified, vpc1\_name can be a nickname, otherwise, it should be the name of the first VPC. | `string` | n/a | yes |
| <a name="input_vpc1_network"></a> [vpc1\_network](#input\_vpc1\_network) | The self link of the first VPC. If not specified, vpc1\_name is used to query its selflink. | `string` | `""` | no |
| <a name="input_vpc1_to_vpc2"></a> [vpc1\_to\_vpc2](#input\_vpc1\_to\_vpc2) | Config export/import routing policy for forward direction.<br>Options:<br><br>    - export\_custom\_routes : (Optional \| bool \| default:false) Whether to export the custom routes to the peer network.<br>    - import\_custom\_routes : (Optional \| bool \| default:false) Whether to import the custom routes from the peer network.<br>    - export\_subnet\_routes\_with\_public\_ip : (Optional \| bool \| default:true) Whether subnet routes with public IP range are exported.<br>    - import\_subnet\_routes\_with\_public\_ip : (Optional, \| bool \| default:false) Whether subnet routes with public IP range are imported.<br><br>Example:<pre>vpc1_to_vpc2 = {<br>  export_custom_routes = true<br>  import_custom_routes = false<br>}</pre> | <pre>object({<br>    export_custom_routes                = optional(bool, false)<br>    import_custom_routes                = optional(bool, false)<br>    export_subnet_routes_with_public_ip = optional(bool, true)<br>    import_subnet_routes_with_public_ip = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_vpc2_name"></a> [vpc2\_name](#input\_vpc2\_name) | If vpc2\_network is specified, vpc2\_name can be a nickname, otherwise, it should be the name of the second VPC. | `string` | n/a | yes |
| <a name="input_vpc2_network"></a> [vpc2\_network](#input\_vpc2\_network) | The self link of the second VPC. If not specified, vpc2\_name is used to query its selflink. | `string` | `""` | no |
| <a name="input_vpc2_to_vpc1"></a> [vpc2\_to\_vpc1](#input\_vpc2\_to\_vpc1) | Config export/import routing policy for backforward direction.<br>Options:<br><br>    - export\_custom\_routes : (Optional \| bool \| default:false) Whether to export the custom routes to the peer network.<br>    - import\_custom\_routes : (Optional \| bool \| default:false) Whether to import the custom routes from the peer network.<br>    - export\_subnet\_routes\_with\_public\_ip : (Optional \| bool \| default:true) Whether subnet routes with public IP range are exported.<br>    - import\_subnet\_routes\_with\_public\_ip : (Optional \| bool \| default:false) Whether subnet routes with public IP range are imported.<br><br>Example:<pre>vpc2_to_vpc1 = {<br>  export_custom_routes = false<br>  import_custom_routes = true<br>}</pre> | <pre>object({<br>    export_custom_routes                = optional(bool, false)<br>    import_custom_routes                = optional(bool, false)<br>    export_subnet_routes_with_public_ip = optional(bool, true)<br>    import_subnet_routes_with_public_ip = optional(bool, false)<br>  })</pre> | `{}` | no |

## Outputs

No outputs.
