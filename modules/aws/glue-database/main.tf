#######################
## AWS Glue Database ##
#######################
module "glue_db_label" {
  source = "git::git@gitlab.com:holcim-adc/americas-core/tools/tf-modules.git//?ref=null/tagging_0.3.0"
  name   = var.db_name

  context = module.this.context
}

locals {
  database_name = var.custom_db_name ? var.db_name : "${module.glue_db_label.id}-db"
}

resource "aws_glue_catalog_database" "this" {
  name         = local.database_name
  description  = var.db_description
  location_uri = var.location_uri
  tags         = merge(module.glue_db_label.tags, { Name = local.database_name })
}

#############################
## AWS Lake Formation Tags ##
#############################
resource "aws_lakeformation_resource_lf_tags" "this" {
  database {
    name = aws_glue_catalog_database.this.name
  }

  dynamic "lf_tag" {
    for_each = merge({ project : module.this.tags.project }, var.lf_tags)
    content {
      key   = lf_tag.key
      value = lf_tag.value
    }
  }
}
