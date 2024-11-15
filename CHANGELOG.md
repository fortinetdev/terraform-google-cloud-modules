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
