terraform {
  backend "s3" {
    bucket = "s3-terraform-storage1"
    key    = "jenkins/terraform.tfstate"
    region = "us-east-1"
  }
}
