####################
#        AWS       #
####################
variable "aws_region" {}

####################
#        VPC       #
####################
variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
}

variable "my_ip" {}

####################
#        DB        #
####################

variable "db_cluster_identifier" {}

variable "db_username" {}

variable "db_password" {}

variable "db_instance_identifier" {}

variable "db_name" {}

variable "db_endpoint" {}



variable "lambda_source_code_hash" {}

variable "lambda_role_name" {
    default = "myRdsFunction-role"
}