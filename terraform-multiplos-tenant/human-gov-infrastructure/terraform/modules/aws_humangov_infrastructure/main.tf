resource "aws_security_group" "state_ec2_sg" {
  name        = "${var.application_name}-${var.state_name}-ec2-sg"
  description = "Allow traffic on ports 22 and 80"

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
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["sg-08e67980cf7b7a324"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.application_name}-${var.state_name}"
  }
}

resource "aws_instance" "state_ec2" {
  ami                    = "ami-020cba7c55df1f615" #"ami-05ffe3c48a9991133"
  instance_type          = "t2.micro"
  key_name               = "${var.application_name}-ec2-key"
  vpc_security_group_ids = [aws_security_group.state_ec2_sg.id]
  iam_instance_profile = aws_iam_instance_profile.s3_dynamodb_full_access_instance_profile.name

  tags = {
    Name = "${var.application_name}-${var.state_name}"
  }
}

resource "aws_dynamodb_table" "state_dynamodb" {
  name         = "${var.application_name}-${var.state_name}-dynamodb"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "${var.application_name}-${var.state_name}"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_s3_bucket" "state_s3" {
  bucket = "${var.application_name}-${var.state_name}-s3-${random_string.bucket_suffix.result}"

  tags = {
    Name = "${var.application_name}-${var.state_name}"
  }
}

resource "aws_iam_role" "s3_dynamodb_full_access_role" {
  name = "${var.application_name}-${var.state_name}-s3_dynamodb_full_access_role"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF

  tags = {
      Name = "${var.application_name}-${var.state_name}"
  }  
}


resource "aws_iam_role_policy_attachment" "s3_full_access_role_policy_attachment" {
  role       = aws_iam_role.s3_dynamodb_full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access_role_policy_attachment" {
  role       = aws_iam_role.s3_dynamodb_full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_instance_profile" "s3_dynamodb_full_access_instance_profile" {
  name = "${var.application_name}-${var.state_name}-s3_dynamodb_full_access_instance_profile"
  role = aws_iam_role.s3_dynamodb_full_access_role.name

  tags = {
    Name = "${var.application_name}-${var.state_name}"
  }  
}