variable "db_name" {
  description = "Name of the glue database"
  type        = string
}

variable "description" {
  description = "Description of the glue database"
  type        = string
  default     = ""
}

variable "custom_db_name" {
  description = "Use the db_name as is without any modifications"
  type        = bool
  default     = false
}

variable "location_uri" {
  description = "Location URI for the database"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment for resource tagging"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags for the database"
  type        = map(string)
  default     = {}
}

variable "lf_tags" {
  description = "Lake Formation tags to apply to the database"
  type        = map(string)
  default     = {}
}
