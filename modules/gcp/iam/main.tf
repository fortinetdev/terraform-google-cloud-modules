# Create a new service account
resource "google_service_account" "account" {
  account_id   = var.service_account_name
}

# Assign roles
resource "google_project_iam_member" "account_roles" {
  for_each = toset(var.roles)
  project  = var.project
  role     = each.value
  member   = "serviceAccount:${google_service_account.account.email}"
}
