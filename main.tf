

# Cloud function resource 
resource "google_cloudfunctions2_function" "function" {
  name = "function-v2"
  location = var.region
  description = "Cloud Function created with Atmos"

  build_config {
    runtime = "nodejs16"
    entry_point = "helloHttp"  
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }

  service_config {
    max_instance_count  = 1
    available_memory    = "256M"
    timeout_seconds     = 60
  }
}


# Storage where the lambda code zip will be stored
resource "google_storage_bucket" "bucket" {
  name     = "${var.project_id}-gcf-source"
  location = "SOUTHAMERICA-EAST1"
  uniform_bucket_level_access = true
}

# Object on the storage of the code (.zip)
resource "google_storage_bucket_object" "object" {
  name   = "js_lambda.zip" # Later move it to a repo
  bucket = google_storage_bucket.bucket.name
  source = "js_lambda.zip"  
}

# Cloud run biding to make it able to call from anywhere
resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloudfunctions2_function.function.location
  service  = google_cloudfunctions2_function.function.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}

# Output
output "function_uri" { 
  value = google_cloudfunctions2_function.function.service_config[0].uri
}
