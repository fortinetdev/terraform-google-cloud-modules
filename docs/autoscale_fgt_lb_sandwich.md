# Autoscale FortiGate with Load Balancer Sandwich

Autoscale FortiGate with Load Balancer Sandwich offers a dynamically scalable network security solution that efficiently manages the traffic flowing in and out of your VPCs.

## Architecture

The "autoscale_fgt_lb_sandwich" Terraform project comprises an `Auto-Scale FortiGate Group`, two `VPCs`, an `External Load Balancer`, and an `Internal Load Balancer`. It uses `Google Cloud Function` and `Firestore Database` to designate a primary FortiGate and to manage license deployment across the FortiGates.

**Architecture Diagram:**
![Diagram](./images/autoscale_fgt_lb_sandwich.svg)

The Auto-Scale FortiGate Group consists of dynamically scalable FortiGates, including one primary FortiGate VM and potentially multiple secondary FortiGate VMs. Configurations are set on the primary FortiGate and automatically synchronized across all secondary FortiGates. If the primary FortiGate fail, the Google Cloud Function will promote the oldest secondary FortiGate to take its place.

Each FortiGate is equipped with two network interfaces (NICs); one connects to the `External VPC` and the other to the `Internal VPC`.

Your VPCs will establish a VPC peering connection with the `Internal VPC`. All outbound traffic is then directed to the `Internal Load Balancer` and passed on to the `Auto-Scale FortiGate Group`. It is crucial that your VPCs do not retain a default route ("0.0.0.0/0") to ensure traffic is properly routed through this architecture.

The roles of `Google Cloud Function` and `Firestore Database` (not shown in the diagram) include selecting the primary FortiGate and administering license injections into the FortiGates.


## How To Deploy

You can find the template in `/examples/autoscale_fgt_lb_sandiwch/terraform.tfvars.template`

#### Project Variables：
```
project = "<YOUR-OWN-VALUE>"        # Your GCP project name.
prefix  = "lb-sandwich"             # Prefix of the objects in this example. It should be unique to avoid name conflict between examples.
region  = "<YOUR-OWN-VALUE>"        # e.g., "us-central1"
zone    = "<YOUR-OWN-VALUE>"        # e.g., "us-central1-a"
```
Modify these variables based on your needs.

If you want to deploy more than one "autoscale_fgt_lb_sandiwch" project, please make sure the `prefix` of those "autoscale_fgt_lb_sandiwch" projects are different.

#### FortiGate Variables:
```
fgt_password = "<YOUR-OWN-VALUE>"   # Your own value, or this project will create one for you. Username is "admin".
machine_type = "n1-standard-4"      # The Virtual Machine type to deploy FGT.
image_type   = "fortigate-74-byol"  # FGT Image type.
                                    # fortigate-74-byol: bring your own licenses, you need to specify cloud_function->license_source;
                                    # fortigate-74-payg: pay as you go, you don't need to specify license_source.
fgt_has_public_ip = false           # If set to true, port1 of all FGTs will have a public IP.
# Additional disk (Optional)
# additional_disk = {
#   size = 50                       # Log disk size (GB) for each FGT. If set to 0, no additional log disk is created.
#   type = "pd-standard"            # The Google Compute Engine disk type. Such as "pd-ssd", "local-ssd", "pd-balanced" or "pd-standard".
# }
```
`fgt_password` is the password for all FGTs in this project (Username is "admin"). If you don't specify it, this project will create one for you. You can find `fgt_password` in the output.

