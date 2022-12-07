# The block below configures Terraform to use the 'remote' backend with Terraform Cloud.
# For more information, see https://www.terraform.io/docs/backends/types/remote.html
terraform {
  backend "azurerm" {
    resource_group_name = "cpt_terraform_rg_blobstorage"
    storage_account_name = "cpttfstorageaccount"
    container_name = "tf-mycsp-prod-state"
    key = "tf-mycsp-prod-key.tfstate"
  }

  required_version = ">= 0.13.0"
}
