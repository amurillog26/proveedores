include "parent" {
  path = find_in_parent_folders()
}
terraform {
  source = "git::https://gitlab.com/holcim-org/americas-core/tools/tf-modules.git///?ref=aws/cloud9_0.2.5"
}


inputs = {
  name         = "mherna16"
  project      = "poc-ia-providersp2p-la""
  description  = "A Cloud9 environment for user mherna16 working on Latam PoC Rackspace team"
  profile_name = "io-la-prd-cloud9-iascode"
  subnet_id    = "subnet-0071b43fae302e86d"
  aws_username = "AWSReservedSSO_ADC-ABS-C9_e6abe037073c018e/martin.hernandez.ext@holcim.com"
}
