# Module: fgt_single

Check [here](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/fgt_single.md) for detailed document.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.0, <8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.0, <8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.private_ips](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk.disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_instance.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_image.fgt_image](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_compute_subnetwork.subnet_resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_disk"></a> [additional\_disk](#input\_additional\_disk) | Additional disk for logging.<br><br>Options:<br><br>    - name : (Optional \| string \| default:"") Name of your log disk.<br>    - size : (Optional \| number \| default:0) Log disk size (GB) for each FGT. If set to 0, no additional log disk is created.<br>    - type : (Optional \| string \| default:"pd-standard") The Google Compute Engine disk type. Such as "pd-ssd", "local-ssd", "pd-balanced" or "pd-standard".<br><br>Example:<pre>additional_disk = {<br>  size = 30<br>  type = "pd-standard"<br>}</pre> | <pre>object({<br>    name = optional(string, "")<br>    size = optional(number, 0)<br>    type = optional(string, "pd-standard")<br>  })</pre> | `{}` | no |
| <a name="input_config_file"></a> [config\_file](#input\_config\_file) | Additional FortiGate configuration script file. | `string` | `""` | no |
| <a name="input_config_script"></a> [config\_script](#input\_config\_script) | Additional FortiGate configuration script. | `string` | `""` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Host name. If not set, it will be <prefix>-instance. | `string` | `""` | no |
| <a name="input_image_source"></a> [image\_source](#input\_image\_source) | The source of the custom image. Example: "projects/fortigcp-project-001/global/images/fortinet-fgt-760-20240726-001-w-license"<br>One of the variables "image\_type" and "image\_source" must be provided, otherwise an error occurs. If both are provided, "image\_source" will be used. | `string` | `""` | no |
| <a name="input_image_type"></a> [image\_type](#input\_image\_type) | The type of public FortiGate Image. Example: "fortigate-76-byol" or "fortigate-76-payg"<br>One of the variables "image\_type" and "image\_source" must be provided, otherwise an error occurs. If both are provided, "image\_source" will be used.<br>Use the following command to check all FortiGate image type:<br>`gcloud compute images list --project=fortigcp-project-001 --filter="family:fortigate*" --format="table[no-heading](family)" | sort | uniq`<br><br>fortigate-76-byol : FortiGate 7.6, bring your own licenses.<br><br>fortigate-76-payg : FortiGate 7.6, don't need to provide licenses, pay as you go. | `string` | `""` | no |
| <a name="input_licensing"></a> [licensing](#input\_licensing) | If your image type is byol (bring your own license), you can license your FortiGate here.<br><br>Options:<br><br>    - license\_file : (Optional \| string \| default:"") Location of your own license.<br>    - fortiflex\_token : (Optional \| string \| default:"") Fortiflex token to activate VM.<br><br>Example:<pre>licensing = {<br>  license_file = "/path/to/license.lic"<br>}</pre>OR<pre>licensing = {<br>  fortiflex_token = "<fortiflex token>"<br>}</pre> | <pre>object({<br>    license_file    = optional(string, "")<br>    fortiflex_token = optional(string, "")<br>  })</pre> | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The Virtual Machine type to deploy FGT. Example of predefined type: n1-standard-4, n2-standard-8, ...<br><br>Custom machine types can be formatted as custom-NUMBER\_OF\_CPUS-AMOUNT\_OF\_MEMORY\_MB,<br>e.g. custom-6-20480 for 6 vCPU and 20GB of RAM.<br><br>There is a limit of 6.5 GB per CPU unless you add extended memory. You must do this explicitly by adding the suffix -ext,<br>e.g. custom-2-15360-ext for 2 vCPU and 15 GB of memory. | `string` | n/a | yes |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | Network interfaces.<br><br>Options:<br><br>    - subnet\_name   : (Required \| string \| default:"") The name of your existing subnet.<br>    - has\_public\_ip : (Optional \| bool \| default:false) Whether this port has public IP. Default is False.<br>    - public\_ip     : (Optional \| string \| default:"") You can specify the public IP of your interface. Only available if has\_public\_ip is true.<br>    - private\_ip    : (Optional \| string \| default:"") The private ip of your FortiGate in this subnet. If not specify private\_ip, GCP will select a private IP for you.<br><br>Example:<pre>network_interfaces = [                        # Network interface of your FortiGate<br>  # Port 1 of your FortiGate<br>  {<br>    subnet_name   = "single-fortigate-public" # The name of your existing subnet.<br>    private_ip    = "10.0.0.2"                # Optional. The private ip of your FortiGate in this subnet.<br>                                              # If not specify private_ip, GCP will select a private IP for you.<br>    has_public_ip = true                      # Whether port 1 has public IP. Default is False.<br>  },<br>  # Port 2 of your FortiGate<br>  {<br>    subnet_name = "single-fortigate-private"<br>  },<br>  # You can specify more ports here<br>  # ...<br>]</pre> | <pre>list(object({<br>    subnet_name   = string<br>    has_public_ip = optional(bool, false)<br>    public_ip     = optional(string, "")<br>    private_ip    = optional(string, "")<br>  }))</pre> | `[]` | no |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | The list of network tags attached to FortiGates.<br>GCP firewall rules have "target tags", and these firewall rules only apply to instances with the same tag.<br>You can specify instance tags here. | `list(string)` | `[]` | no |
| <a name="input_password"></a> [password](#input\_password) | Password. If not set, it will be the instance ID. This variable only works for FortiGate (Not working for FAZ and FMG). | `string` | `""` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix of the objects in this module | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region to deploy FortiGate. | `string` | n/a | yes |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | The e-mail address of the service account used for VMs. Example value: 1234567-compute@developer.gserviceaccount.com<br>If not given, the default Google Compute Engine service account is used. | `string` | `""` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Zone to deploy FortiGate. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_password"></a> [default\_password](#output\_default\_password) | n/a |
| <a name="output_instance"></a> [instance](#output\_instance) | n/a |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | n/a |
| <a name="output_instance_name"></a> [instance\_name](#output\_instance\_name) | n/a |
| <a name="output_port_ips"></a> [port\_ips](#output\_port\_ips) | n/a |
