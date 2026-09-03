variable "namespace" {
  description = "Namespace Kubernetes do projeto MecaniQA"
  type        = string
  default     = "mecaniqa"
}

variable "kubeconfig_path" {
  description = "Caminho do kubeconfig local"
  type        = string
  default     = "~/.kube/config"
}
