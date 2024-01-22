variable "credentials" {
  description = "My Credentials"
  default     = "./keys/my-creds.json"
}

variable "project" {
  description = "Project"
  default     = "ny-taxi-2024"
}

variable "region" {
  description = "Project Region"
  default     = "us-east4"
}

variable "location" {
  description = "Project Location"
  default     = "US"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "homework_dataset"
}

variable "gcs_bucket_name" {
  description = "Bucket Storage Name"
  default     = "ny-taxi-2024-homework-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}
