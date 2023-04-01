provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "example" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "example-subnet"
  }
}

resource "aws_security_group" "example" {
  name        = "example"
  description = "Example security group"
  vpc_id      = aws_vpc.example.id
}

resource "aws_instance" "example" {
  ami           = "ami-0c94855ba95b798c7" # Ubuntu Server 18.04 LTS
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.example.id]
  subnet_id              = aws_subnet.example.id

  tags = {
    Name = "example-instance"
  }
}

resource "aws_db_instance" "example" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "exampledb"
  username             = "exampleuser"
  password             = "examplepassword"
  parameter_group_name = "default.mysql5.7"
  publicly_accessible  = false
  subnet_group_name    = aws_db_subnet_group.example.name

  vpc_security_group_ids = [aws_security_group.example.id]

  tags = {
    Name = "example-rds"
  }
}

resource "aws_db_subnet_group" "example" {
  name       = "example"
  subnet_ids = [aws_subnet.example.id]

  tags = {
    Name = "example-dbsubnet"
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  acl    = "private"
  tags = {
    Name = "example-bucket"
  }
}
