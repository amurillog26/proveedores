output "db_name" {
  description = "Name of the Glue Catalog DB."
  value       = aws_glue_catalog_database.this.name
}
