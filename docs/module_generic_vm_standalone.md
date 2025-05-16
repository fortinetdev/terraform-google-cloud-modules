# Module: Deploy one Forti Product - generic_vm_standalone

Deploy any Forti products (e.g., FortiGate, FortiAnalyzer, FortiManager... ) and using existing VPCs.

This module can be used to create FortiManager, FortiAnalyzer, FortiGuest, FortiAIOps and more by changing the `image_type` or `image_source` to the [target value](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/guide_image.md#image-list).

This `generic_vm_standalone` module assumes that you already have existing VPCs and subnets. It only requires the subnet names. You can check the [example scripts](#example-scripts) for how to create VPC and VM together.

## Example scripts

Following script create one VPC, and Forti products (FortiGate / FortiAnalyzer / FortiManager / FortiGuest / FortiAIOPS), please only keep the product you need to deploy. 

```
module "example_vpc" {
  source = "fortinetdev/cloud-modules/google//modules/gcp/vpc"

  network_name = "generic-vm-vpc"

  subnets = [
    {
      name          = "generic-vm-subnet"        # Subnet name should be unique in your GCP project.
      region        = "us-central1"              # Region of your subnet
      ip_cidr_range = "10.0.0.0/24"              # CIDR of your subnet
    }
  ]

  firewall_rules = [
    {
      name          = "generic-vm-firewall"
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["generic-vm"]             # Network tags. All GCP instances with the tag "generic-vm" will follow this firewall rule.
      # Option 1: Allow specific protocols and ports
      allow = [
        {
          protocol = "tcp"                       # Required. The protocol you want to allow. You can specify "all" to allow all protocols.
          ports = ["22", "80", "443"]            # Optional. The ports you want to open. If not specified, all ports will be opened.
        }
      ]
      # # Option 2: Allow all protocols and ports
      # allow = [
      #   {
      #     protocol = "all"          
      #   }
      # ]
    }
  ]
}

# FortiGate
module "fortigate_example" {
  source = "fortinetdev/cloud-modules/google//modules/fortinet/generic_vm_standalone"
  
  # default username is "admin" and password is instance_id
  prefix       = "fortigate-example"        # The prefix name of all Google Cloud resources created by this module.
  hostname     = "fortigate-example"        # The hostname of your VM.
  # password     = "<Your password>"        # The password of your VM, if not specified, the default password is the instance_id.
  region       = "us-central1"              # Region to deploy VM.
  zone         = "us-central1-a"            # Zone to deploy VM.
  machine_type = "n2-standard-8"            # The GCP Virtual Machine type to deploy FGT.

  image = {
    product = "fortigate"
    version = "7.6.2"
    lic     = "payg"
    arch    = "x64"
  }
  # image = {
  #   family = "fortigate-76-byol"
  # }
  # image = {
  #   source = "projects/fortigcp-project-001/global/images/fortinet-fgtondemand-762-20250130-001-w-license"
  # }

  network_interfaces = [                    # Network interface of your VM
    {
      subnet_name   = "generic-vm-subnet"  # The name of your existing subnet.
      has_public_ip = true                 # Whether port 1 has public IP. Default is False.
    },
  ]
  network_tags  = ["generic-vm"]           # VM network tags.
  depends_on = [ module.example_vpc ]
}

# FortiAnalyzer
module "fortianalyzer_example" {
  source = "fortinetdev/cloud-modules/google//modules/fortinet/generic_vm_standalone"
  
  # default username is "admin" and password is instance_id
  prefix       = "fortianalyzer-example"    # The prefix name of all Google Cloud resources created by this module.
  hostname     = "fortianalyzer-example"    # The hostname of your VM.
  # password     = "<Your password>"        # The password of your VM, if not specified, the default password is the instance_id.
  region       = "us-central1"              # Region to deploy VM.
  zone         = "us-central1-a"            # Zone to deploy VM.
  machine_type = "n1-standard-4"            # The GCP Virtual Machine type to deploy FGT.

  image = {
    product = "fortianalyzer"
    version = "7.6.2"
  }
  # image = {
  #   family = "fortianalyzer-76-byol"
  # }
  # image = {
  #   source = "projects/fortigcp-project-001/global/images/fortinet-faz-762-20241218-001-w-license"
  # }

  disks = [{ size = 30 }]
  network_interfaces = [                    # Network interface of your VM
    {
      subnet_name   = "generic-vm-subnet"   # The name of your existing subnet.
      has_public_ip = true                  # Whether port 1 has public IP. Default is False.
    },
  ]
  network_tags  = ["generic-vm"]           # VM network tags.
  # license = {
  #   license_file = "/path/to/license/file.lic"
  # }
  depends_on = [ module.example_vpc ]
}

# FortiManager
module "fortimanager_example" {
  source = "fortinetdev/cloud-modules/google//modules/fortinet/generic_vm_standalone"
  
  # default username is "admin" and password is instance_id
  prefix       = "fortimanager-example"     # The prefix name of all Google Cloud resources created by this module.
  hostname     = "fortimanager-example"     # The hostname of your VM.
  # password     = "<Your password>"        # The password of your VM, if not specified, the default password is the instance_id.
  region       = "us-central1"              # Region to deploy VM.
  zone         = "us-central1-a"            # Zone to deploy VM.
  machine_type = "n1-standard-4"            # The GCP Virtual Machine type to deploy FGT.

  image = {
    product = "fortimanager"
    version = "7.6.2"
  }
  # image = {
  #   family = "fortimanager-76-byol"
  # }
  # image = {
  #   source = "projects/fortigcp-project-001/global/images/fortinet-fmg-762-20241218-001-w-license"
  # }

  disks = [{ size = 30 }]
  network_interfaces = [                    # Network interface of your VM
    {
      subnet_name   = "generic-vm-subnet"   # The name of your existing subnet.
      has_public_ip = true                  # Whether port 1 has public IP. Default is False.
    },
  ]
  network_tags  = ["generic-vm"]            # VM network tags.
  # license = {
  #   license_file = "/path/to/license/file.lic"
  # }
  depends_on = [ module.example_vpc ]
}

# FortiGuest
module "fortiguest_example" {
  source = "fortinetdev/cloud-modules/google//modules/fortinet/generic_vm_standalone"
  
  # predefined password and license are not working for fortiguest
  # default username is "admin" and password is "" (empty)
  prefix       = "fortiguest-example"       # The prefix name of all Google Cloud resources created by this module.
  hostname     = "fortiguest-example"       # The hostname of your VM.
  region       = "us-central1"              # Region to deploy VM.
  zone         = "us-central1-a"            # Zone to deploy VM.
  machine_type = "n1-standard-4"            # The GCP Virtual Machine type to deploy FGT.

  image = {
    product = "fortiguest"
    version = "2.0.0"
  }
  # image = {
  #   source = "projects/fortigcp-project-001/global/images/fortiguest-200-build0205-lic"
  # }

  disks = [{ size = 30 }]
  network_interfaces = [                    # Network interface of your VM
    {
      subnet_name   = "generic-vm-subnet"   # The name of your existing subnet.
      has_public_ip = true                  # Whether port 1 has public IP. Default is False.
    },
  ]
  network_tags  = ["generic-vm"]            # VM network tags.
  depends_on = [ module.example_vpc ]
}

# FortiAIOPS
module "fortiaiops_example" {
  source = "fortinetdev/cloud-modules/google//modules/fortinet/generic_vm_standalone"

  # predefined password and license are not working for fortiaiops
  # default username is "admin" and password is "admin"
  prefix       = "fortiaiops-example"       # The prefix name of all Google Cloud resources created by this module.
  hostname     = "fortiaiops-example"       # The hostname of your VM.
  region       = "us-central1"              # Region to deploy VM.
  zone         = "us-central1-a"            # Zone to deploy VM.
  machine_type = "n1-standard-4"            # The GCP Virtual Machine type to deploy FGT.
  
  image = {
    product = "fortiaiops"
    version = "2.1.0"
  }
  # image = {
  #   source = "projects/fortigcp-project-001/global/images/fortiaiops-210-build0313-lic"
  # }

  disks = [{ size = 30 }]                   # This disk is required for fortiaiops
  network_interfaces = [                    # Network interface of your VM
    {
      subnet_name   = "generic-vm-subnet"   # The name of your existing subnet.
      has_public_ip = true                  # Whether port 1 has public IP. Default is False.
    },
  ]
  network_tags  = ["generic-vm"]            # VM network tags.
  depends_on = [ module.example_vpc ]
}

```

## All possible options

Following is a template with all possible options and descriptions.

```
module "example_forti_instance" {
  source = "fortinetdev/cloud-modules/google//modules/fortinet/generic_vm_standalone"

  prefix   = "single-fortigate"             # The prefix name of all Google Cloud resources created by this module.
  hostname = "single-fortigate"             # The name of your Instance. If not set, it will be <prefix>-instance.
  # password     = "<Your admin password>"  # Optional. If not set, it will be the GCP instance id. This variable is not working for FortiGuest and FortiAIOPS.
  region       = "us-central1"              # Region to deploy instance.
  zone         = "us-central1-a"            # Zone to deploy instance.
  machine_type = "n1-standard-4"            # The GCP Virtual Machine type to deploy FGT.

  # IAM variables (Optional)
  # service_account_email = "example@example.com " # The e-mail address of the service account.
                                                   # If not given, the default Google Compute Engine service account is used.

  # Image. There are 3 ways to specify the image.
  # 1. Specify the image product and version (for FortiGate, you also need to specify the lic and arch).
  image = {
    product = "fortigate"
    version = "7.6.2"
    lic     = "payg"
    arch    = "x64"
  }
  
  # 2. Specify the image family (e.g. fortigate-76-byol, fortigate-76-payg).
  # image = {
  #   family = "fortigate-76-byol"
  # }

  # 3. Specify the image source.
  # image = {
  #   source = "projects/fortigcp-project-001/global/images/fortinet-fgtondemand-762-20250130-001-w-license"
  # }


  network_interfaces = [                              # Network interface of your Instance
    # Port 1 of your instance
    {
      subnet_name   = "single-fortigate-vpc1-subnet"  # The name of your existing subnet.
      private_ip    = "10.0.0.2"                      # Optional. The private ip of your instance in this subnet.
                                                      # If private_ip is not specified, GCP will select a private IP for you.
      has_public_ip = true                            # Whether port 1 has public IP. Default is False.
    },
    # Port 2 of your instance
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

  # If your image type is byol (bring your own license), you can license your instance here.
  # (license is not working for FortiGuest and FortiAIOPS)
  # Method 1, specify the license file
  # license = {
  #   license_file = "/path/to/license.lic"
  # }
  # Method 2, specify the fortiflex token
  # license = {
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

  network_tags  = ["Your-firewall-tag"]        # Instance network tags. This instance will follow the firewall rules bound to this tag.
}

output "public_ips" {
  value = module.example_forti_instance.public_ips
  description = "List of private IPs for each network interface."
}
output "private_ips" {
  value = module.example_forti_instance.private_ips
  description = "List of public IPs for each network interface (or empty string if none)"
}
```


## Others
**Even if `terraform apply` is complete, the instance requires time to initialize, load licenses, which may take 5 to 10 minutes. During this period, the instance will be unavailable.**