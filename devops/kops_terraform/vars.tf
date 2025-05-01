
variable "AWS_ACCESS_KEY" {
	default = "string"
}

variable "AWS_SECRET_KEY" {
	default = "string"
}

variable "AWS_REGION" {
	default = "ap-southeast-1"
}

variable "AMIS" {
	type = map(string)
	default = {
		ap-southeast-1 = "ami-061eb2b23f9f8839c"
	}
}
