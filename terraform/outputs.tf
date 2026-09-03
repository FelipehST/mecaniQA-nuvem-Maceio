output "namespace_name" {
  description = "Namespace criado pelo Terraform"
  value       = kubernetes_namespace_v1.mecaniqa.metadata[0].name
}
