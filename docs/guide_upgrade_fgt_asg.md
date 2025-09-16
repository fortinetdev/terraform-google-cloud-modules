# Guide: Upgrading FortiGate AutoScale Group

After deploying the examples `autoscale_fgt_as_hub`, `autoscale_fgt_lb_sandwich`, or the module `fortigate/fgt_asg_with_function`, you can upgrade the FortiGate (FGT) image version and the [Cloud Function](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/guide_function.md) code.

### Upgrading the FortiGate Image Version

Once the project is deployed, you may modify the FortiGate image version. This change will affect only newly provisioned FortiGate instances. Existing instances will retain their current version.

The upgrade process depends on how the FGT image is specified in your Terraform configuration:

- Using `image_type`:

    If you specify the image via the variable `image_type`, Terraform will automatically retrieve the latest available image. Simply run the command `terraform apply` and confirm the changes.

- Using `image_source`:

    If the FGT image is set via the variable `image_source`, update this variable with the new image reference. Then, run the command `terraform apply` and confirm the changes.

### Upgrading the Cloud Function (Available in version >= 1.4.1)

The [Cloud Function](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/guide_function.md) is continuously updated to support new features and improvements. To benefit from these updates, you can upgrade the Cloud Function code using one of the following methods:

#### 1. If you are using a local copy of the project

If you have cloned or downloaded the source code locally (using `terraform.tfvars` file to deploy), you can manually update the Cloud Function code:

1. Download the latest [`cloud function code file`](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/modules/fortigate/fgt_asg_with_function/cloud_function.zip)
2. Replace the existing file at `/modules/fortigate/fgt_asg_with_function/cloud_function.zip`.
3. Re-run `terraform apply` to deploy the updated function.


#### 2. If you are using the project as a module (recommended for version ≥ 1.4.1)

If you're using this project as a module, for example, by creating your own `main.tf` file and including the following block:

**Example (initial use without version pinning):**
```
module "autoscale_fgt_lb_sandwich" {
  source = "fortinetdev/cloud-modules/google//examples/autoscale_fgt_lb_sandwich"

  # other parameters
}
```
Terraform will fetch the latest available version at the time of the first `terraform init`. However, this version is **locked** in your `.terraform.lock.hcl` file and will not automatically update, even if newer versions become available later.

To ensure you're using a specific version, or to upgrade to a newer one, you should explicitly specify the version attribute in your module block.

**To upgrade to a newer version:**

Update the `version` field to the desired version number. For example:

```
module "autoscale_fgt_lb_sandwich" {
  source = "fortinetdev/cloud-modules/google//examples/autoscale_fgt_lb_sandwich"
  version = "1.4.1"  # <-- Update this to a new version

  # other parameters
}
```

Then run the following commands to upgrade and apply the changes:
```
terraform init -upgrade
terraform apply
```
