output "dn" {
  value       = aci_rest.fvAEPg.id
  description = "Distinguished name of `fvAEPg` object."
}

output "name" {
  value       = aci_rest.fvAEPg.content.name
  description = "Endpoint group name."
}
