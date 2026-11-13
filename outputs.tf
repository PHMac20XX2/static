output "url_do_site" {
  description = "URL pública do site estático"
  value       = azurerm_storage_account.site.primary_web_endpoint
}