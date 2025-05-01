
resource "aws_instance" "demo_kop" {
	ami           = lookup(var.AMIS, var.AWS_REGION)
	tags          = { Name = "kops_fts" }
	instance_type = "t2.micro"
	
	provisioner "local-exec" {
		command = "echo ${aws_instance.demo_kop.private_ip} >> private_ips.txt;echo ${aws_instance.demo_kop.public_ip} >> public_ips.txt"
	}
}

