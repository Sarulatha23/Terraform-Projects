variable "aws_cidr" {
  description = "VPC_CIDR"
  type        = string
}
variable "public_subnet" {
  description = "public_subnet"
  type        = list(string)
}
variable "intance_type" {
  description = "intance_type"
  type        = string
}