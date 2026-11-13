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

  static_website {
    index_document     = "index.html"
    error_404_document = "index.html"
  }
}

# 4) Upload do index.html
resource "azurerm_storage_blob" "index" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.site.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/html"
  source                 = "${path.module}/site/index.html"
  content_md5            = filemd5("${path.module}/site/index.html")
}