resource "aws_security_group" "docker_sg" {
  name = "terraform-docker-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "docker_ec2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  key_name      = "docker-key"

  vpc_security_group_ids = [aws_security_group.docker_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install docker -y
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user

    # Nginx container
    docker pull nginx
    docker run -d -p 80:80 --name nginx nginx

    # MySQL container
    docker pull mysql:8.0
    docker run -d \
      --name mysql \
      -p 3306:3306 \
      -e MYSQL_ROOT_PASSWORD=root123 \
      -e MYSQL_DATABASE=appdb \
      mysql:8.0
  EOF

  tags = {
    Name = "terraform-docker-nginx-mysql"
  }
}
