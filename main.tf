# module "seoul" {
#   source = "./seoul" 
# }
# module "singa" {
#   source = "./singapore"
# }
# module "inter-region-peering" { # Required seoul and singa module
#   source = "./inter-region-peering"
# }
# module "idc-seoul" {
#   source = "./idc_seoul"
# }
module "idc-singa" {
  source = "./idc_singapore"
}
# module "idc-singa-vpn" { # Required idc-singa module
#   source = "./idc_singapore_vpn"
# }