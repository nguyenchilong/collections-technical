variable "region" {
  type = string
  default = "ap-southeast-1"
}

variable "ami" {
  type = string
  default = "ami-0a4408457f9a03be3"
}

variable "public_key_path" {
  type = string
  default = "path-to/sydney-region-key-pair.pub"
}