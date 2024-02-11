variable "my_vpc" {
  description = "VPC-cidr"
  type        = string

}

variable "pub-subnet" {
  description = "pub-sub"
  type        = list(string)
}

variable "instance_type" {
  description = "instance"
  type        = string
}