provider "aws" {
  region = "us-east-1"

}

resource "aws_instance" "host01" {
  ami                    = "ami-0ec18f6103c5e0491" # Red Hat Enterprise Linux version 9 
  instance_type          = "t2.micro"
  key_name               = "tcb-ansible-key"
  vpc_security_group_ids = [aws_security_group.secgroup.id]

  provisioner "local-exec" {
    command = "sleep 30; ssh-keyscan ${self.private_ip} >> ~/.ssh/known_hosts"
  }
}

resource "aws_instance" "host02" {
  ami                    = "ami-0ec18f6103c5e0491" # Red Hat Enterprise Linux version 9 
  instance_type          = "t2.micro"
  key_name               = "tcb-ansible-key"
  vpc_security_group_ids = [aws_security_group.secgroup.id]

  provisioner "local-exec" {
    command = "sleep 30; ssh-keyscan ${self.private_ip} >> ~/.ssh/known_hosts"
  }
}

resource "aws_instance" "host03" {
  ami                    = "ami-0779caf41f9ba54f0" # Debian Enterprise Linux version 9 
  instance_type          = "t2.micro"
  key_name               = "tcb-ansible-key"
  vpc_security_group_ids = [aws_security_group.secgroup.id]

  provisioner "local-exec" {
    command = "sleep 30; ssh-keyscan ${self.private_ip} >> ~/.ssh/known_hosts"
  }
}


resource "aws_security_group" "secgroup" {

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
    from_port       = 0
    to_port         = 0
    protocol        = "-1"                     # It means "All Protocols/Ports"
    security_groups = ["sg-08e67980cf7b7a324"] # Update this field!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # It means "All Protocols/Ports"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "host01_private_ip" {
  value = aws_instance.host01.private_ip # Update "host" inventory file
}

output "host02_private_ip" {
  value = aws_instance.host02.private_ip # Update "host" inventory file
}

output "host03_private_ip" {
  value = aws_instance.host03.private_ip # Update "host" inventory file
}