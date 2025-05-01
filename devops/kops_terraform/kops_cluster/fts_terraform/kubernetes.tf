locals {
	cluster_name                 = "kops.lnchub.com"
	master_autoscaling_group_ids = [aws_autoscaling_group.master-ap-southeast-1a-masters-kops-lnchub-com.id]
	master_security_group_ids    = [aws_security_group.masters-kops-lnchub-com.id]
	masters_role_arn             = aws_iam_role.masters-kops-lnchub-com.arn
	masters_role_name            = aws_iam_role.masters-kops-lnchub-com.name
	node_autoscaling_group_ids   = [aws_autoscaling_group.nodes-kops-lnchub-com.id]
	node_security_group_ids      = [aws_security_group.nodes-kops-lnchub-com.id]
	node_subnet_ids              = [aws_subnet.ap-southeast-1a-kops-lnchub-com.id]
	nodes_role_arn               = aws_iam_role.nodes-kops-lnchub-com.arn
	nodes_role_name              = aws_iam_role.nodes-kops-lnchub-com.name
	region                       = "ap-southeast-1"
	route_table_public_id        = aws_route_table.kops-lnchub-com.id
	subnet_ap-southeast-1a_id    = aws_subnet.ap-southeast-1a-kops-lnchub-com.id
	vpc_cidr_block               = aws_vpc.kops-lnchub-com.cidr_block
	vpc_id                       = aws_vpc.kops-lnchub-com.id
}

output "cluster_name" {
	value = "kops.lnchub.com"
}

output "master_autoscaling_group_ids" {
	value = [aws_autoscaling_group.master-ap-southeast-1a-masters-kops-lnchub-com.id]
}

output "master_security_group_ids" {
	value = [aws_security_group.masters-kops-lnchub-com.id]
}

output "masters_role_arn" {
	value = aws_iam_role.masters-kops-lnchub-com.arn
}

output "masters_role_name" {
	value = aws_iam_role.masters-kops-lnchub-com.name
}

output "node_autoscaling_group_ids" {
	value = [aws_autoscaling_group.nodes-kops-lnchub-com.id]
}

output "node_security_group_ids" {
	value = [aws_security_group.nodes-kops-lnchub-com.id]
}

output "node_subnet_ids" {
	value = [aws_subnet.ap-southeast-1a-kops-lnchub-com.id]
}

output "nodes_role_arn" {
	value = aws_iam_role.nodes-kops-lnchub-com.arn
}

output "nodes_role_name" {
	value = aws_iam_role.nodes-kops-lnchub-com.name
}

output "region" {
	value = "ap-southeast-1"
}

output "route_table_public_id" {
	value = aws_route_table.kops-lnchub-com.id
}

output "subnet_ap-southeast-1a_id" {
	value = aws_subnet.ap-southeast-1a-kops-lnchub-com.id
}

output "vpc_cidr_block" {
	value = aws_vpc.kops-lnchub-com.cidr_block
}

output "vpc_id" {
	value = aws_vpc.kops-lnchub-com.id
}

provider "aws" {
	region = "ap-southeast-1"
}

