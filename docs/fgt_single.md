# Module: Single FortiGate - fgt_single

> This module is used to deploy one single FortiGate.
To deploy any Forti products (e.g., FortiGate, FortiAnalyzer, FortiManager... ), please use the module: [generic_vm_standalone](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/module_generic_vm_standalone.md).

Create a FortiGate and using existing VPCs.

## How To Deploy

You can use this module directly:

```
module "single_fortigate" {
  source = "fortinetdev/cloud-modules/google//modules/fortinet/fgt_single"

  prefix   = "single-fortigate"             # The prefix name of all Google Cloud resources created by this module.
  hostname = "single-fortigate"             # The name of your FortiGate. If not set, it will be <prefix>-instance.
  # password     = "<Your admin password>"  # Optional. If not set, it will be the GCP instance id. This variable only works for FortiGate (Not working for FortiAnalyzer and FortiManager).
  region       = "us-central1"              # Region to deploy FortiGate.
  zone         = "us-central1-a"            # Zone to deploy FortiGate.
  machine_type = "n1-standard-4"            # The GCP Virtual Machine type to deploy FGT.

  # IAM variables (Optional)
  # service_account_email = "example@example.com " # The e-mail address of the service account.
                                                   # If not given, the default Google Compute Engine service account is used.

  # FortiGate image.
  # You can use "image_type" to deploy the latest public FortiGate image, or use "image_source" to deploy the custom image.
  # One of the variables "image_type" and "image_source" must be provided, otherwise an error occurs.
  # If both are provided, "image_source" will be used, and "image_type" will be ignored.
  image_type   = "fortigate-76-byol"        # The type of public FortiGate Image.
                                            # fortigate-76-byol: bring your own licenses, you need to specify cloud_function->license_source;
                                            # fortigate-76-payg: pay as you go, you don't need to specify license_source.
  # image_source = "projects/fortigcp-project-001/global/images/fortinet-fgt-760-20240726-001-w-license"  # The source of the custom image.

  network_interfaces = [                    # Network interface of your FortiGate
    # Port 1 of your FortiGate
    {
      subnet_name   = "single-fortigate-vpc1-subnet"  # The name of your existing subnet.
      private_ip    = "10.0.0.2"                      # Optional. The private ip of your FortiGate in this subnet.
                                                      # If private_ip is not specified, GCP will select a private IP for you.
      has_public_ip = true                            # Whether port 1 has public IP. Default is False.
    },
    # Port 2 of your FortiGate
    {
      subnet_name   = "single-fortigate-vpc2-subnet"
    },
    # You can specify more ports here
    # ...
  ]

  # Optional parameters
  # Additional disk for logging
  # additional_disk = {
  #   size = 30
  # }

  # If your image type is byol (bring your own license), you can license your FortiGate here.
  # Method 1, specify the license file
  # licensing = {
  #   license_file = "/path/to/license.lic"
  # }
  # Method 2, specify the fortiflex token
  # licensing = {
  #   fortiflex_token = "<fortiflex token>"
  # }

  # Add additional configuration script or config_file
  # If you specify both config_script and config_file, this terraform project will upload both of them.
  config_script = <<-EOF
config system probe-response
    set mode http-probe
end
  EOF
  config_file = "/path/to/bootstrap.conf"

  network_tags  = ["single-fortigate"]        # FortiGate network tags.
}
```

## Create a New VPC and Subnet

This `fgt_single` module assumes that you already have existing VPCs and subnets. It only requires the subnet names.

If you do not have existing VPCs, you can create them using the following scripts.

```
module "example_vpc" {
  source = "fortinetdev/cloud-modules/google//modules/gcp/vpc"

  network_name = "single-fortigate-vpc1"

  subnets = [
    {
      name          = "single-fortigate-vpc1-subnet"   # subnet name should be unique in your GCP project.
      region        = "us-central1"                    # Region of your subnet
      ip_cidr_range = "10.0.0.0/24"                    # CIDR of your subnet
    }
  ]

  firewall_rules = [
    {
      name          = "single-fortigate-vpc1-firewall"
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["single-fortigate"]             # Network tags. All GCP instances with the tag "single-fortigate" will follow this firewall rule.
      allow = [
        {
          protocol = "all"
        }
      ]
    }
  ]
}
```


## Others
**Even if `terraform apply` is complete, FortiGates require time to initialize, load licenses, which may take 5 to 10 minutes. During this period, the FortiGates will be unavailable.**