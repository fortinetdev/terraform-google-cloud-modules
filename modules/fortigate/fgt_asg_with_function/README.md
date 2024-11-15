# Module: fgt_asg_with_function

Following examples use this module:
- [autoscale_fgt_lb_sandwich](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/autoscale_fgt_lb_sandwich.md) 
- [autoscale_fgt_as_hub](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/autoscale_fgt_as_hub.md).

Following Google APIs must be enabled:
- eventarc.googleapis.com
- firestore.googleapis.com # And *(default)* database in Native mode.
- storage.googleapis.com
- compute.googleapis.com
- secretmanager.googleapis.com
- pubsub.googleapis.com
- vpcaccess.googleapis.com
- cloudbuild.googleapis.com
- run.googleapis.com
- logging.googleapis.com

Firestore *"(default)"* database must be created in Native mode before using this module. The *"(default)"* database is the Firestore default database. If it does not exist, please create it manually.
```
# Using this script to create the "(default)" database.
# Please do not destroy it once it is created.
resource "google_firestore_database" "database" {
  project     = "<YOUR-PROJECT-NAME>"
  name        = "(default)"
  location_id = "nam5"     # "nam5" (United States) or "eur3" (Belgium and Netherlands)
  type        = "FIRESTORE_NATIVE"
}
```
Please do not destroy *"(default)"* database once it is created. Please do not try to delete and recreate "google_firestore_database", otherwise, an error may occur.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.13, < 2.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.0, <7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.0, <7.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloudfunctions2_function.init_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function) | resource |
| [google_compute_autoscaler.autoscaler](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_autoscaler) | resource |
| [google_compute_instance_group_manager.manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_manager) | resource |
| [google_compute_region_autoscaler.autoscaler](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_autoscaler) | resource |
| [google_compute_region_health_check.autohealing](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check) | resource |
| [google_compute_region_instance_group_manager.manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) | resource |
| [google_compute_region_instance_template.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_template) | resource |
| [google_logging_project_sink.topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_pubsub_topic.topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_binding.pubsub_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_binding) | resource |
| [google_secret_manager_secret.fortiflex_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret.instance_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.fortiflex_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_iam_member.instance_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_version.fortiflex_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_secret_manager_secret_version.instance_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_storage_bucket.gcf_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.bucket_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_object.function_zip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_storage_bucket_object.license_files](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_vpc_access_connector.vpc_connector](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/vpc_access_connector) | resource |
| [random_password.autoscale_psksecret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.fgt_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.bucket_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_compute_default_service_account.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_default_service_account) | data source |
| [google_compute_image.fgt_image](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_compute_subnetwork.subnet_resources](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_service_account.iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_disk"></a> [additional\_disk](#input\_additional\_disk) | Additional disk for logging.<br><br>Options:<br><br>    - size : (Optional \| number \| default:0) Log disk size (GB) for each FGT. If set to 0, no additional log disk is created.<br>    - type : (Optional \| string \| default:"pd-standard") The Google Compute Engine disk type. Such as "pd-ssd", "local-ssd", "pd-balanced" or "pd-standard".<br><br>Example:<pre>additional_disk = {<br>  size = 30<br>  type = "pd-standard"<br>}</pre> | <pre>object({<br>    size = optional(number, 0)<br>    type = optional(string, "pd-standard")<br>  })</pre> | <pre>{<br>  "size": 0,<br>  "type": "pd-standard"<br>}</pre> | no |
| <a name="input_autoscaler"></a> [autoscaler](#input\_autoscaler) | Auto Scaler parameters. This variable controls when to autoscale and the maximum number of instances.<br>Options:<br><br>    - max\_instances     : (Required \| number) The maximum number of FGT instances.<br>    - min\_instances     : (Optional \| number \| default:2) The minimum number of FGT instances.<br>    - cooldown\_period   : (Optional \| number \| default:300) Specify how long (seconds) it takes for FGT to initialize from boot time until it is ready to serve..<br>    - cpu\_utilization   : (Optional \| number \| default:0.9) Autoscaling signal. If cpu utilization above this value, google cloud will create new FGT instance.<br>    - autohealing       : (Optional \| Object) Parameters about autohealing. Autohealing recreates VM instances if your application cannot be reached by the health check.<br>        - health\_check\_port   : (Optional \| number \| default:8008) The port used for health checks by autohealing. Set it to 0 to disable autohealing.<br>        - timeout\_sec         : (Optional \| number \| default:5) How long (in seconds) to wait before claiming a health check failure.<br>        - check\_interval\_sec  : (Optional \| number \| default:30) How often (in seconds) to send a health check.<br>        - unhealthy\_threshold : (Optional \| number \| default:10) A so-far healthy instance will be marked unhealthy after this many consecutive failures.<br><br>Example:<pre>autoscaler = {<br>    max_instances = 10<br>    min_instances = 2<br>    cooldown_period = 300<br>    cpu_utilization = 0.9<br>}</pre> | <pre>object({<br>    max_instances   = number<br>    min_instances   = optional(number, 2)<br>    cooldown_period = optional(number, 300)<br>    cpu_utilization = optional(number, 0.9)<br>    autohealing = optional(object({<br>      health_check_port   = optional(number, 8008)<br>      timeout_sec         = optional(number, 5)<br>      check_interval_sec  = optional(number, 30)<br>      unhealthy_threshold = optional(number, 10)<br>      }), {}<br>    )<br>  })</pre> | n/a | yes |
| <a name="input_cloud_function"></a> [cloud\_function](#input\_cloud\_function) | Parameters for cloud function. The cloud function is used to inject licenses to FGTs,<br>upload user-specified configurations and manage the FGT autoscale group.<br><br>Options:<br><br>    - vpc\_network : (Required \| string) Name of the internal VPC network the cloud function connects to. Cloud function must connect to the internal VPC to send data to FGTs.<br>    - function\_ip\_range : (Required \| string) Cloud function needs to have its only CIDR ip range ending with "/28", which cannot be used by other resources. Example "10.1.0.0/28".<br>      This IP range subnet cannot be used by other resources, such as VMs, Private Service Connect, or load balancers.<br>    - license\_source : (Optional \| string \| default:"none") The source of license if your image\_type is "byol".<br>        "none" : Don't inject licenses to FGTs.<br>        "file" : Injecting licenses based on license files. All license files should be in license\_file\_folder.<br>        "fortiflex" : Injecting licenses based on FortiFlex. Need to specify the parameter fortiflex if license\_source is "fortiflex".<br>        "file\_fortiflex" : Injecting licenses based on license files first. If all license files are in use, try FortiFlex next.<br>    - license\_file\_folder : (Optional \| string \| default:"./licenses") The folder where all ".lic" license files are located. Default is "./licenses" folder.<br>    - autoscale\_psksecret : (Optional \| string \| default:"") The secret key used to synchronize information between FortiGates. If not set, the module will randomly generate a 16-character secret key.<br>    - print\_debug\_msg : (Optional \| bool \| default:false) Deprecated, use logging\_level instead. If set to true, the cloud function will print debug messages. You can find these messages in Google Cloud Logs Explorer.<br>    - logging\_level : (Optional \| string \| default:"NOT\_SPECIFIED") Verbosity of logs. Possible values include "NONE", "ERROR", "WARN", "INFO", "DEBUG", and "TRACE". You can find logs in Google Cloud Logs Explorer.<br>    For backward compatibility reasons, the default value "NOT\_SPECIFIED" functions the same as "NONE" and logs nothing unless you set the deprecated "print\_debug\_msg" to true, in which case it acts like "INFO".<br>    - fortiflex : (Optional \| object) You need to specify this parameter if your license\_source is "fortiflex" or "file\_fortiflex".<br>        - retrieve\_mode : (Optional \| string \| default:"use\_stopped") How to retrieve an existing fortiflex license (entitlement):<br>            "use\_stopped" selects and reactivates a stopped entitlement where the description field is empty;<br>            "use\_active" selects one active and unused entitlement where the description field is empty.<br>        - username : (Reuqired if license\_source is "fortiflex" or "file\_fortiflex" \| string \| default:"") The username of your FortiFlex account.<br>        - password : (Reuqired if license\_source is "fortiflex" or "file\_fortiflex" \| string \| default:"") The password of your FortiFlex account.<br>        - config : (Reuqired if license\_source is "fortiflex" or "file\_fortiflex" \| string \| default:"") The configuration ID of your FortiFlex configuration (product type should be FortiGate-VM).<br>    - service\_config : (Optional \| object) This parameter controls the instance that runs the cloud function.<br>        - max\_instance\_count : (Optional \| number \| default:1) The limit on the maximum number of function instances that may coexist at a given time.<br>        - max\_instance\_request\_concurrency : (Optional \| number \| default:1) Sets the maximum number of concurrent requests that each instance can receive.<br>        - available\_cpu : (Optional \| string \| default:"1") The number of CPUs used in a single container instance.<br>        - available\_memory : (Optional \| string \| default:"1G") The amount of memory available for a function. Supported units are k, M, G, Mi, Gi. If no unit is supplied the value is interpreted as bytes.<br>        - timeout\_seconds : (Optional \| number \| default:240) The function execution timeout. Execution is considered failed and can be terminated if the function is not completed at the end of the timeout period.<br>    - additional\_variables : (Optional \| map \| default: {}) Additional variables used in cloud function. It is used to specify example-specific variables<br><br>Example:<pre>cloud_function = {<br>  function_ip_range      = "10.1.0.0/28"  # Cloud function needs to have its own CIDR ip range ending with "/28". This IP range cannot be used by other resources.<br>  license_source         = "file"         # "none", "fortiflex", "file", "file_fortiflex"<br>  license_file_folder    = "./licenses"<br>  autoscale_psksecret    = "psksecret"<br>  logging_level          = "INFO"         # "NONE", "ERROR", "WARN", "INFO", "DEBUG", "TRACE"<br>  # Specify fortiflex parameters if license_source is "fortiflex" or "file_fortiflex"<br>  # fortiflex = {<br>  #   retrieve_mode = "use_active"<br>  #   username      = "Your fortiflex username"<br>  #   password      = "Your fortiflex password"<br>  #   config        = "Your fortiflex configuration ID"<br>  # }<br>  # Parameters of google cloud function.<br>  service_config = {<br>    max_instance_request_concurrency = 2<br>    timeout_seconds                  = 360<br>  }<br>}</pre> | <pre>object({<br>    vpc_network         = string<br>    function_ip_range   = string<br>    license_source      = optional(string, "none")<br>    license_file_folder = optional(string, "./licenses")<br>    autoscale_psksecret = optional(string, "psksecret")<br>    print_debug_msg     = optional(bool, false) # Deprecated, use logging_level instead<br>    logging_level       = optional(string, "NOT_SPECIFIED")<br>    fortiflex = optional(object({<br>      retrieve_mode = optional(string, "use_stopped")<br>      username      = optional(string, "")<br>      password      = optional(string, "")<br>      config        = optional(string, "")<br>      }), {}<br>    )<br>    service_config = optional(object({<br>      max_instance_count               = optional(number, 1)<br>      max_instance_request_concurrency = optional(number, 1)<br>      available_cpu                    = optional(string, "1")<br>      available_memory                 = optional(string, "1G")<br>      timeout_seconds                  = optional(number, 240)<br>    }), {})<br>    additional_variables = optional(map(string), {})<br>  })</pre> | n/a | yes |
| <a name="input_config_script"></a> [config\_script](#input\_config\_script) | Extra config data | `string` | `""` | no |
| <a name="input_fgt_password"></a> [fgt\_password](#input\_fgt\_password) | Password for all FGTs (user name is admin). It must be at lease 8 characters long if specified.<br>If no password is set, the module will randomly generate a 16-character password.<br>After the deployment, if you change the "admin" user password elsewhere (e.g., through the GUI or CLI),<br>please ensure you also update the password here to allow the Cloud Function to communicate with the FortiGates. | `string` | `""` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | FGT hostname. If not set, one FGT hostname will be its license ID. | `string` | `""` | no |
| <a name="input_image_source"></a> [image\_source](#input\_image\_source) | The source of the custom image. Example: "projects/fortigcp-project-001/global/images/fortinet-fgt-760-20240726-001-w-license"<br>One of the variables "image\_type" and "image\_source" must be provided, otherwise an error occurs. If both are provided, "image\_source" will be used. | `string` | `""` | no |
| <a name="input_image_type"></a> [image\_type](#input\_image\_type) | The type of public FortiGate Image. Example: "fortigate-76-byol" or "fortigate-76-payg"<br>One of the variables "image\_type" and "image\_source" must be provided, otherwise an error occurs. If both are provided, "image\_source" will be used.<br>Use the following command to check all FGT image type:<br>`gcloud compute images list --project=fortigcp-project-001 --filter="family:fortigate*" --format="table[no-heading](family)" | sort | uniq`<br><br>fortigate-76-byol : FortiGate 7.6, bring your own licenses.<br><br>fortigate-76-payg : FortiGate 7.6, don't need to provide licenses, pay as you go. | `string` | `"fortigate-76-byol"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The Virtual Machine type to deploy FGT. Example of predefined type: n1-standard-4, n2-standard-8, ...<br><br>Custom machine types can be formatted as custom-NUMBER\_OF\_CPUS-AMOUNT\_OF\_MEMORY\_MB,<br>e.g. custom-6-20480 for 6 vCPU and 20GB of RAM.<br><br>There is a limit of 6.5 GB per CPU unless you add extended memory. You must do this explicitly by adding the suffix -ext,<br>e.g. custom-2-15360-ext for 2 vCPU and 15 GB of memory. | `string` | n/a | yes |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | List of Network Interfaces.<br><br>Options:<br><br>    - subnet\_name   : (Required \| string) The name of your existing subnet.<br>    - has\_public\_ip : (Optional \| bool \| default:false) Whether this port has public IP. Default is False.<br>    - elb\_ip        : (Optional \| string \| default:"") If this interface connects to an external load balancer (ELB), specify the IP of the existing ELB here.<br>        Cloud function will uses this information to configure the FortiGate interface properly.<br>    - ilb\_ip        : (Optional \| string \| default:"") If this interface connects to an internal load balancer (ILB), specify the IP of the existing ILB here.<br>        Cloud function will uses this information to configure the FortiGate interface properly.<br><br>Example:<pre>network_interfaces = [<br>  # Port 1 of your FortiGate<br>  {<br>    subnet_name   = "vpc-external"<br>    has_public_ip = true<br>    elb_ip        = google_compute_address.elb_ip.address<br>  },<br>  # Port 2 of your FortiGate.<br>  {<br>    subnet_name   = "vpc-internal"<br>    ilb_ip        = google_compute_address.ilb_ip.address<br>  },<br>  # You can specify more ports here<br>  # ...<br>]</pre> | <pre>list(object({<br>    subnet_name   = string<br>    has_public_ip = optional(bool, false)<br>    elb_ip        = optional(string, "")<br>    ilb_ip        = optional(string, "")<br>  }))</pre> | n/a | yes |
| <a name="input_network_tags"></a> [network\_tags](#input\_network\_tags) | The list of network tags attached to FortiGates.<br>GCP firewall rules have "target tags", and these firewall rules only apply to instances with the same tag.<br>You can specify instance tags here. | `list(string)` | `[]` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix of all objects in this module. It should be unique to avoid name conflict between projects. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Your GCP project name. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region to deploy VM. | `string` | n/a | yes |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | The e-mail address of the service account used for VMs and secrets management. Example value: 1234567-compute@developer.gserviceaccount.com<br>This service account should already have "roles/datastore.user" and "roles/compute.viewer".<br>If not given, the default Google Compute Engine service account is used. | `string` | `""` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Deploy the project to this single zone.<br>Variable zone is mutually exclusive with variable zones.<br>If both zone and zones are specified, zones will be used.<br>If neither is specified, GCP will select 3 zones for you. | `string` | `""` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Deploy the project to multiple zones for higher availability.<br>Variable zones is mutually exclusive with variable zone.<br>If both zone and zones are specified, zones will be used.<br>If neither is specified, GCP will select 3 zones for you. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscale_psksecret"></a> [autoscale\_psksecret](#output\_autoscale\_psksecret) | The secret key used to synchronize information between FortiGates. |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | GCP Bucket name. |
| <a name="output_fgt_password"></a> [fgt\_password](#output\_fgt\_password) | Password for all FGTs. |
| <a name="output_instance_group_id"></a> [instance\_group\_id](#output\_instance\_group\_id) | The full URL of the instance group created by this module. |
