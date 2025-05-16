# Function Trigger
resource "google_pubsub_topic" "topic" {
  name = "${local.prefix}topic"
}

resource "google_logging_project_sink" "topic" {
  name                   = "${local.prefix}sink"
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.topic.id}"
  filter                 = <<-EOT
    resource.type="gce_instance" AND
    logName="projects/${var.project}/logs/cloudaudit.googleapis.com%2Factivity" AND
    (protoPayload.methodName:"compute.instances.insert" OR protoPayload.methodName:"compute.instances.delete" OR protoPayload.methodName:"compute.instances.update") AND
    protoPayload.resourceName=~"/zones/${var.region}-./instances/${var.prefix}" AND
    operation.last=true
  EOT
  unique_writer_identity = true # Use a unique writer
}

# Grant writer access because of unique_writer_identity in topic
resource "google_pubsub_topic_iam_binding" "pubsub_iam" {
  topic = google_pubsub_topic.topic.name
  role  = "roles/pubsub.publisher"

  members = [
    google_logging_project_sink.topic.writer_identity,
    local.iam_member
  ]
}

# Bucket
resource "google_storage_bucket" "gcf_bucket" {
  name                        = local.bucket_name
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = var.bucket.uniform_bucket_level_access # Allow uniform bucket level access
}

resource "random_string" "bucket_id" {
  length  = 8
  lower   = true
  upper   = false
  special = false
  numeric = true
}

resource "google_storage_bucket_object" "license_files" {
  for_each = fileset(var.cloud_function.license_file_folder, "*.lic")
  name     = "licenses/${each.value}"
  bucket   = google_storage_bucket.gcf_bucket.name
  source   = "${var.cloud_function.license_file_folder}/${each.value}"
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "function.zip"
  bucket = google_storage_bucket.gcf_bucket.name
  source = "${path.module}/cloud_function.zip"
}

# Save secret password, need to enable Secret Manager API
resource "google_secret_manager_secret" "fortiflex_password" {
  count     = local.use_fortiflex_passwd ? 1 : 0
  secret_id = "${local.prefix}fortiflex-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "fortiflex_password" {
  count       = local.use_fortiflex_passwd ? 1 : 0
  secret      = google_secret_manager_secret.fortiflex_password[0].id
  secret_data = var.cloud_function.fortiflex.password
}

resource "google_secret_manager_secret" "instance_password" {
  count     = local.use_fgt_passwd ? 1 : 0
  secret_id = "${local.prefix}instance-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "instance_password" {
  count       = local.use_fgt_passwd ? 1 : 0
  secret      = google_secret_manager_secret.instance_password[0].id
  secret_data = local.fgt_password
}

# Cloud Function
resource "google_cloudfunctions2_function" "init_instance" {
  name     = "${local.prefix}function"
  location = var.region
  build_config {
    runtime         = "python312"
    entry_point     = "entry_point"
    service_account = var.cloud_function.build_service_account_email != "" ? "projects/${var.project}/serviceAccounts/${var.cloud_function.build_service_account_email}" : null
    source {
      storage_source {
        bucket = google_storage_bucket.gcf_bucket.name
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }
  service_config {
    max_instance_count               = var.cloud_function.service_config.max_instance_count
    max_instance_request_concurrency = var.cloud_function.service_config.max_instance_request_concurrency
    available_cpu                    = var.cloud_function.service_config.available_cpu
    available_memory                 = var.cloud_function.service_config.available_memory
    timeout_seconds                  = var.cloud_function.service_config.timeout_seconds
    ingress_settings                 = var.cloud_function.service_config.ingress_settings
    vpc_connector_egress_settings    = var.cloud_function.service_config.egress_settings
    service_account_email            = local.service_account_email
    environment_variables = merge({
      PROJECT_PREFIX          = var.prefix
      LICENSE_SOURCE          = var.cloud_function.license_source
      FORTIFLEX_USERNAME      = var.cloud_function.fortiflex.username
      FORTIFLEX_CONFIG        = var.cloud_function.fortiflex.config
      FORTIFLEX_RETRIEVE_MODE = var.cloud_function.fortiflex.retrieve_mode
      LOGGING_LEVEL           = var.cloud_function.logging_level
      CLOUD_FUNC_IP_RANGE     = var.cloud_function.function_ip_range
      AUTOSCALE_PSKSECRET     = var.cloud_function.autoscale_psksecret
      BUCKET_NAME             = local.bucket_name
      ELB_IP_LIST             = jsonencode([for interface in var.network_interfaces : interface.elb_ip])
      ILB_IP_LIST             = jsonencode([for interface in var.network_interfaces : interface.ilb_ip])
    },
    try(var.fmg_integration.ums, null) != null ? { SKIP_CONFIG = "autoscale" } : {},
    var.cloud_function.additional_variables
  )

    dynamic "secret_environment_variables" {
      for_each = local.use_fortiflex_passwd ? [1] : []
      content {
        key        = "FORTIFLEX_PASSWORD"
        project_id = var.project
        secret     = google_secret_manager_secret.fortiflex_password[0].secret_id
        version    = "latest"
      }
    }
    dynamic "secret_environment_variables" {
      for_each = local.use_fgt_passwd ? [1] : []
      content {
        key        = "INSTANCE_PASSWORD"
        project_id = var.project
        secret     = google_secret_manager_secret.instance_password[0].secret_id
        version    = "latest"
      }
    }
    vpc_connector = google_vpc_access_connector.vpc_connector.id
  }
  event_trigger {
    trigger_region        = var.region
    event_type            = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic          = google_pubsub_topic.topic.id
    retry_policy          = "RETRY_POLICY_DO_NOT_RETRY"
    service_account_email = var.cloud_function.trigger_service_account_email == "" ? null : var.cloud_function.trigger_service_account_email
  }
  depends_on = [
    google_storage_bucket_iam_member.bucket_access,
    google_secret_manager_secret_iam_member.fortiflex_password,
    google_secret_manager_secret_version.fortiflex_password,
    google_secret_manager_secret_iam_member.instance_password,
    google_secret_manager_secret_version.instance_password,
    google_pubsub_topic_iam_binding.pubsub_iam,
    google_storage_bucket_object.license_files,
  ]
  lifecycle {
    ignore_changes = [
      service_config[0].environment_variables["LOG_EXECUTION_ID"]
    ]
    replace_triggered_by = [google_storage_bucket_object.function_zip.detect_md5hash]
  }
}

resource "time_sleep" "wait_after_function_creation" {
  count           = var.special_behavior.function_creation_wait_sec > 0 ? 1 : 0
  create_duration = "${var.special_behavior.function_creation_wait_sec}s"
  depends_on      = [google_cloudfunctions2_function.init_instance]
}

resource "time_sleep" "wait_before_function_destruction" {
  count            = var.special_behavior.function_destruction_wait_sec > 0 ? 1 : 0
  destroy_duration = "${var.special_behavior.function_destruction_wait_sec}s"
  depends_on       = [google_cloudfunctions2_function.init_instance]
}

resource "google_vpc_access_connector" "vpc_connector" {
  name          = "${local.prefix}vpc-con"
  region        = var.region
  network       = var.cloud_function.vpc_network
  ip_cidr_range = var.cloud_function.function_ip_range
  max_instances = 3 # For google provider 6.0 compatibility issue
  min_instances = 2 # For google provider 6.0 compatibility issue
}
