variable "instance_num" {
    description = "number of instances to be created"
    default  = 3
}

variable "image_name" {
  description =  "name of the image"
  #default = "cirros-0.5.1-x86_64-disk"
  default = "CentOS-8.3-GenericCloud"
}

variable "flavor_name" {
  description = "type of flavor of the instances"
  #default = "m1.nano"
  #default = "ds1G"
  default = "m1.small"
}
