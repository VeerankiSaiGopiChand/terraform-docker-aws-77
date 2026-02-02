output "public_ip" {
  value = aws_instance.docker_ec2.public_ip
}

output "mysql_connect" {
  value = "mysql -h ${aws_instance.docker_ec2.public_ip} -u root -p"
}
