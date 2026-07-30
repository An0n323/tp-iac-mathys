output "url_publique" {
  description = "URL du serveur web deploye."
  value       = "http://${aws_instance.web.public_ip}"
}
