environment                         = "DevTest"
department                          = "InnovationHub"
location                            = "uksouth"
resource_group_name                 = "myrg"
ado_vg_name                         = "RD-CI"
ado_project_name                    = "CAIS"
ci_service_principle                = "tj0798-CAIS-7eac40a0-6807-4898-9a66-fbe5bba26ace"
keyvault_readonly_access_object_ids = ["6ca1b442-104d-456e-b45c-7738df5249e4"]
keyvault_admin_access_object_ids    = ["c58164e3-1225-43e1-a37b-918f70bcfcb0"]
keyvault_devs_access_object_ids     = ["71d0bb9e-675e-4452-9b29-27ede335bdfb"]
secret_maps = {
  "name1" = "value11"
  "name2" = "value22"
  "name3" = "value33"
}
# https://www.mytechramblings.com/posts/how-to-bootstrap-terraform-and-azdo-to-start-deploying-iac-to-azure/