![Fortinet logo|](https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Fortinet_logo.svg/320px-Fortinet_logo.svg.png)

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
1. [generic_vm_standalone](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/module_generic_vm_standalone.md)

    This module can be used to deploy any Fortinet VM: FortiGate / FortiManager / FortiAnalyzer / FortiAIOPS / FortiGuest ...


2. [Single FortiGate](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/fgt_single.md)  (Deprecated, please use [generic_vm_standalone](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/module_generic_vm_standalone.md)):

    You can use this module to quickly deploy one single FortiGate.

    This module can also be used to create FortiManager and FortiAnalyzer if you change the `image_type` or `image_source` to the [target value](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/guide_image.md#image-list).



## How to Use Examples/Modules:

**Use it as a Terraform project (Examples only)**

1. Clone the module to your environment. 
2. Navigate to the example folder (e.g., "examples/autoscale_fgt_lb_sandwich").
3. Edit the file "terraform.tfvars.template" and rename it to "terraform.tfvars".
4. Execute the commands `terraform init` and `terraform apply`. 

**Use it as a module (Examples and Modules)**

1. Create a new folder and add a file named "main.tf" within this folder. 
2. In "main.tf", specify the source to the target example, for instance: `"fortinetdev/cloud-modules/google//examples/autoscale_fgt_lb_sandwich"`. Provide your own values for necessary parameters of the module. There is a file named `terraform.tfvars.template` on each example, which could be a reference. 

``` 
module "your_module_name" { 
    source = "fortinetdev/cloud-modules/google//examples/<example_name>" 

    <Specify module variables>
} 
``` 
3. Execute the commands `terraform init` and `terraform apply`.

## FAQ
- [How to Specify Image](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/guide_image.md)
- [What is Cloud Function](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/guide_function.md)
- [Useful GCP Modules](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/guide_gcp_modules.md)

## Request, Question or Issue

If there is a missing feature or a bug -- [open an issue](https://github.com/fortinetdev/terraform-google-cloud-modules/issues/new)

## License

[License](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/LICENSE) © Fortinet Technologies. All rights reserved.