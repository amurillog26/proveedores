# Elimina la referencia al módulo "this"
# y usa un enfoque más simple

locals {
  database_name = var.custom_db_name ? var.db_name : "${var.db_name}-db"
  tags = merge(
    {
      Name        = local.database_name,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_glue_catalog_database" "this" {
  name         = local.database_name
  description  = var.description
  location_uri = var.location_uri
  tags         = local.tags
}

# Para las etiquetas LF, simplifica para usar directamente las variables proporcionadas
resource "aws_lakeformation_resource_lf_tags" "this" {
  database {
    name = aws_glue_catalog_database.this.name
  }

  dynamic "lf_tag" {
    for_each = var.lf_tags
    content {
      key   = lf_tag.key
      value = lf_tag.value
    }
  }
}
