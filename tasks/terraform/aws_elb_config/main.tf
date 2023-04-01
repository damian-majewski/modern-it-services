resource "aws_elb" "example" {
  name               = "example-elb"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances = ["${aws_instance.example.id}"]

  tags = {
    Name = "example-elb"
  }
}

resource "aws_security_group" "elb" {
  name        = "example-elb-sg"
  description = "Allow incoming traffic to ELB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
