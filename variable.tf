variable "region" {
  type = string
  description = "The region to deploy resource to"
  default = "us-east-1"
}

variable "vpc_cidr" {
    type = string
    description = "CIDR block for VPC"
    default = "10.255.0.0/20"

}

variable "default_tag" {
  type = map
  description = "Map of default tags to apply to resource"
  default = {
      project = "ecs_sm_demo"
  }
}

variable "public_subnet_count" {
   type = number
   default = 2
}

variable "private_subnet_count" {
   type = number
   default = 2
}