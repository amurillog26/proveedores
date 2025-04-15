include "parent" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  global   = include.parent.locals.global
  app_name = local.global.app_name
  project  = local.global.project
}

terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git///?ref=aws/s3_4.1.2"
}


inputs = {
  name          = "${local.app_name}-input"
  s3_versioning = "Disabled"
  s3_encryption = "aws:kms"
}


