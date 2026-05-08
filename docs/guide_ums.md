# Guide: User Managed Scaling (UMS)

User Managed Scaling (UMS) allows FortiManager to manage FortiGate autoscale instances on GCP. When UMS is enabled in this project, FortiManager handles device onboarding, license installation, and autoscale group management.

Set `fmg_integration.ums` to enable UMS mode. When UMS mode is enabled, this project does not create Cloud Functions or Firestore resources. Any parameters configured under `cloud_function` are ignored, because the related tasks are handled by FortiManager.

For the FortiManager side workflow, please check the Fortinet document library: [UMS installation Guide for GCP](https://docs.fortinet.com/document/fortimanager-public-cloud/8.0.0/gcp-administration-guide/459889/ums-installation-guide-for-gcp).

## Supported Examples

UMS is supported by examples that use the `modules/fortigate/fgt_asg_with_function` module, including:

- `examples/autoscale_fgt_lb_sandwich`
- `examples/autoscale_fgt_as_hub`

## Prerequisites

- A Terraform environment with permissions to create GCP resources.
- A FortiManager instance with a known public IP address and serial number. You can deploy one by using the [generic_vm_standalone](https://github.com/fortinetdev/terraform-google-cloud-modules/blob/main/docs/module_generic_vm_standalone.md) module.
- A GCP service account or default Compute Engine service account with enough permission for the SDN connector to read the managed instance group.
- FortiGate license source. Use either FortiGate license files or a [FortiFlex API user](https://docs.fortinet.com/document/fortimanager-public-cloud/8.0.0/gcp-administration-guide/794785/configure-a-fortiflex-user-and-permission-profile).


## Configure FortiManager

[Document Library: Configure the FortiManager](https://docs.fortinet.com/document/fortimanager-public-cloud/8.0.0/gcp-administration-guide/467817/configure-the-fortimanager)

Enable VM management and device registration on FortiManager:

```text
config system global
    set fgfm-allow-vm enable
end
config system admin setting
    set allow_register enable
    set register_passwd <FMG_REGISTER_PASSWORD>
end
```

Create an API admin user for UMS onboarding:

```text
config system admin user
    edit "ums_api_user"
        set trusthost1 <TRUSTED_SUBNET> <NETMASK>
        set profileid "Super_User"
        set user_type api
        set rpc-permit read-write
        set autoreg-user enable
    next
end
```

In FortiManager GUI, go to **System Settings > Administrators**, select the API user, and regenerate the API key. Save this value for `fmg_integration.ums.api_key`.

Then configure the following in FortiManager GUI:

1. Create a GCP SDN connector under **Fabric View > External Connectors**.
2. Enable **User Managed Scaling** in **Policy & Objects > (click any item in the left navigation pane) > Tools > Feature Visibility**.
3. Create a UMS entry under **Policy & Objects > Security Fabric > User Managed Scaling** and bind it to the GCP SDN connector.
4.  If you are using FortiFlex (Flex-VM) licenses, see [FortiFlex Connector with a specific Configuration ID](https://docs.fortinet.com/document/fortimanager-public-cloud/8.0.0/gcp-administration-guide/490828/fortiflex-connector-with-a-specific-configuration-id) for instructions on creating a FortiFlex connector.
5. Create an auto onboarding rule under **Device Manager > Device & Group > Add Device (dropdown menu) > Auto Onboarding**. Select Create New to create a new onboarding rule entry. Set following fields:
    - "Type": "Administrator"
    - "Administrator": "ums_api_user" (The user we created in step 1)
    - "ADOM": "root
    - "Platform": "All Platforms"
    - "Device Group": "Managed FortiGate"
    - "Install License": "BYOL License" or "Flex VM"
    - "Install Configuration": "Disable", "By Device Group" or "Manual Configuration"
    - "Maximum Device Number": Any number you want. (e.g., 4)
    - Click "OK"
6. If you are using BYOL licenses, add the licenses to **Device Manager > Device & Group > Add Device > Auto Onboarding > License Pool**

## Configure Terraform

Set `fmg_integration.ums` in the Terraform scripts.

```hcl
fmg_integration = {
  ip = "<FMG_PUBLIC_IP>"
  sn = "<FMG_SERIAL_NUMBER>"
  ums = {
    autoscale_psksecret = "<RANDOM_STRING>"
    fmg_reg_password    = "<FMG_REGISTER_PASSWORD>"
    sync_interface      = "port1"
    api_key             = "<FMG_API_KEY>"
  }
}
```

UMS fields:

- `ip`: FortiManager public IP address.
- `sn`: FortiManager serial number.
- `ums.autoscale_psksecret`: Secret used by FortiGate instances for autoscale synchronization.
- `ums.fmg_reg_password`: FortiManager device registration password configured by `set register_passwd`.
- `ums.sync_interface`: FortiGate interface used for synchronization with FortiManager. Default is `port1`.
- `ums.api_key`: FortiManager API key. Required when the FortiGate image is BYOL.


Deploy with Terraform:

```shell
terraform init
terraform apply
```

## Verify Deployment

After deployment, FortiManager should discover the FortiGate instances, authorize them through the auto onboarding rule, install the selected license, and manage them in the configured ADOM and device group.

To access a FortiGate GUI from FortiManager, go to **Device Manager > Device & Group**, right-click the FortiGate, and select **Remote Access**.

## Troubleshooting

- If the managed instance group is not visible in FortiManager, check the GCP SDN connector and the IAM permissions used by the connector.
- If autoscale group count fields are empty, verify that the SDN connector can read the target project, region, and managed instance group.
- If FortiGate devices are not onboarded, verify `fgfm-allow-vm`, `allow_register`, `register_passwd`, the API admin key, and the auto onboarding rule.
- If BYOL licensing fails, verify that the FortiManager BYOL license pool has available licenses and that `fmg_integration.ums.api_key` is set.
- If FortiFlex licensing fails, verify the FortiFlex connector, permission profile, and configuration ID in FortiManager.
