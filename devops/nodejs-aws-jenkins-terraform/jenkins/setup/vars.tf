variable "AWS_REGION" {
  default = "eu-west-1"
}
variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
}
variable "PATH_TO_PUBLIC_KEY" {
  default = "mykey.pub"
}
variable "AMIS" {
  type = "map"
  default = {
    us-east-1 = "ami-0f9cf087c1f27d9b1"
    us-west-2 = "ami-0653e888ec96eab9b"
    eu-west-1 = "ami-09f0b8b3e41191524"
  }
}
variable "INSTANCE_DEVICE_NAME" {
  default = "/dev/xvdh"
}
variable "JENKINS_VERSION" {
  default = "2.121.2"
}
variable "TERRAFORM_VERSION" {
  default = "0.11.10"
}

variable "APP_INSTANCE_COUNT" {
  default = "0"
}
