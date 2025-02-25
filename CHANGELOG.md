## 1.3.0 (2025)

FEATURES:
* **New Module**: `modules/gcp/iam`. It helps you create a new service account with specified roles.

IMPROVEMENTS:
* Document: Added image guide and cloud function guide.
* Module `modules/fortigate/fgt_asg_with_function`:
  * Added a hash number to the `google_compute_region_instance_template` name. This enables the project to update the FGT image source without requiring a full deletion and redeployment. To upgrade the FGT version, simply change the `image_source`.
  * Added new variables `special_behavior.function_creation_wait_sec` and `special_behavior.function_destruction_wait_sec`. If set to a nonzero value, these variables make the project wait for the specified number of seconds after creating or before destroying the cloud function.
  * Supported FGTs connecting to FAZ. New function variables: `FAZ_IP`, `FAZ_ADOM`, `FAZ_USERNAME`, `FAZ_PASSWORD`.
  * The `"DEBUG"` log level has been further refined into `"DEBUG"` and `"TRACE"`. The `"TRACE"` level outputs more detailed and verbose log information.
  * Improved function logic and added `task_list` to support multi-threading related tasks.

## 1.2.0 (January 31, 2025)

IMPROVEMENTS:

* Module `fgt_single`:
  * Changed the default value `licensing->fortiflex_token` from 0 to "" (empty string).
* Module `fgt_asg_with_function`:
  * Improved the primary FGT reselection logic in function script.
  * The deprecated parameter `cloud_function->print_debug_msg` has been removed, please use `cloud_function->logging_level`.
  * Added a new static route to the FGTs' configuration that routes data destined for `cloud_function.function_ip_range` to port `cloud_function.cloud_func_interface`.
  * Added new variable `autoscaler->scale_in_control_sec`. When the FortiGate group scales down, Google Cloud will delete at most one FGT every 'scale_in_control_sec' seconds.
  * Supported connecting with the Vault server to read secret data. Added 3 new internal variables `VAULT_SERVER`, `VAULT_ROLE`, and `VAULT_PATH` in the Cloud Function.
  * Added `count` to some resources related to the `fgt_password`. Some resources are moved, but the functions remain unchanged. E.g., `google_secret_manager_secret_iam_member.instance_password` has moved to `google_secret_manager_secret_iam_member.instance_password[0]`.
  * Added new variable `special_behavior` for customized functionality. Do not use it unless explicitly instructed by the developer.
* Example `autoscale_fgt_lb_sandwich`:
  * Supported everything changed in Module `fgt_asg_with_function`.
  * By default, this example does not specify the FortiGate hostname. The new variable `fgt_hostname` can set the hostname of all FGTs in the autoscale group. If this variable is not specified, the hostname of the FGT will be its serial number.
  * Added a new static route to the FGTs' configuration that routes data destined for `cloud_function.function_ip_range` to port1.
* Example `autoscale_fgt_as_hub`:
  * Supported everything changed in Module `fgt_asg_with_function`.
  * By default, this example does not specify the FortiGate hostname. The new variable `fgt_hostname` can set the hostname of all FGTs in the autoscale group. If this variable is not specified, the hostname of the FGT will be its serial number.
  * To use existing ILB, you can specify the ILB IP without creating a new ILB by specifying `network_interfaces->additional_variables->ilb_ip`. For example: `network_interfaces = [{network_name="example-network", subnet_name="example-subnet", additional_variables={ilb_ip="10.0.0.100"}}]`. This script will configure the FGT's interface to support ILB. You need to manually add the FGT instance group as the backend of the existing ILB in Google Cloud after the deployment of this example project.


## 1.1.0 (Nov 1, 2024)

FEATURES:

* **New Module**: `fgt_single`. You can use this module to deploy one signle FortiGate.
* **New Example**: `autoscale_fgt_as_hub`. Utilize Autoscale FortiGate as a central hub to connect up to eight existing VPCs. FortiGates connect your VPCs and manage traffic between VPCs.

IMPROVEMENTS:

* Improved the whole project to support Google Cloud 6.0.0
* Example `autoscale_fgt_lb_sandwich`: Added new output `bucket_name`, `elb_ip` and `ilb_ip`.
* Example `autoscale_fgt_lb_sandwich`: Supported `cloud_function.logging_level` to control the verbosity of logs. `cloud_function.print_debug_msg` is deprecated.
* Example `autoscale_fgt_lb_sandwich`: Supported `zones`. If you use the parameter `zones` instead of `zone`, your FortiGates will be deployed in multiple zones.
* Example `autoscale_fgt_lb_sandwich`: Added `image_source`, you can specify custom FortiGate image.
* Example `autoscale_fgt_lb_sandwich`: Added `service_account_email`, you can specify a custom service account other than the default one.
* Module `fgt_asg_with_function`: Supported `cloud_function.logging_level` to control the verbosity of logs. `cloud_function.print_debug_msg` is deprecated.
* Module `fgt_asg_with_function`: Supported `zones`. If you use the parameter `zones` instead of `zone`, your FortiGates will be deployed in multiple zones.
* Module `fgt_asg_with_function`: Added random strings to the storage bucket name to avoid global name conflict.
* Module `fgt_asg_with_function`: Removed unnessary resource "google_compute_target_pool".
* Module `fgt_asg_with_function`: Added validation for variable `fgt_password`. The `fgt_password` must be at least 8 characters long if specified.
* Module `fgt_asg_with_function`: Added Google API requirements and Firestore database requirements in the document.
* Module `fgt_asg_with_function`: Added autohealing for FortiGate instances group.
* Module `fgt_asg_with_function`: Added `elb_ip` and `ilb_ip` in variable `network_interfaces`. If you specify `elb_ip` or `ilb_ip`, the cloud function will configure your FortiGates interfaces to support ELB and ILB.
* Module `fgt_asg_with_function`: Added `image_source`, you can specify a custom FortiGate image.
* Module `fgt_asg_with_function`: Added `service_account_email`, you can specify a custom service account other than the default one.

BUG FIXES:

* Module `fgt_asg_with_function`: Fixed an error that you can't set `cloud_function.fortiflex.password` as empty.
* Module `fgt_asg_with_function`: `network_interfaces` is required now.

## 1.0.0 (Aug 30, 2024)

* Initial release