resource "aws_autoscaling_group" "master-ap-southeast-1a-masters-kops-lnchub-com" {
	name                 = "master-ap-southeast-1a.masters.kops.lnchub.com"
	launch_configuration = aws_launch_configuration.master-ap-southeast-1a-masters-kops-lnchub-com.id
	max_size             = 1
	min_size             = 1
	vpc_zone_identifier  = [aws_subnet.ap-southeast-1a-kops-lnchub-com.id]
	
	tag {
		key                 = "KubernetesCluster"
		value               = "kops.lnchub.com"
		propagate_at_launch = true
	}
	
	tag {
		key                 = "Name"
		value               = "master-ap-southeast-1a.masters.kops.lnchub.com"
		propagate_at_launch = true
	}
	
	tag {
		key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
		value               = "master-ap-southeast-1a"
		propagate_at_launch = true
	}
	
	tag {
		key                 = "k8s.io/role/master"
		value               = "1"
		propagate_at_launch = true
	}
	
	tag {
		key                 = "kops.k8s.io/instancegroup"
		value               = "master-ap-southeast-1a"
		propagate_at_launch = true
	}
	
	metrics_granularity = "1Minute"
	enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_autoscaling_group" "nodes-kops-lnchub-com" {
	name                 = "nodes.kops.lnchub.com"
	launch_configuration = aws_launch_configuration.nodes-kops-lnchub-com.id
	max_size             = 2
	min_size             = 2
	vpc_zone_identifier  = [aws_subnet.ap-southeast-1a-kops-lnchub-com.id]
	
	tag {
		key                 = "KubernetesCluster"
		value               = "kops.lnchub.com"
		propagate_at_launch = true
	}
	
	tag {
		key                 = "Name"
		value               = "nodes.kops.lnchub.com"
		propagate_at_launch = true
	}
	
	tag {
		key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
		value               = "nodes"
		propagate_at_launch = true
	}
	
	tag {
		key                 = "k8s.io/role/node"
		value               = "1"
		propagate_at_launch = true
	}
	
	tag {
		key                 = "kops.k8s.io/instancegroup"
		value               = "nodes"
		propagate_at_launch = true
	}
	
	metrics_granularity = "1Minute"
	enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_ebs_volume" "a-etcd-events-kops-lnchub-com" {
	availability_zone = "ap-southeast-1a"
	size              = 20
	type              = "gp2"
	encrypted         = false
	
	tags = {
		KubernetesCluster                       = "kops.lnchub.com"
		Name                                    = "a.etcd-events.kops.lnchub.com"
		"k8s.io/etcd/events"                    = "a/a"
		"k8s.io/role/master"                    = "1"
		"kubernetes.io/cluster/kops.lnchub.com" = "owned"
	}
}

resource "aws_ebs_volume" "a-etcd-main-kops-lnchub-com" {
	availability_zone = "ap-southeast-1a"
	size              = 20
	type              = "gp2"
	encrypted         = false
	
	tags = {
		KubernetesCluster                       = "kops.lnchub.com"
		Name                                    = "a.etcd-main.kops.lnchub.com"
		"k8s.io/etcd/main"                      = "a/a"
		"k8s.io/role/master"                    = "1"
		"kubernetes.io/cluster/kops.lnchub.com" = "owned"
	}
}

resource "aws_iam_instance_profile" "masters-kops-lnchub-com" {
	name = "masters.kops.lnchub.com"
	role = aws_iam_role.masters-kops-lnchub-com.name
}

resource "aws_iam_instance_profile" "nodes-kops-lnchub-com" {
	name = "nodes.kops.lnchub.com"
	role = aws_iam_role.nodes-kops-lnchub-com.name
}

resource "aws_iam_role" "masters-kops-lnchub-com" {
	name = "masters.kops.lnchub.com"
	assume_role_policy = file(
	"${path.module}/data/aws_iam_role_masters.kops.lnchub.com_policy",
	)
}

resource "aws_iam_role" "nodes-kops-lnchub-com" {
	name = "nodes.kops.lnchub.com"
	assume_role_policy = file(
	"${path.module}/data/aws_iam_role_nodes.kops.lnchub.com_policy",
	)
}

resource "aws_iam_role_policy" "masters-kops-lnchub-com" {
	name = "masters.kops.lnchub.com"
	role = aws_iam_role.masters-kops-lnchub-com.name
	policy = file(
	"${path.module}/data/aws_iam_role_policy_masters.kops.lnchub.com_policy",
	)
}

resource "aws_iam_role_policy" "nodes-kops-lnchub-com" {
	name = "nodes.kops.lnchub.com"
	role = aws_iam_role.nodes-kops-lnchub-com.name
	policy = file(
	"${path.module}/data/aws_iam_role_policy_nodes.kops.lnchub.com_policy",
	)
}

resource "aws_internet_gateway" "kops-lnchub-com" {
	vpc_id = aws_vpc.kops-lnchub-com.id
	
	tags = {
		KubernetesCluster                       = "kops.lnchub.com"
		Name                                    = "kops.lnchub.com"
		"kubernetes.io/cluster/kops.lnchub.com" = "owned"
	}
}

resource "aws_key_pair" "kubernetes-kops-lnchub-com-55d42b8d68bfa8c37b635fa6a057cc92" {
	key_name = "kubernetes.kops.lnchub.com-55:d4:2b:8d:68:bf:a8:c3:7b:63:5f:a6:a0:57:cc:92"
	public_key = file(
	"${path.module}/data/aws_key_pair_kubernetes.kops.lnchub.com-55d42b8d68bfa8c37b635fa6a057cc92_public_key",
	)
}

