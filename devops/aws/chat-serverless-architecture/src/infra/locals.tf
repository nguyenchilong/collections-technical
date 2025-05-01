locals {
  go_pkg_file              = "${path.module}/../go-pkg/"
  main_file                = "main.go"
  chat_connect_src_path    = "${local.go_pkg_file}/sls/chat-connect/${local.main_file}"
  chat_disconnect_src_path = "${local.go_pkg_file}/sls/chat-disconnect/${local.main_file}"
  chat_message_src_path    = "${local.go_pkg_file}/sls/chat-message/${local.main_file}"
  auth_register_src_path   = "${local.go_pkg_file}/sls/auth-register/${local.main_file}"
  auth_login_src_path      = "${local.go_pkg_file}/sls/auth-login/${local.main_file}"

  generate_path   = "tf_generated"
  binary_file     = "bootstrap"
  chat_connect    = "chat_connect"
  chat_disconnect = "chat_disconnect"
  chat_message    = "chat_message"
  auth_register   = "auth_register"
  auth_login      = "auth_login"

  chat_connect_archive_path    = "${path.module}/${local.generate_path}/${local.chat_connect}.zip"
  chat_disconnect_archive_path = "${path.module}/${local.generate_path}/${local.chat_disconnect}.zip"
  chat_message_archive_path    = "${path.module}/${local.generate_path}/${local.chat_message}.zip"
  auth_register_archive_path   = "${path.module}/${local.generate_path}/${local.auth_register}.zip"
  auth_login_archive_path      = "${path.module}/${local.generate_path}/${local.auth_login}.zip"
}

resource "random_string" "random" {
  length           = 16
  special          = true
  override_special = "/@£$"
}
