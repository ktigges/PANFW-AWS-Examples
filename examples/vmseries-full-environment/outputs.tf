output "security_gwlb_service_name" {
  description = "The AWS Service Name of the created GWLB, which is suitable to use for subsequent VPC Endpoints."
  value       = { for k, v in module.gwlb : k => v.endpoint_service.service_name }
}

output "vmseries_public_ips_ew" {
  description = "Map of public IPs created within `vmseries` module instances."
  value       = { for k, v in module.vmseries : k => v.public_ips }
}
