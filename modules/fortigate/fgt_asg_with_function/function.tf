resource "google_pubsub_topic" "topic" {
  name = "${local.prefix}topic"
}

resource "google_logging_project_sink" "topic" {
  name                   = "${local.prefix}sink"
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.topic.id}"
  filter                 = <<-EOT
    resource.type="gce_instance" AND
    logName="projects/${var.project}/logs/cloudaudit.googleapis.com%2Factivity" AND
    (protoPayload.methodName:"compute.instances.insert" OR protoPayload.methodName:"compute.instances.delete") AND
    protoPayload.resourceName:"/zones/${var.zone}/instances/${var.prefix}" AND
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
  ]
}

# Bucket used to store google cloud functions files
resource "google_storage_bucket" "gcf_bucket" {
  name          = "${local.prefix}bucket"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_object" "license_files" {
  for_each = fileset(var.cloud_function.license_file_folder, "*.lic")
  name     = "licenses/${each.value}"
  bucket   = google_storage_bucket.gcf_bucket.name
  source   = "${var.cloud_function.license_file_folder}/${each.value}"
}

# Save secret password, need to enable Secret Manager API
resource "google_secret_manager_secret" "fortiflex_password" {
  secret_id = "${local.prefix}fortiflex-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "fortiflex_password" {
  secret      = google_secret_manager_secret.fortiflex_password.id
  secret_data = var.cloud_function.fortiflex.password
}

resource "google_secret_manager_secret_iam_member" "fortiflex_password" {
  secret_id = google_secret_manager_secret.fortiflex_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = data.google_compute_default_service_account.default.member
}

resource "google_secret_manager_secret" "instance_password" {
  secret_id = "${local.prefix}instance-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "instance_password" {
  secret      = google_secret_manager_secret.instance_password.id
  secret_data = local.fgt_password
}

resource "google_secret_manager_secret_iam_member" "instance_password" {
  secret_id = google_secret_manager_secret.instance_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = data.google_compute_default_service_account.default.member
}

# Upload cloud function
resource "google_storage_bucket_object" "function_zip" {
  name   = "function.zip"
  bucket = google_storage_bucket.gcf_bucket.name
  source = "${path.module}/cloud_function.zip"
}

resource "google_cloudfunctions2_function" "init_instance" {
  name     = "${local.prefix}function"
  location = var.region
  build_config {
    runtime     = "python312"
    entry_point = "entry_point"
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
    environment_variables = {
      PROJECT_PREFIX          = var.prefix
      LICENSE_SOURCE          = var.cloud_function.license_source
      FORTIFLEX_USERNAME      = var.cloud_function.fortiflex.username
      FORTIFLEX_CONFIG        = var.cloud_function.fortiflex.config
      FORTIFLEX_RETRIEVE_MODE = var.cloud_function.fortiflex.retrieve_mode
      PRINT_DEBUG_MSG         = var.cloud_function.print_debug_msg
      MANAGEMENT_PORT         = 443
      AUTOSCALE_PSKSECRET     = var.cloud_function.autoscale_psksecret
    }
    secret_environment_variables {
      key        = "FORTIFLEX_PASSWORD"
      project_id = var.project
      secret     = google_secret_manager_secret.fortiflex_password.secret_id
      version    = "latest"
    }
    secret_environment_variables {
      key        = "INSTANCE_PASSWORD"
      project_id = var.project
      secret     = google_secret_manager_secret.instance_password.secret_id
      version    = "latest"
    }
    vpc_connector                 = google_vpc_access_connector.vpc_connector.id
    vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
  }
  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.topic.id
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
  }
  depends_on = [
    google_secret_manager_secret_iam_member.fortiflex_password,
    google_secret_manager_secret_version.fortiflex_password,
    google_secret_manager_secret_iam_member.instance_password,
    google_secret_manager_secret_version.instance_password,
    google_pubsub_topic_iam_binding.pubsub_iam,
    google_storage_bucket_object.license_files
  ]
  lifecycle {
    ignore_changes = [
      service_config[0].environment_variables["LOG_EXECUTION_ID"]
    ]
  }
}

resource "google_vpc_access_connector" "vpc_connector" {
  name          = "${local.prefix}vpc-connector"
  region        = var.region
  network       = var.cloud_function.vpc_network
  ip_cidr_range = var.cloud_function.function_ip_range
}
