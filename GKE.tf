resource "google_container_cluster" "example" {
  #zpc-skip-policy: ZS-GCP-00128,ZS-GCP-00130,ZS-GCP-00131,ZS-GCP-00132,ZS-GCP-00133,ZS-GCP-00134,ZS-GCP-00135,ZS-GCP-00136,ZS-GCP-00129:testing
  name               = var.name
  location           = var.location
  project            = data.google_project.project.name
  enable_binary_authorization = false
  enable_intranode_visibility = false
  enable_shielded_nodes = true
  node_config {
    shielded_instance_config {
      enable_integrity_monitoring = false
    }
     workload_metadata_config {
      node_metadata = "METADATA_SERVER_NAME"
    }
  }
  private_cluster_config {
       enable_private_nodes    = false
       enable_private_endpoint = false
       master_ipv4_cidr_block  = false
    }
}
