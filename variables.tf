variable "subscription_id" {
  description = "ID da subscription Azure"
  type        = string
}

variable "location" {
  description = "Região da Azure"
  type        = string
  default     = "brazilsouth"
}

variable "project_name" {
  description = "Prefixo usado nos nomes dos recursos"
  type        = string
  default     = "sitestudo"
}