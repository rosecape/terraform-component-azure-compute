output "aks_id" {
  description = "The ID of the AKS."
  value       = module.aks.aks_id
}

output "kubelet_identity" {
  description = "The kubelet identity."
  value       = module.aks.kubelet_identity[0]
}
