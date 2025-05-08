#
# ONLY EDIT THIS FILE IN https://gitlab.com/holcim-adc/americas-core/tools/tf-modules/-/blob/null/tagging
# All other instances of this file should be a copy of that one
#
#
# Copy this file from https://gitlab.com/holcim-adc/americas-core/tools/tf-modules/-/blob/null/tagging/exports/context.tf
# and then place it in your Terraform module to automatically get
# Holcim's standard configuration inputs suitable for passing
# to Holcim's modules.
#
# curl -sL https://gitlab.com/holcim-adc/americas-core/tools/tf-modules/-/raw/null/tagging/exports/context.tf -o context.tf
#
# Modules should access the whole context as `module.this.context`
# to get the input variables with nulls for defaults,
# for example `context = module.this.context`,
# and access individual variables as `module.this.<var>`,
# with final values filled in.
#
# For example, when using defaults, `module.this.context.delimiter`
# will be null, and `module.this.delimiter` will be `-` (hyphen).
#

module "this" {
  source = "git::git@gitlab.com:holcim-adc/americas-core/tools/tf-modules.git//?ref=null/tagging_0.3.0" # requires Terraform >= 0.13.0

  enabled             = var.enabled
  label_order         = var.label_order
  regex_replace_chars = var.regex_replace_chars
  id_length_limit     = var.id_length_limit
  label_key_case      = var.label_key_case
  label_value_case    = var.label_value_case
  descriptor_formats  = var.descriptor_formats
  labels_as_tags      = var.labels_as_tags

  project     = var.project
  app_name    = var.app_name
  entity      = var.entity
  cost_center = var.cost_center
  app_type    = var.app_type
  name        = var.name

  environment = var.environment
  namespace   = var.namespace
  tenant      = var.tenant
  sla_tier    = var.sla_tier
  attributes  = var.attributes
  tags        = var.tags

  context = var.context
}

