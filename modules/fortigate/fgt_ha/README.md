# Module: fgt_ha

Please check the document:
- [fgt_ha](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/module_fgt_ha.md)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.0, <7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.0, <7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.private_ips_1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_address.private_ips_2](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk.disk](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_instance.fgts](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance_group.fgt_umigs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group) | resource |
| [google_compute_image.fgt_image](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_compute_subnetwork.subnet_resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_compute_zones.zones_in_region](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_disk"></a> [additional\_disk](#input\_additional\_disk) | Additional disk for logging.<br><br>Options:<br><br>    - size : (Optional \| number \| default:0) Log disk size (GB) for each FGT. If set to 0, no additional log disk is created.<br>    - type : (Optional \| string \| default:"pd-standard") The Google Compute Engine disk type. Such as "pd-ssd", "local-ssd", "pd-balanced" or "pd-standard".<br><br>Example:<pre>additional_disk = {<br>  size = 30<br>  type = "pd-standard"<br>}</pre> | <pre>object({<br>    size = optional(number, 0)<br>    type = optional(string, "pd-standard")<br>  })</pre> | <pre>{<br>  "size": 0,<br>  "type": "pd-standard"<br>}</pre> | no |
| <a name="input_config_file"></a> [config\_file](#input\_config\_file) | Additional FortiGate configuration script file. | `string` | `""` | no |
| <a name="input_config_script"></a> [config\_script](#input\_config\_script) | Additional FGT configuration script. | `string` | `""` | no |
| <a name="input_fgt_password"></a> [fgt\_password](#input\_fgt\_password) | Password for all FGTs (user name is admin). It must be at lease 8 characters long if specified.<br>If this variable is not set, an FGT's password will be its instance ID. | `string` | `""` | no |
| <a name="input_ha_mode"></a> [ha\_mode](#input\_ha\_mode) | HA mode of FortiGate. Options: "fgcp-ap" (FGCP active-passive) or "fgsp-aa" (FGSP active-active). | `string` | `null` | no |
| <a name="input_ha_password"></a> [ha\_password](#input\_ha\_password) | Password used for HA. This variable is only used when ha\_mode is "fgcp-ap". | `string` | `""` | no |
| <a name="input_ha_port"></a> [ha\_port](#input\_ha\_port) | HA port. Provide value as FortiGate port name (eg. \"port4\").<br>By default, it is the last port of your FGTs. It is not recommended to set it to port1. | `string` | `null` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | FGT hostname. If not set, an FGT's hostname will be its license ID. | `string` | `""` | no |
| <a name="input_image_source"></a> [image\_source](#input\_image\_source) | The source of the custom image. Example: "projects/fortigcp-project-001/global/images/fortinet-fgt-763-20250423-001-w-license"<br>One of the variables "image\_type" and "image\_source" must be provided, otherwise an error occurs. If both are provided, "image\_source" will be used. | `string` | `""` | no |
| <a name="input_image_type"></a> [image\_type](#input\_image\_type) | The type of public FortiGate Image. Example: "fortigate-76-byol" or "fortigate-76-payg"<br>One of the variables "image\_type" and "image\_source" must be provided, otherwise an error occurs. If both are provided, "image\_source" will be used.<br>Use the following command to check all FGT image type:<br>`gcloud compute images list --project=fortigcp-project-001 --filter="family:fortigate*" --format="table[no-heading](family)" | sort | uniq`<br><br>fortigate-76-byol : FortiGate 7.6, bring your own licenses.<br><br>fortigate-76-payg : FortiGate 7.6, don't need to provide licenses, pay as you go. | `string` | `"fortigate-76-byol"` | no |
| <a name="input_license"></a> [license](#input\_license) | If your image type is byol (bring your own license), you can license your FortiGate here.<br><br>Options:<br><br>    - license\_file : (Optional \| list of string \| default:["", ""]) Location of your own license.<br>    - fortiflex\_token : (Optional \| list of string \| default:["", ""]) Fortiflex tokens to activate VM.<br><br>Example:<pre>license = {<br>  license_file = ["/path/to/license1.lic", "/path/to/license2.lic"]<br>}</pre>OR<pre>license = {<br>  fortiflex_token = ["<fortiflex token 1>", "<fortiflex token 2>"]<br>}</pre> | <pre>object({<br>    license_file    = optional(list(string), ["", ""])<br>    fortiflex_token = optional(list(string), ["", ""])<br>  })</pre> | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The Virtual Machine type to deploy FGT. Example of predefined type: n1-standard-4, n2-standard-8, ...<br><br>Custom machine types can be formatted as custom-NUMBER\_OF\_CPUS-AMOUNT\_OF\_MEMORY\_MB,<br>e.g. custom-6-20480 for 6 vCPU and 20GB of RAM.<br><br>There is a limit of 6.5 GB per CPU unless you add extended memory. You must do this explicitly by adding the suffix -ext,<br>e.g. custom-2-15360-ext for 2 vCPU and 15 GB of memory. | `string` | n/a | yes |
| <a name="input_mgmt_port"></a> [mgmt\_port](#input\_mgmt\_port) | The management port. Provide value as FortiGate port name (eg. \"port4\").<br>By default, it is the last port of your FGTs. It is not recommended to set it to port1. | `string` | `null` | no |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | List of Network Interfaces.<br><br>Options:<br><br>    - subnet\_name   : (Required \| string) The name of your existing subnet.<br>    - has\_public\_ip : (Optional \| bool \| default:false) Whether this port has public IP. Default is False.<br>    - elb\_ip        : (Optional \| list of string \| default:[]) If this interface connects to an external load balancer (ELB), specify the IP of the existing ELB here.<br>    - ilb\_ip        : (Optional \| list of string \| default:[]) If this interface connects to an internal load balancer (ILB), specify the IP of the existing ILB here.<br><br>Example:<pre>network_interfaces = [<br>  # Port 1 of your FortiGate<br>  {<br>    subnet_name   = "vpc-external"<br>    has_public_ip = true<br>    elb_ip        = google_compute_address.elb_ip.address<br>  },<br>  # Port 2 of your FortiGate.<br>  {<br>    subnet_name   = "vpc-internal"<br>    ilb_ip        = google_compute_address.ilb_ip.address<br>  },<br>  # You can specify more ports here<br>  # ...<br>]</pre> | <pre>list(object({<br>    subnet_name   = string<br>    has_public_ip = optional(bool, false)<br>    elb_ip        = optional(list(string), [])<br>    ilb_ip        = optional(list(string), [])<br>  }))</pre> | n/a | yes |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | The list of network tags attached to FortiGates.<br>GCP firewall rules have "target tags", and these firewall rules only apply to instances with the same tag.<br>You can specify instance tags here. | `list(string)` | `[]` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix of all objects in this module. It should be unique to avoid name conflict between projects. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region to deploy VM. | `string` | n/a | yes |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | Example value: 1234567-compute@developer.gserviceaccount.com<br>The e-mail address of the service account. This service account will control the cloud function created by this project.<br>If this variable is not specified, the default Google Compute Engine service account is used. | `string` | `""` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Deploy the project to multiple zones for higher availability.<br>Two zone are required. If it is not specified, this module will select 2 zones for you. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id_list"></a> [instance\_id\_list](#output\_instance\_id\_list) | n/a |
