## Terraform modules for Fortinet VM products on GCP

Terraform modules for deploying Fortinet VM products (e.g. FortiGate VM) on GCP. 

Folder `modules` contains reusable modules for GCP configurations (Subfolder `gcp`) and Fortinet VM products (Other subfolders). 

Folder `examples` contains examples for certain structures of security solutions. Please Note: Templates under folder `examples` are examples which the name or content may change. When you reference an example as a module, it is not recommended to update its version after it is deployed.

## Supported Templates

Please click the following links for visual diagrams, requirements, example deployment scripts, and additional information.

### Examples
1. [Autoscale-FGT-LB-Sandwich](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/autoscale_fgt_lb_sandwich.md):
    
    Autoscale FortiGate with Load Balancer Sandwich uses FortiGates as a firewall between your VPCs and the Internet. It offers a dynamically scalable FortiGate Group that efficiently manages the traffic flowing in and out of your VPCs.

2. [Autoscale-FGT-as-Hub](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/autoscale_fgt_as_hub.md):
    
    Utilize Autoscale FortiGate as a central hub to connect up to eight existing VPCs. FortiGates connect your VPCs and manage traffic between VPCs.

### Modules
1. [Single FortiGate](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/fgt_single.md):

    You can use this module to quickly deploy one single FortiGate.


## How to Use Examples/Modules:

**Use it as a Terraform project (Examples only)**

1. Navigate to the example folder (e.g., "examples/autoscale_fgt_lb_sandwich").
2. Edit the file "terraform.tfvars.template" and rename it to "terraform.tfvars".
3. Execute the commands `terraform init` and `terraform apply`.

**Use it as a module (Examples and Modules)**

1. Create a new folder and add a file named "main.tf" within this folder.
2. In "main.tf", specify the module with the necessary parameters.

```
module "your_module_name" {
    source = "fortinetdev/cloud-modules/google//examples/<example_name>"
    # source = "fortinetdev/cloud-modules/google//modules/fortigate/<module_name>"

    other_variable = "xxx"
}
```
3. Execute the commands `terraform init` and `terraform apply`.

## Request, Question or Issue

If there is a missing feature or a bug -- [open an issue](https://github.com/fortinetdev/terraform-google-cloud-modules/issues/new)

## License

[License](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/LICENSE) © Fortinet Technologies. All rights reserved.