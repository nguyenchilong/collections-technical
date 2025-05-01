resource "aws_vpc_endpoint" "ssm" {
	vpc_endpoint_type   = "Interface"
	vpc_id              = "vpc-0e1cf1f20e9ffe07c"
	service_name        = "com.amazonaws.${local.region}.ssm"
	private_dns_enabled = true
	subnet_ids = [
		local.private_subnet_id
	]
}

resource "aws_vpc_endpoint" "ec2messages" {
	vpc_endpoint_type   = "Interface"
	vpc_id              = "vpc-0e1cf1f20e9ffe07c"
	service_name        = "com.amazonaws.${local.region}.ec2messages"
	private_dns_enabled = true
	subnet_ids = [
		local.private_subnet_id
	]
}

resource "aws_vpc_endpoint" "ssmmessages" {
	vpc_endpoint_type   = "Interface"
	vpc_id              = "vpc-0e1cf1f20e9ffe07c"
	service_name        = "com.amazonaws.${local.region}.ssmmessages"
	private_dns_enabled = true
	subnet_ids = [
		local.private_subnet_id
	]
}
