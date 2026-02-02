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

  # Install kubectl
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  chmod +x kubectl
  mv kubectl /usr/local/bin/

  # Install kind
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
  chmod +x kind
  mv kind /usr/local/bin/kind

  # Create Kubernetes cluster
  kind create cluster --name terraform-cluster

  # Apply Kubernetes manifests
  kubectl apply -f https://raw.githubusercontent.com/VeerankiSaiGopiChand/terraform-docker-aws-77/main/k8s/nginx.yaml
  kubectl apply -f https://raw.githubusercontent.com/VeerankiSaiGopiChand/terraform-docker-aws-77/main/k8s/mysql.yaml
EOF


  tags = {
    Name = "terraform-docker-nginx-mysql"
  }
}
