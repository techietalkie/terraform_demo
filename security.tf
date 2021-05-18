# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "lb" {
  name        = "load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.main.id

ingress {
  from_port   = 0
  protocol    = "-1"
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow web traffic to load balancer"
}
/*
ingress {
  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  #protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
} */

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    }
}

# Traffic to the EC2 cluster should only come from the ALB
resource "aws_security_group" "dev_ec2" {
  name        = "ec2-tasks-security-group"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    #cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.lb.id]
    #cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 0
    to_port         = 0
    security_groups = [aws_security_group.lb.id]
    #cidr_blocks= ["0.0.0.0/0"]
  }

  /* ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    # security_groups = [aws_security_group.lb.id]
    cidr_blocks= ["0.0.0.0/0"]
  } */

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
