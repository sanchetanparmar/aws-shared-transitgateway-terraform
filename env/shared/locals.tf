

data "terraform_remote_state" "shared_terraform" {
  backend = "s3"
  config = {
    bucket               = var.main_tf_backend.bucket
    key                  = var.main_tf_backend.key
    region               = var.main_tf_backend.region
    # workspace_key_prefix = var.main_tf_backend.workspace_key_prefix
  }
}
