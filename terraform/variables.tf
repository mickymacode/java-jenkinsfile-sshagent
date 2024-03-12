variable "region" {
  default = "ap-southeast-2"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "env_prefix" {
  default = "dev"
}

variable "subnet_cidr_block" {
  default = "10.0.10.0/24"
}

variable "availability_zone" {
  default = "ap-southeast-2a"
}

variable "instance_type" {
  default = "t2.micro"
}
