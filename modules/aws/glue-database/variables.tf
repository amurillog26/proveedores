variable "custom_db_name" {
  type        = bool
  description = "Whether to use or not a custom name for the Glue DB. Meant for backwards compatibility."
  default     = false
}

variable "db_name" {
  type        = string
  description = "Name to be used for the Glue DB. Will be a suffix if `custom_db_name` is true."
}

variable "db_description" {
  type        = string
  description = "Glue DB description."
  default     = null
}

variable "location_uri" {
  type        = string
  description = "Location of the data store associated with the Glue DB."
  default     = null
}

variable "lf_tags" {
  type        = map(string)
  description = "Extra LF taggs to associate with the Glue DB."
  default     = {}
}
