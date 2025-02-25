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

#### FortiGate
FortiGate has both BYOL (Bring your own license) and PAYG (pay as you go) images.

| Image  | Vaule of `image_source`  |
|------|------|
| FMG 7.6.2 PAYG  | projects/fortigcp-project-001/global/images/fortinet-fgtondemand-762-20250130-001-w-license |
| FMG 7.6.1 PAYG  | projects/fortigcp-project-001/global/images/fortinet-fgtondemand-761-20241128-001-w-license |
| FMG 7.6.0 PAYG  | projects/fortigcp-project-001/global/images/fortinet-fgtondemand-760-20240726-001-w-license |
| FMG 7.4.7 PAYG  | projects/fortigcp-project-001/global/images/fortinet-fgtondemand-747-20250123-001-w-license |
| FMG 7.4.6 PAYG  | projects/fortigcp-project-001/global/images/fortinet-fgtondemand-746-20241213-001-w-license |
| FMG 7.2.10 PAYG  | projects/fortigcp-project-001/global/images/fortinet-fgtondemand-7210-20240920-001-w-license |
| FMG 7.2.9 PAYG  | projects/fortigcp-project-001/global/images/fortinet-fgtondemand-729-20240816-001-w-license |
| FMG 7.0.17 PAYG  | projects/fortigcp-project-001/global/images/fortinet-fgtondemand-7017-20250116-001-w-license |
| FMG 7.0.16 PAYG  | projects/fortigcp-project-001/global/images/fortinet-fgtondemand-7016-20241024-001-w-license |


| Image  | Vaule of `image_source`  |
|------|------|
| FMG 7.6.2 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fgt-762-20250130-001-w-license |
| FMG 7.6.1 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fgt-761-20241128-001-w-license |
| FMG 7.6.0 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fgt-760-20240726-001-w-license |
| FMG 7.4.7 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fgt-747-20250123-001-w-license |
| FMG 7.4.6 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fgt-746-20241213-001-w-license |
| FMG 7.2.10 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fgt-7210-20240920-001-w-license |
| FMG 7.2.9 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fgt-729-20240816-001-w-license |
| FMG 7.0.17 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fgt-7017-20250116-001-w-license |
| FMG 7.0.16 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fgt-7016-20241024-001-w-license |


#### FortiManager

FortiManager only has BYOL (Bring your own license) images.

| Image  | Vaule of `image_source`  |
|------|------|
| FMG 7.6.2 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fmg-762-20241218-001-w-license |
| FMG 7.6.1 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fmg-761-20241025-001-w-license |
| FMG 7.6.0 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fmg-760-20240731-001-w-license |
| FMG 7.4.5 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fmg-745-20241023-001-w-license |
| FMG 7.4.4 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fmg-744-20240918-001-w-license |
| FMG 7.2.9 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fmg-729-20241218-001-w-license |
| FMG 7.2.8 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fmg-728-20241023-001-w-license |
| FMG 7.0.13 BYOL  | projects/fortigcp-project-001/global/images/fortinet-fmg-7013-20241023-001-w-license |

#### FortiAnalyzer

FortiAnalyzer only has BYOL (Bring your own license) images.

| Image  | Vaule of `image_source`  |
|------|------|
| FAZ 7.6.2 BYOL  | projects/fortigcp-project-001/global/images/fortinet-faz-762-20241218-001-w-license |
| FAZ 7.6.1 BYOL  | projects/fortigcp-project-001/global/images/fortinet-faz-761-20241025-001-w-license |
| FAZ 7.6.0 BYOL  | projects/fortigcp-project-001/global/images/fortinet-faz-760-20240801-001-w-license |
| FAZ 7.4.5 BYOL  | projects/fortigcp-project-001/global/images/fortinet-faz-745-20241023-001-w-license |
| FAZ 7.4.4 BYOL  | projects/fortigcp-project-001/global/images/fortinet-faz-744-20240918-001-w-license |
| FAZ 7.2.9 BYOL  | projects/fortigcp-project-001/global/images/fortinet-faz-729-20241218-001-w-license |
| FAZ 7.2.8 BYOL  | projects/fortigcp-project-001/global/images/fortinet-faz-728-20241023-001-w-license |
| FAZ 7.0.13 BYOL  | projects/fortigcp-project-001/global/images/fortinet-faz-7013-20241023-001-w-license |
