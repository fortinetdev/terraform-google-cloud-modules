To run `terraform apply` in the `"/examples/autoscale_fgt_lb_sandwich"` directory, place your license files in the `"/examples/autoscale_fgt_lb_sandwich/licenses"` folder, as the default for the `cloud_function -> license_file_folder` variable is `"./licenses"`.

If using "autoscale_fgt_lb_sandwich" as a module, create a `"licenses"` folder in your workspace and add your license files there.

Alternatively, you can store the license files in a separate folder and update the `cloud_function -> license_file_folder` variable with the new folder path.

This template uploads all `.lic` files from the `cloud_function -> license_file_folder` to a Google Cloud Bucket and uses them to activate FortiGate.