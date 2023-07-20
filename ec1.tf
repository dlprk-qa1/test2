module "emr-cluster_example_complete" {
  source  = "cloudposse/emr-cluster/aws//examples/complete"
  version = "1.1.0"
  # insert the 19 required variables here
}
  
module "config_example_complete" {
  source  = "cloudposse/config/aws//examples/complete"
  version = "0.16.0"
  # insert the 2 required variables here
}
