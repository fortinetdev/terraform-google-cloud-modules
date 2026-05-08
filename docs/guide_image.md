# Guide: Image

## How to Specify Image

All FortiGate-related modules and examples include two image-related variables: `image_type` and `image_source`. If both are specified, `image_source` takes precedence.
- `image_type`: Defines the type of public FortiGate image.
  - `"fortigate-76-byol"` Uses the latest FortiGate 7.6 and Bring Your Own License (BYOL).
  - `"fortigate-76-payg"` Uses the latest FortiGate 7.6 and Pay-As-You-Go (PAYG), where licensing fees are billed based on the machine type.
- `image_source`: Specifies a custom image
  - Example format: `"projects/<YOUR-PROJECT-NAME>/global/images/<YOUR-IMAGE-NAME>"`. 

### Official Image Source

All official images are stored in the project `fortigcp-project-001`. To view the available official images, run the following command:

```
gcloud compute images list --project=fortigcp-project-001
```

To use a specific version of an official image, set following in your terraform file:
```
image_source = "projects/fortigcp-project-001/global/images/<IMAGE-NAME>"
```

### Upload Your Custom Image

Use the following script to upload your custom image.

Your image source will follow this format: `"projects/<YOUR-PROJECT-NAME>/global/images/<YOUR-IMAGE-NAME>"`.

```hcl
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "image_bucket" {
  name     = "custom-image-bucket-${random_id.bucket_suffix.hex}"
  location = "US"
}

resource "google_storage_bucket_object" "image_file" {
  name   = "custom_image.tar.gz"
  bucket = google_storage_bucket.image_bucket.name
  source = "/path/to/local/image.tar.gz"
}

resource "google_compute_image" "custom_image" {
  name = "<YOUR-IMAGE-NAME>"
  raw_disk {
    source = google_storage_bucket_object.image_file.self_link
  }
  project     = "<YOUR-PROJECT-NAME>"
  description = "Custom image for Fortinet FGT"
}
```

## Image List

You can find the value of `image_source` for all versions [here](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/modules/fortinet/generic_vm_standalone/image_lookup.json).

### FortiGate
FortiGate has both BYOL (Bring your own license) and PAYG (pay as you go) images.

| Image  | Vaule of `image_source`  |
|------|------|
| FGT 8.0.0 PAYG  | projects/fortigcp-project-001/global/images/fortinet-fgtondemand-800-20260423-001-w-license |
| FGT 7.6.6 PAYG  | projects/fortigcp-project-001/global/images/fortinet-fgtondemand-766-20260129-001-w-license |
| FGT 7.4.11 PAYG  | projects/fortigcp-project-001/global/images/fortinet-fgtondemand-7411-20260129-001-w-license |
| FGT 7.2.13 PAYG  | projects/fortigcp-project-001/global/images/fortinet-fgtondemand-7213-20260202-001-w-license |
| FGT 7.0.19 PAYG  | projects/fortigcp-project-001/global/images/fortinet-fgtondemand-7019-20260202-001-w-license |


| Image  | Vaule of `image_source`  |
|------|------|
| FGT 8.0.0 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fgt-800-20260423-001-w-license |
| FGT 7.6.6 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fgt-766-20260129-001-w-license |
| FGT 7.4.11 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fgt-7411-20260129-001-w-license |
| FGT 7.2.13 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fgt-7213-20260202-001-w-license |
| FGT 7.0.19 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fgt-7019-20260202-001-w-license |


### FortiManager

FortiManager only has BYOL (Bring your own license) images.

| Image  | Vaule of `image_source`  |
|------|------|
| FMG 8.0.0 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fmg-800-20260423-001-w-license |
| FMG 7.6.6 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fmg-766-20260212-001-w-license |
| FMG 7.4.10 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fmg-7410-20260212-001-w-license |
| FMG 7.2.12 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fmg-7212-20260212-001-w-license |
| FMG 7.0.16 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fmg-7016-20260212-001-w-license |

### FortiAnalyzer

FortiAnalyzer only has BYOL (Bring your own license) images.

| Image  | Vaule of `image_source`  |
|------|------|
| FAZ 8.0.0 BYOL  | projects/fortigcp-project-001/global/images/fortinet-faz-800-20260423-001-w-license |
| FAZ 7.6.6 BYOL  | projects/fortigcp-project-001/global/images/fortinet-faz-766-20260212-001-w-license |
| FAZ 7.4.10 BYOL  | projects/fortigcp-project-001/global/images/fortinet-faz-7410-20260212-001-w-license |
| FAZ 7.2.12 BYOL  | projects/fortigcp-project-001/global/images/fortinet-faz-7212-20260212-001-w-license |
| FAZ 7.0.16 BYOL  | projects/fortigcp-project-001/global/images/fortinet-faz-7016-20260212-001-w-license |

### FortiAIOps

| Image  | Vaule of `image_source`  |
|------|------|
| FortiAIOps 3.2.1  | projects/fortigcp-project-001/global/images/fortiaiops-321-build0158-lic |

### FortiGuest

| Image  | Vaule of `image_source`  |
|------|------|
| FortiGuest 2.4.2  | projects/fortigcp-project-001/global/images/fortiguest-242-build0520-lic |
