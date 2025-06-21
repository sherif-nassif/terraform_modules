
variable "port" {
  type        = string
  description = "the needed port by loadbalancer"
}

variable "image" {
  type        = string
  description = "the image of the EC2 instance"
}

variable "flavor" {
  type        = string
  description = "the ram-disk-cpu used"
}

variable "vpc_name" {
  type        = string
  description = "the name of the created vpc"
}

variable "vpc_cidr_block" {
  type        = string
  description = "the value of the  vpc cidr block"
}

variable "az_1" {
  type        = string
  description = "the first availability zone for the lb"
}

variable "az_2" {
  type        = string
  description = "the second availability zone for the lb"
}

variable "subnet1_cidr" {
  type        = string
  description = "subnet 1 cidr"

}

variable "subnet2_cidr" {
  type        = string
  description = "subnet 2 cidr"
}
variable "subnet1_name" {
  type        = string
  description = "subnet 1 name"
}

variable "subnet2_name" {
  type        = string
  description = "subnet 2 name"
}

variable "route" {
  type        = string
  description = "the routing entry of the routing table"
}