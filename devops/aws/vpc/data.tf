data "template_file" "user_data" {
	template = templatefile("userdata.tpl", {
		rds_address = element(split(":", aws_db_instance.default.endpoint), 0)
	})
}
