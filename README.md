## Terraform modules for Fortinet VM products on GCP

Terraform modules for deploying Fortinet VM products (e.g. FortiGate VM) on GCP. 

Folder `modules` contains reusable modules for GCP configurations (Subfolder `gcp`) and Fortinet VM products (Other subfolders). 

Folder `examples` contains examples for certain structures of security solutions. Please Note: Templates under folder `examples` are examples which the name or content may change. Directly reference a examples as module are not recommended.

## Supported features of examples

1. [Autoscale-FGT-LB-Sandwich](./docs/autoscale_fgt_lb_sandwich.md):
    
    Autoscale FortiGate with Load Balancer Sandwich offers a dynamically scalable network security solution that efficiently manages the traffic flowing in and out of your VPCs.

    For a detailed visual diagram and additional information, please refer to [this document](./docs/autoscale_fgt_lb_sandwich.md).

## How to Use Examples:

**Direct Use of Example**

1. Navigate to the example folder (e.g., "examples/autoscale_fgt_lb_sandwich").
2. Edit the file "terraform.tfvars.template" and rename it to "terraform.tfvars".
3. Execute the commands "terraform init" and "terraform apply".

**Use it as a module**

1. Create a new folder and add a file named "main.tf" within this folder.
2. Update "main.tf" with the necessary module parameters, referencing "terraform.tfvars.template" for guidance.

```
module "your_module_name" {
    source = "path_to_the_module"

    other_variable = "xxx"
}
```
3. Execute the commands "terraform init" and "terraform apply".

## Request, Question or Issue

If there is a missing feature or a bug -- [open an issue](https://github.com/fortinetdev/terraform-google-cloud-modules/issues/new)

## License

[License](./LICENSE) © Fortinet Technologies. All rights reserved.