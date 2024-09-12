#
# Variables we need for this Terraform run. Set them in variables.tf
variable "api_public_key" { default="" }
variable "api_private_key" { default="" }
variable "org_id" { default="" }

variable "project_name" { default="Terraform" }
variable "cluster_name" { default="TerraformManagedCluster" }
variable "database_username" { default = "terraform" }
variable "database_user_password" { default = "terraform" }
variable "access_list_ip" { default = "0.0.0.0" }
variable "access_list_ip_desc" { default = "Added by Terraform" }

#
# Configure the MongoDB Atlas Provider
#
terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "0.9.1"
    }
  }
}
provider "mongodbatlas" {
  public_key = var.api_public_key
  private_key  = var.api_private_key
}

#
# Create a Project 
#
resource "mongodbatlas_project" "my_project" {
  name 			= var.project_name
  org_id		= var.org_id
}

#
# Create a Cluster
#
resource "mongodbatlas_cluster" "my_cluster" {
  project_id   = mongodbatlas_project.my_project.id
  name         = var.cluster_name
  num_shards   = 1

  replication_factor           = 3
  provider_backup_enabled      = true
  auto_scaling_disk_gb_enabled = true
  mongo_db_major_version       = "4.0"

  //Provider Settings "block"
  provider_name               = "GCP"
  disk_size_gb                = 40
  provider_instance_size_name = "M30"
  provider_region_name        = "US_EAST_4"
}

#
# Create a Database User
#
resource "mongodbatlas_database_user" "my_database_user" {
  username 	          	= var.database_username
  password 	           	= var.database_user_password
  project_id            = mongodbatlas_project.my_project.id
  auth_database_name	 	= "admin"

  roles {
    role_name     	= "readWriteAnyDatabase"
    database_name 	= "admin"
  }
}

#
# Create an IP Access List
#
resource "mongodbatlas_project_ip_access_list" "test" {
  project_id    = mongodbatlas_project.my_project.id  
  ip_address 		= var.access_list_ip
  comment    		= var.access_list_ip_desc
}
