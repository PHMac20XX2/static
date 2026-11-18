# 1) Sufixo aleatório
resource "random_string" "sufixo" {
  length  = 6
  upper   = false
  special = false
}

# 2) Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}"
  location = var.location
}

# 3) Storage Account com site estático habilitado
resource "azurerm_storage_account" "site" {
  name                     = "st${var.project_name}${random_string.sufixo.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_storage_account_static_website" "site" {
  storage_account_id = azurerm_storage_account.site.id
  index_document     = "index.html"
  error_404_document = "404.html"
}

locals {
  tipos_mime = {
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    png  = "image/png"
    jpg  = "image/jpeg"
    svg  = "image/svg+xml"
  }
}

resource "azurerm_storage_blob" "arquivos" {
  for_each = fileset("${path.module}/site", "**")

  name                   = each.value
  storage_account_name   = azurerm_storage_account.site.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "${path.module}/site/${each.value}"
  content_md5            = filemd5("${path.module}/site/${each.value}")
  content_type           = lookup(local.tipos_mime, reverse(split(".", each.value))[0], "application/octet-stream")

  depends_on = [azurerm_storage_account_static_website.site]
}