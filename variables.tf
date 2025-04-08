variable "env" {
  type        = string
  description = "Environment name (e.g. dev, prod)"
  default     = "dev"
}

variable "loc" {
  type        = string
  description = "Short location code (e.g. uks)"
  default     = "uks"
}

variable "location" {
  type        = string
  description = "Azure location name (e.g. uksouth)"
  default     = "uksouth"
}

variable "project_name" {
  type        = string
  description = "Short name for the project"
  default     = "az-ai-reviews"
}

# variable "b2c_tenant_id" {
#   type        = string
#   description = "Azure B2C tenant ID (GUID) if required for AD provider."
#   default     = ""
# }

variable "tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default = {
    environment = "dev"
  }
}

# test