provider "kubernetes" {
  config_path = pathexpand(var.kubeconfig_path)
}

resource "kubernetes_namespace_v1" "mecaniqa" {
  metadata {
    name = var.namespace

    labels = {
      project = "mecaniqa"
      managed = "terraform"
    }
  }
}
