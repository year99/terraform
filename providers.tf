# Description: This file is used to define the provider configuration for the terraform code.
# The provider configuration is used to define the cloud provider and the version of the provider.
terraform {    
  required_providers { //   required_providers { // Required providers   
    aws = {
      source  = "hashicorp/aws" // Source of the provider
      version = "5.8.0" // Version of the provider
    }
  }

  cloud { //    cloud = "aws" // Cloud provider
    organization = "tf" // Name of the organization

    workspaces {
      name = "terraform-sandeep-aws" // Name of the workspace
    } // End of workspaces
  }
}