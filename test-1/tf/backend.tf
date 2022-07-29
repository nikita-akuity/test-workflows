terraform {
  backend "kubernetes" {
    secret_suffix     = "test"
    namespace         = "wf"
    in_cluster_config = true
  }
}
