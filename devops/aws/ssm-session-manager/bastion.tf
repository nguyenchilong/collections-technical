locals {
	region = "YOUR_AWS_REGION"
	private_subnet_id = "YOUR_PRIVATE_SUBNET_ID"
}

resource "aws_instance" "bastion1" {
	ami                         = "ami-05b10e08d247fb927" // Amazon Linux 2 AMI
	instance_type               = "t3.nano"
	associate_public_ip_address = false
	subnet_id                   = local.private_subnet_id
	iam_instance_profile        = aws_iam_instance_profile.private_bastion.name
	
	tags = {
		Name = "private-bastion"
	}
}

resource "aws_iam_role" "private_bastion" {
	name = "PrivateBastionRole"
	
	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Action = "sts:AssumeRole"
				Effect = "Allow"
				Principal = {
					Service = "ec2.amazonaws.com"
				}
			}
		]
	})
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
	role       = aws_iam_role.private_bastion.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "private_bastion" {
	name = "PrivateBastionInstanceProfile"
	role = aws_iam_role.private_bastion.name
}