resource "aws_launch_configuration" "master-ap-southeast-1a-masters-kops-lnchub-com" {
	name_prefix                 = "master-ap-southeast-1a.masters.kops.lnchub.com-"
	image_id                    = "ami-0b07063e12545b6b1"
	instance_type               = "t2.micro"
	key_name                    = aws_key_pair.kubernetes-kops-lnchub-com-55d42b8d68bfa8c37b635fa6a057cc92.id
	iam_instance_profile        = aws_iam_instance_profile.masters-kops-lnchub-com.id
	security_groups             = [aws_security_group.masters-kops-lnchub-com.id]
	associate_public_ip_address = true
	user_data = file(
	"${path.module}/data/aws_launch_configuration_master-ap-southeast-1a.masters.kops.lnchub.com_user_data",
	)
	
	root_block_device {
		volume_type           = "gp2"
		volume_size           = 64
		delete_on_termination = true
	}
	
	lifecycle {
		create_before_destroy = true
	}
	
	enable_monitoring = false
}

resource "aws_launch_configuration" "nodes-kops-lnchub-com" {
	name_prefix                 = "nodes.kops.lnchub.com-"
	image_id                    = "ami-0b07063e12545b6b1"
	instance_type               = "t2.micro"
	key_name                    = aws_key_pair.kubernetes-kops-lnchub-com-55d42b8d68bfa8c37b635fa6a057cc92.id
	iam_instance_profile        = aws_iam_instance_profile.nodes-kops-lnchub-com.id
	security_groups             = [aws_security_group.nodes-kops-lnchub-com.id]
	associate_public_ip_address = true
	user_data = file(
	"${path.module}/data/aws_launch_configuration_nodes.kops.lnchub.com_user_data",
	)
	
	root_block_device {
		volume_type           = "gp2"
		volume_size           = 128
		delete_on_termination = true
	}
	
	lifecycle {
		create_before_destroy = true
	}
	
	enable_monitoring = false
}

# TF-UPGRADE-TODO: In Terraform v0.11 and earlier, it was possible to begin a
# resource name with a number, but it is no longer possible in Terraform v0.12.
#
# Rename the resource and run `terraform state mv` to apply the rename in the
# state. Detailed information on the `state move` command can be found in the
# documentation online: https://www.terraform.io/docs/commands/state/mv.html
resource "aws_route" "route-0-0-0-0--0" {
	route_table_id         = aws_route_table.kops-lnchub-com.id
	destination_cidr_block = "0.0.0.0/0"
	gateway_id             = aws_internet_gateway.kops-lnchub-com.id
}

resource "aws_route53_zone_association" "kops-lnchub-com" {
	zone_id = "/hostedzone/Z0856166S0PIG3FYYW4R"
	vpc_id  = aws_vpc.kops-lnchub-com.id
}

resource "aws_route_table" "kops-lnchub-com" {
	vpc_id = aws_vpc.kops-lnchub-com.id
	
	tags = {
		KubernetesCluster                       = "kops.lnchub.com"
		Name                                    = "kops.lnchub.com"
		"kubernetes.io/cluster/kops.lnchub.com" = "owned"
		"kubernetes.io/kops/role"               = "public"
	}
}

resource "aws_route_table_association" "ap-southeast-1a-kops-lnchub-com" {
	subnet_id      = aws_subnet.ap-southeast-1a-kops-lnchub-com.id
	route_table_id = aws_route_table.kops-lnchub-com.id
}

resource "aws_security_group" "masters-kops-lnchub-com" {
	name        = "masters.kops.lnchub.com"
	vpc_id      = aws_vpc.kops-lnchub-com.id
	description = "Security group for masters"
	
	tags = {
		KubernetesCluster                       = "kops.lnchub.com"
		Name                                    = "masters.kops.lnchub.com"
		"kubernetes.io/cluster/kops.lnchub.com" = "owned"
	}
}

resource "aws_security_group" "nodes-kops-lnchub-com" {
	name        = "nodes.kops.lnchub.com"
	vpc_id      = aws_vpc.kops-lnchub-com.id
	description = "Security group for nodes"
	
	tags = {
		KubernetesCluster                       = "kops.lnchub.com"
		Name                                    = "nodes.kops.lnchub.com"
		"kubernetes.io/cluster/kops.lnchub.com" = "owned"
	}
}

