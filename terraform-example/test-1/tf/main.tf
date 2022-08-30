provider "google" {
  project     = var.project_id
  region      = var.region
}
provider "google-beta" {
  project     = var.project_id
  region      = var.region
}

module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "5.1.0"
  project_id   = var.project_id
  network_name = "test-vpc"

  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = var.region
    }
  ]
}

resource "google_service_account" "test" {
  account_id   = "service-account-one"
  display_name = "service account one"
  project      = var.project_id
}

module "vm_instance_template" {
  source          = "terraform-google-modules/vm/google//modules/instance_template"
  version         = "7.8.0"
  region          = var.region
  project_id      = var.project_id
  subnetwork      = module.vpc.subnets["us-west1/subnet-01"].self_link
  service_account = {
    email = google_service_account.test.email
    scopes = ["compute-rw", "logging-write"]
  }
}

module "vm_compute_instance" {
  source              = "terraform-google-modules/vm/google//modules/compute_instance"
  version             = "7.8.0"
  region              = var.region
  zone                = var.zone
  subnetwork          = module.vpc.subnets["us-west1/subnet-01"].self_link
  num_instances       = 1
  hostname            = "instance-simple"
  instance_template   = module.vm_instance_template.self_link
  deletion_protection = false

}