# Copy contents of https://gitlab.com/holcim-adc/americas-core/tools/tf-modules/-/blob/null/tagging/variables.tf here
variable "context" {
  type = any
  default = {
    # Module control variables
    enabled             = true
    label_order         = []
    regex_replace_chars = null
    id_length_limit     = null
    label_key_case      = null
    label_value_case    = null
    descriptor_formats  = {}
    labels_as_tags      = ["unset"]

    # Mandatory tags
    ## URL: https://docs.google.com/presentation/d/1Wg81EB2gkNLkurMN-0C8VLc45G9zukpnxOaN7eQA0-0/edit?usp=sharing
    project     = null
    app_name    = null
    entity      = null
    cost_center = null
    app_type    = null
    name        = null

    # Optional tags
    environment = null
    namespace   = null
    tenant      = null
    sla_tier    = null
    attributes  = []
    tags        = {}
  }
  description = <<-EOT
    Single object for setting entire context at once.
    See description of individual variables for details.
    Leave string and numeric variables as `null` to use default value.
    Individual variable settings (non-null) override settings in context object,
    except for attributes, tags, and additional_tag_map, which are merged.
  EOT

  validation {
    condition     = lookup(var.context, "label_key_case", null) == null ? true : contains(["lower", "title", "upper"], var.context["label_key_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }

  validation {
    condition     = lookup(var.context, "label_value_case", null) == null ? true : contains(["lower", "title", "upper", "none"], var.context["label_value_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}
variable "enabled" {
  type        = bool
  default     = null
  description = "Set to false to prevent the module from creating any resources."
}

variable "namespace" {
  type        = string
  default     = null
  description = "ID element. Usually an abbreviation of your organization name, e.g. 'io' or 'data', to help ensure generated IDs are globally unique"
}

variable "tenant" {
  type        = string
  default     = null
  description = "ID element . A customer identifier, indicating who this instance of a resource is for (e.g. am, la, na, de, etc.)"
}

variable "project" {
  type        = string
  default     = null
  description = <<-EOT
    Project tag value use to identify where the resource belongs to.
    - e.g. "ng-infra-smtp", "ng-infra-tool", "ng-infra-na"
  EOT
}

variable "app_name" {
  type        = string
  default     = null
  description = <<-EOT
    application-name tag value use to identify the application or solution related to (multiple values are allowded using semicolon).
    - e.g. "sap", "altiris", "command;tcc"
  EOT
}

variable "entity" {
  type        = string
  default     = null
  description = <<-EOT
    Entity tag value use to identify the Entity owner:
    - Valid values are: "adc", "glb", "ev", "cp", "dl", "hbe", "ml", "ps".
  EOT
}

variable "cost_center" {
  type        = string
  default     = null
  description = <<-EOT
    cost-center tag value use to indicate the associated resource cost-center (multiple values are allowd using semicolon):
    - e.g. "966cmxxoc0", "101906519", "101906519;966cmxxoc0"
  EOT
}

variable "app_type" {
  type        = string
  default     = null
  description = <<-EOT
    The application-type tag value use to indicate the application type resources:
    - Valid values are:  "apps", "autoscaling", "db", "infra", "web", "fs", "sec", "virtual-appliance", "xen-desktop".
  EOT
}

variable "environment" {
  type        = string
  default     = null
  description = <<-EOT
    Environment tag value use to describe the resource environment.
    e.g. "prd", "drp", "qa", "dev", "sbx".
  EOT
}

variable "sla_tier" {
  type        = string
  default     = null
  description = <<-EOT
    sla-tier tag value use to describe the SLA associated to the deployed resourceso or solution:
    e.g. "platinum", "gold", "silver", "bronze", "no-metal".
  EOT
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = <<-EOT
    ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,
    in the order they appear in the list. New attributes are appended to the
    end of the list. The elements of the list are joined by the `delimiter`
    and treated as a single ID element.
    EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<-EOT
    Additional tags (e.g. `{'iac': 'terraform'}`).
    Neither the tag keys nor the tag values will be modified by this module.
    EOT
}

variable "labels_as_tags" {
  type        = set(string)
  default     = ["default"]
  description = <<-EOT
    Set of labels (ID elements) to include as tags in the `tags` output.
    Default is to include all labels.
    Tags with empty values will not be included in the `tags` output.
    Set to `[]` to suppress all generated tags.
    **Notes:**
      The value of the `name` tag, if included, will be the `id`, not the `name`.
      Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be
      changed in later chained modules. Attempts to change it will be silently ignored.
    EOT
}

variable "label_order" {
  type        = list(string)
  default     = []
  description = <<-EOT
    The order in which the labels (ID elements) appear in the `id`.
    Defaults to ["namespace", "entity", "tenant", "environment", "name", "attributes"].
    EOT
}

variable "regex_replace_chars" {
  type        = string
  default     = null
  description = <<-EOT
    Terraform regular expression (regex) string.
    Characters matching the regex will be removed from the ID elements.
    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.
  EOT
}

variable "id_length_limit" {
  type        = number
  default     = null
  description = <<-EOT
    Limit `id` to this many characters (minimum 6).
    Set to `0` for unlimited length.
    Set to `null` for keep the existing setting, which defaults to `0`.
    Does not affect `id_full`.
  EOT

  validation {
    condition     = var.id_length_limit == null ? true : var.id_length_limit >= 6 || var.id_length_limit == 0
    error_message = "The id_length_limit must be >= 6 if supplied (not null), or 0 for unlimited length."
  }
}

variable "label_key_case" {
  type        = string
  default     = null
  description = <<-EOT
    Controls the letter case of the `tags` keys (label names) for tags generated by this module.
    Does not affect keys of tags passed in via the `tags` input.
    Possible values: `lower`, `title`, `upper`.
    Default value: `title`.
  EOT

  validation {
    condition     = var.label_key_case == null ? true : contains(["lower", "title", "upper"], var.label_key_case)
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }
}

variable "label_value_case" {
  type        = string
  default     = null
  description = <<-EOT
    Controls the letter case of ID elements (labels) as included in `id`,
    set as tag values, and output by this module individually.
    Does not affect values of tags passed in via the `tags` input.
    Possible values: `lower`, `title`, `upper` and `none` (no transformation).
    Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.
    Default value: `lower`.
  EOT

  validation {
    condition     = var.label_value_case == null ? true : contains(["lower", "title", "upper", "none"], var.label_value_case)
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}

variable "descriptor_formats" {
  type        = any
  default     = {}
  description = <<-EOT
    Describe additional descriptors to be output in the `descriptors` output map.
    Map of maps. Keys are names of descriptors. Values are maps of the form
    `{
        format = string
        labels = list(string)
    }`
    (Type is `any` so the map values can later be enhanced to provide additional options.)
    `format` is a Terraform format string to be passed to the `format()` function.
    `labels` is a list of labels, in order, to pass to `format()` function.
    Label values will be normalized before being passed to `format()` so they will be
    identical to how they appear in `id`.
    Default is `{}` (`descriptors` output will be empty).
    EOT
}