resource "aws_security_group_rule" "all-master-to-master" {
	type                     = "ingress"
	security_group_id        = aws_security_group.masters-kops-lnchub-com.id
	source_security_group_id = aws_security_group.masters-kops-lnchub-com.id
	from_port                = 0
	to_port                  = 0
	protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
	type                     = "ingress"
	security_group_id        = aws_security_group.nodes-kops-lnchub-com.id
	source_security_group_id = aws_security_group.masters-kops-lnchub-com.id
	from_port                = 0
	to_port                  = 0
	protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
	type                     = "ingress"
	security_group_id        = aws_security_group.nodes-kops-lnchub-com.id
	source_security_group_id = aws_security_group.nodes-kops-lnchub-com.id
	from_port                = 0
	to_port                  = 0
	protocol                 = "-1"
}

resource "aws_security_group_rule" "https-external-to-master-0-0-0-0--0" {
	type              = "ingress"
	security_group_id = aws_security_group.masters-kops-lnchub-com.id
	from_port         = 443
	to_port           = 443
	protocol          = "tcp"
	cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "master-egress" {
	type              = "egress"
	security_group_id = aws_security_group.masters-kops-lnchub-com.id
	from_port         = 0
	to_port           = 0
	protocol          = "-1"
	cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
	type              = "egress"
	security_group_id = aws_security_group.nodes-kops-lnchub-com.id
	from_port         = 0
	to_port           = 0
	protocol          = "-1"
	cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
	type                     = "ingress"
	security_group_id        = aws_security_group.masters-kops-lnchub-com.id
	source_security_group_id = aws_security_group.nodes-kops-lnchub-com.id
	from_port                = 1
	to_port                  = 2379
	protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4000" {
	type                     = "ingress"
	security_group_id        = aws_security_group.masters-kops-lnchub-com.id
	source_security_group_id = aws_security_group.nodes-kops-lnchub-com.id
	from_port                = 2382
	to_port                  = 4000
	protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
	type                     = "ingress"
	security_group_id        = aws_security_group.masters-kops-lnchub-com.id
	source_security_group_id = aws_security_group.nodes-kops-lnchub-com.id
	from_port                = 4003
	to_port                  = 65535
	protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
	type                     = "ingress"
	security_group_id        = aws_security_group.masters-kops-lnchub-com.id
	source_security_group_id = aws_security_group.nodes-kops-lnchub-com.id
	from_port                = 1
	to_port                  = 65535
	protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
	type              = "ingress"
	security_group_id = aws_security_group.masters-kops-lnchub-com.id
	from_port         = 22
	to_port           = 22
	protocol          = "tcp"
	cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
	type              = "ingress"
	security_group_id = aws_security_group.nodes-kops-lnchub-com.id
	from_port         = 22
	to_port           = 22
	protocol          = "tcp"
	cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "ap-southeast-1a-kops-lnchub-com" {
	vpc_id            = aws_vpc.kops-lnchub-com.id
	cidr_block        = "172.20.32.0/19"
	availability_zone = "ap-southeast-1a"
	
	tags = {
		KubernetesCluster                       = "kops.lnchub.com"
		Name                                    = "ap-southeast-1a.kops.lnchub.com"
		SubnetType                              = "Public"
		"kubernetes.io/cluster/kops.lnchub.com" = "owned"
		"kubernetes.io/role/elb"                = "1"
	}
}

resource "aws_vpc" "kops-lnchub-com" {
	cidr_block           = "172.20.0.0/16"
	enable_dns_hostnames = true
	enable_dns_support   = true
	
	tags = {
		KubernetesCluster                       = "kops.lnchub.com"
		Name                                    = "kops.lnchub.com"
		"kubernetes.io/cluster/kops.lnchub.com" = "owned"
	}
}

resource "aws_vpc_dhcp_options" "kops-lnchub-com" {
	domain_name         = "ap-southeast-1.compute.internal"
	domain_name_servers = ["AmazonProvidedDNS"]
	
	tags = {
		KubernetesCluster                       = "kops.lnchub.com"
		Name                                    = "kops.lnchub.com"
		"kubernetes.io/cluster/kops.lnchub.com" = "owned"
	}
}

resource "aws_vpc_dhcp_options_association" "kops-lnchub-com" {
	vpc_id          = aws_vpc.kops-lnchub-com.id
	dhcp_options_id = aws_vpc_dhcp_options.kops-lnchub-com.id
}

terraform {
	required_version = ">= 0.9.3"
}

