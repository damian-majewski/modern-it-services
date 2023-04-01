provider "google" {
  project = "my-gcp-project"
  region  = "us-central1"
}

resource "google_container_cluster" "example" {
  name               = "example-cluster"
  location           = "us-central1-a"
  initial_node_count = 3

  master_auth {
    username = "exampleuser"
    password = "examplepassword"
  }

  node_config {
    machine_type = "n1-standard-1"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
