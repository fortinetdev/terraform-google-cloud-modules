# Guide: GCP Modules

In order to use Google Cloud Terraform resources more conveniently, this Terraform project includes some GCP Modules (`/modules/gcp`).

Here are some useful modules you may need:

### Create dedicated service account

This script will create a dedicated service account: `<SERVICE-ACCOUNT-NAME>@<YOUR-PROJECT-NAME>.iam.gserviceaccount.com`.

This service account has roles ["roles/datastore.user", "roles/compute.viewer", "roles/run.invoker"].

```hcl
module "dedicated_service_account" {
  source               = "fortinetdev/cloud-modules/google//modules/gcp/iam"
  project              = "<YOUR-PROJECT-NAME>"
  service_account_name = "<SERVICE-ACCOUNT-NAME>"
  roles = [
    "roles/datastore.user",
    "roles/compute.viewer",
    "roles/run.invoker",
    # Add any roles you want here
  ]
}

output "dedicated_service_account" {
  value = module.dedicated_service_account.service_account_email
}
```


### Create a new VPC

You can use this script to create a new VPC with subnets and firewall rules.

```
module "example_vpc" {
  source = "fortinetdev/cloud-modules/google//modules/gcp/vpc"

  network_name = "example-network-name"

  # You can specify a list of subnets in this VPC
  subnets = [
    {
      name          = "example-subnet-name"
      region        = "<YOUR-REGION>"   # e.g., us-central1
      ip_cidr_range = "<YOUR-IP-RANGE>" # e.g., "10.0.0.0/24"
    }
  ]

  # You can specify a list of firewall rules
  firewall_rules = [
    {
      name          = "example-network-firewall-1"
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["example-access"]
      allow = [
        {
          protocol = "all"
        }
      ]
    }
  ]
}

```