`machine_type` represents the Virtual Machine type to deploy FGT.
Example of predefined machine type: "n1-standard-4", "n2-standard-8", ...
The default value "n1-standard-4" in the template is just an example for demonstration. It may not be suitable for your task. Please change the `machine_type` to match your needs.
You can find more supported machine types [here](https://docs.fortinet.com/document/fortigate-public-cloud/7.4.0/gcp-administration-guide/304081).

`fgt_has_public_ip` means whether to allow FortiGate to have a public IP. If set to true, port1 of all FGTs will have a public IP.

`image_type` represents the type of FGT image. You can use the command `gcloud compute images list --project=fortigcp-project-001 --filter="family:fortigate*" --format="table[no-heading](family)" | sort | uniq` to get all possible values.

- "fortigate-74-byol" means the FGT image is the latest patch of FGT 7.4, and you want to bring your own licenses (byol). You need to specify your FortiGate license source in `cloud_function -> license_source`.
- "fortigate-74-byol" means the FGT image is the latest patch of FGT 7.4, and you want to [pay as you go (payg)](https://console.cloud.google.com/marketplace/product/fortigcp-project-001/fortigate-payg). You don't need to specify the FortiGate license source. However, you need to pay an additional license fee in GCP based on the number of CPU cores (vCPU) of the instance.

If `additional_disk` is specified, every FGT will have its own log disk, and the initialization time will increase by 1~2 minutes.


#### Network Variables:

```
external_subnet = "192.168.0.0/22"  # The CIDR of the external VPC for this project. This IP range is used only for FGTs.
internal_subnet = "192.168.4.0/22"  # The CIDR of the internal VPC for this project. This IP range is used only for FGTs and internal load balancer.
# protected_vpc = [                 # List of your existing VPCs (The LANs your want to protect). If specified, outbound and inbound traffic from these VPCs will first go through the FGTs.
#   {name = "<YOUR-VPC-NAME-1>"},
#   {name = "<YOUR-VPC-NAME-2>"}
# ]
```
`external_subnet` is the IP range of the external VPC in the architecture diagram. This IP range should only be used by Auto-Scale FortiGates and should not overlap with the IP range of your existing VPCs.

`internal_subnet` is the IP range of the internal VPC in the architecture diagram. This IP range should only be used by Auto-Scale FortiGates and should not overlap with the IP range of your existing VPCs.

`protected_vpc` is a list of your existing VPCs. It is "Your VPC A", "Your VPC B"... in the architecture diagram. If this variable is specified, outbound and inbound traffic from these VPCs will first go through the Auto-Scale FortiGate Group. These VPCs should not have a default route ("0.0.0.0/0"), otherwise their outbound traffic will not be redirected to this project.


#### Load Balancer Variables:
```
load_balancer = {
  health_check_port = 8008              # The port to be used for health check.
  internal_lb = {
    front_end_ip      = "192.168.4.100" # Front end IP of the internal load balancer. It should be in the "internal_subnet" IP range. Set by the API if undefined.
    frontend_protocol = "TCP"           # Protocol of the front-end forwarding rule. Valid options are TCP, UDP, ESP, AH, SCTP, ICMP and L3_DEFAULT.
    backend_protocol  = "TCP"           # The protocol the load balancer uses to communicate with the backend. Valid options are HTTP, HTTPS, HTTP2, SSL, TCP, UDP, GRPC, UNSPECIFIED.
  }
  external_lb = {
    frontend_protocol = "TCP"           # Protocol of the front-end forwarding rule. Valid options are TCP, UDP, ESP, AH, SCTP, ICMP and L3_DEFAULT.
    backend_protocol  = "TCP"           # The protocol the load balancer uses to communicate with the backend. Valid options are HTTP, HTTPS, HTTP2, SSL, TCP, UDP, GRPC, UNSPECIFIED.
  }
}
```
Parameters for external and internal load balancers. 

You can leave most variables at their default values, except for `internal_lb -> frontend_ip`, which should be in the `internal_subnet` IP range.

#### Cloud Function Variables:
```
cloud_function = {
  function_ip_range   = "192.168.8.0/28"   # Cloud function needs to have its own CIDR ip range ending with "/28", which cannot be used by other resources.
  license_source      = "file"             # The source of license if your image_type is "fortigate-xx-byol".
                                           # Possible value: "none", "fortiflex", "file", "file_fortiflex"
  license_file_folder = "./licenses"       # The folder where all ".lic" license files are located.
  autoscale_psksecret = "<RANDOM-STRING>"  # The secret key used to synchronize information between FortiGates. If not set, the module will randomly generate a 16-character secret key.
  print_debug_msg     = false              # If set as true, the cloud function will print debug messages. You can find these messages in Google Cloud Logs Explorer.
  # Specify fortiflex parameters if license_source is "fortiflex" or "file_fortiflex"
  # fortiflex = {
  #   retrieve_mode = "use_active"         # How to retrieve an existing fortiflex license (entitlement)
  #                                        # "use_stopped" selects and reactivates a stopped entitlement where the description field is empty;
  #                                        # "use_active" selects one active and unused entitlement where the description field is empty.
  #   username      = "<YOUR-OWN-VALUE>"   # The username of your FortiFlex account.
  #   password      = "<YOUR-OWN-VALUE>"   # The password of your FortiFlex account.
  #   config        = <YOUR-OWN-VALUE>     # The config ID of your FortiFlex configuration.
  # }

  # This parameter controls the instance that runs the cloud function.
  service_config = {
    max_instance_count               = 1    # The limit on the maximum number of function instances that may coexist at a given time.
    max_instance_request_concurrency = 2    # Sets the maximum number of concurrent requests that each instance can receive.
    available_cpu                    = "1"  # The number of CPUs used in a single container instance.
    available_memory                 = "1G" # The amount of memory available for a function.
    timeout_seconds                  = 420  # The function execution timeout.
  }
}
```
Cloud function is used to manage FGT synchronization and inject license into FGT.

`function_ip_range` is used by cloud function. This IP range needs to end with "/28" and cannot be used by any other resources.

`license_source` is the source of your license. If your `image_type` ends with "byol" (bring your own license), you need to specify your license source here. Possible values are
- "none": Don't inject licenses to FGTs.
- "file": Injecting licenses based on license files. All license files should be in `license_file_folder` (default value is "./licenses").
- "fortiflex": Injecting licenses based on FortiFlex. You need to specify the variable `fortiflex` if license_source is "fortiflex".
- "file_fortiflex": Injecting licenses based on license files first. If all license files are in use, try FortiFlex next.

`autoscale_psksecret` is the secret key used to synchronize information between FortiGates. If not set, this project will randomly generate a 16-character secret key. You can find it in the output.

`print_debug_msg` is used for debug purposes. If set as true, the cloud function will print debug messages. You can find these messages in Google Cloud Logs Explorer.

`fortiflex` is required if your `license_source` is "fortiflex".
This "autoscale_fgt_lb_sandwich" project will retrieve your existing unused FortiFlex entitlements and use them to inject licenses into FortiGates.
You need to provide your FortiFlex `username` and `password`.
You also need to provide a FortiGate configuration `config` (A digital number). You can use our fortiflexvm Terraform to [create a FortiGate configuration](https://registry.terraform.io/providers/fortinetdev/fortiflexvm/latest/docs/resources/fortiflexvm_config) and get its config ID. You need to [use this config ID to create entitlements](https://registry.terraform.io/providers/fortinetdev/fortiflexvm/latest/docs/resources/fortiflexvm_entitlements_vm) in advance.


`service_config` is a variable that controls the instance on which the cloud function runs. You can increase `max_instance_request_concurrency` to allow multiple injection license requests to run simultaneously. You need to increase `available_memory` if your `max_instance_request_concurrency` is high and running out of existing memory.


#### Autoscaler Variables:
```
autoscaler = {
  max_instances   = 4     # The maximum number of FGT instances
  min_instances   = 2     # The minimum number of FGT instances
  cooldown_period = 360   # Specify how long (seconds) it takes for FGT to initialize from boot time until it is ready to serve.
  cpu_utilization = 0.8   # Autoscaling signal. If CPU utilization is above this value, Google Cloud will create new FGT instances.
}
```
Autoscaler is used to control when to autoscale and control the number of FortiGate instances.

`max_instances` is the maximum number of FGT instances you want to create.

`min_instances` is the minimum number of FGT instances. Your auto-scale FortiGate Group will at least have `min_instances` FGTs. This number can not be less than 2.

`cooldown_period` specify how long (seconds) it takes for FGT to initialize from boot time until it is ready to serve. Please increase this value if the instance takes longer to become ready, especially when `additional_disk` is configured.

`cpu_utilization` is the autoscaling signal. If CPU utilization is above this value, Google Cloud will create new FGT instances. Google Cloud will also delete idle FGT instances if CPU utilization is low for a long time.


#### Additional FGT configuration script.

**NOTE: After deploying this terraform project, changing the variable `config_script` (and contents in `config_file`) will not change the FortiGate configuration.**

The following script is just an example: it allows all inbound and outbound traffic, and it also allows traffic between your VPCs (protected LANs).

Please modify the script based on your needs.

```
config_script = <<EOF
config firewall policy
    # Allow all internal to external traffic
    edit 0
        set name "internal_to_external"
        set srcintf "port2"
        set dstintf "port1"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set nat enable
    next
    # Allow all external to internal traffic
    edit 0
        set name "external_to_internal"
        set srcintf "port1"
        set dstintf "port2"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
    next
    # Allow all internal to internal traffic (traffic between protected LANs)
    edit 0
        set name "internal_to_internal"
        set srcintf "port2"
        set dstintf "port2"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
    next
end
# Allow FGTs to route external traffic to protected LAN.
config router static
    edit 0
        # Assume all your VPCs (protected LANs) are in 10.0.0.0/8
        # Assume all protected LANs connect to port2
        # Assume internal subnet gateway is 192.168.4.1 (internal_subnet is 192.168.4.0/22)
        set dst 10.0.0.0/8
        set gateway 192.168.4.1
        set device "port2"
    next
end
EOF

# config_file = "<YOUR-OWN-VALUE>"  # e.g., your_config_file.conf
```

In addition to the variable config_script, you can also save the configuration script as a file and upload the script using the variable config_file.

If you specify both config_script and config_file, this terraform project will upload both of them.

## FortiGates Licenses

To use FortiGates, you need to provide the necessary licenses. Here are the available options:

1. Set `image_type` as "fortigate-xx-payg" (e.g., "fortigate-74-payg"). With this option, you do not need to specify a separate license source, but you will incur additional license fees in GCP based on the number of CPU cores (vCPUs) of the instance.

2. (RECOMMENDED) Set `image_type` as "fortigate-xx-byol" (e.g, "fortigate-74-byol"). Configure `cloud_function->license_source` as "file", and place your license files (.lic files) in the `cloud_function->->license_file_folder` folder.

3. Set `image_type` as "fortigate-xx-byol" (e.g, "fortigate-74-byol"). Configure `cloud_function->license_source` as "fortiflex" and properly set `cloud_function->fortiflex`. Use `cloud_function->fortiflex->config` to specify a digital ID of your configuration.
  - GUI method: Visit the [fortiflex platform](https://support.fortinet.com/flexvm/), create a "FortiGate Virtual Machine" configuration and generate several entitlements based on this configuration.  
  - Terraform method: You can use our fortiflexvm Terraform to [create a FortiGate configuration](https://registry.terraform.io/providers/fortinetdev/fortiflexvm/latest/docs/resources/fortiflexvm_config) and get its config ID. You need to [use this config ID to create entitlements](https://registry.terraform.io/providers/fortinetdev/fortiflexvm/latest/docs/resources/fortiflexvm_entitlements_vm) in advance.

4. Set `image_type` as "fortigate-xx-byol" (e.g, "fortigate-74-byol"). Configure `cloud_function->license_source` as "file_fortiflex". This setting prioritizes using files to inject licenses into FortiGates initially. If file licenses are depleted, it will use "fortiflex" method.

## Configure FortiGates after deploying

After deploying the "autoscale_fgt_lb_sandwich" project, the `config_script` and contents within the `config_file` become immutable. Subsequent modifications to the `config_script` or the `config_file` will not affect the configuration of existing FortiGates.

In "Google Cloud Firestore -> (default) -> \<YOUR-PROJECT-PREFIX\> -> GLOBAL", you can access the global information of the "autoscale_fgt_lb_sandwich" project. The `"primary_ip_list"` (e.g., ["192.168.0.2", "192.168.4.2"]) indicates the IPs of the primary FortiGate. The first IP is in the `External VPC` and the second IP is in the `Internal VPC`. If you have already specified `protected_vpc`, any VM within your `protected_vpc` can SSH into the primary FortiGate. Any changes made to the configuration of the primary FortiGate will propagate automatically to all secondary FortiGates. If no `protected_vpc` has been specified, you may set up a VM in either the `External VPC` or the `Internal VPC` to SSH into the primary FortiGate.


## Others
**Even if `terraform apply` is complete, FortiGates require time to initialize, load licenses and synchronize within the auto-scaling group, which may take 5 to 10 minutes. During this period, the FortiGates will be unavailable.**

To reduce disruption to your VPCs, initially run `terraform apply` without defining `protected_vpc`. Once all FortiGates in the project are fully initialized, execute `terraform apply` again, this time specifying `protected_vpc`.