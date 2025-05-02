include "root" {
  path   = find_in_parent_folders()
  expose = true
}

#deleting sg

terraform {
  source = "git::git@gitlab.com:holcim-org/americas-core/tools/tf-modules.git//?ref=aws/secgroup_2.0.1"
}




inputs = {

  name                  = "io-providersp2p-sg-sm-nb"
  sec_group_description = "Security group for sagemaker notebook porviders PoC"
  vpc_id                = "vpc-084190be4f1934629"

  ingress_rules = [
    {
      description  = "Allow traffic generated from SG"
      from_port    = 443
      to_port      = 443
      protocol     = "TCP"
      cidr_blocks  = ["10.0.0.0/8"]
      prefix_lists = []
      sec_groups   = []
    }

  ]



}
