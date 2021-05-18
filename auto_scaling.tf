resource "aws_autoscaling_group" "dev_auto_ec2" {
  name = "dev env auto scaling group"
  min_size       = 1
  desired_capacity      = 1
  max_size       = 1
  launch_configuration  = aws_launch_configuration.ec2_public_launch_configuration.name
  vpc_zone_identifier = aws_subnet.public.*.id
}

resource "aws_autoscaling_policy" "up" {
  name               = "cb_scale_up"
  autoscaling_group_name = aws_autoscaling_group.dev_auto_ec2.id
  policy_type = "TargetTrackingScaling"
  min_adjustment_magnitude = 1

  target_tracking_configuration {
  predefined_metric_specification {
    predefined_metric_type = "ASGAverageCPUUtilization"
  }
  target_value = 80.0
}
}


resource "aws_iam_role" "ec2_iam_role" {
  name               = "EC2-IAM-Role"
  assume_role_policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement":
  [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com", "application-autoscaling.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ec2_iam_role_policy" {
  name = "EC2-IAM-Policy"
  role = aws_iam_role.ec2_iam_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "elasticloadbalancing:*",
        "cloudwatch:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2-IAM-Instance-Profile"
  role = aws_iam_role.ec2_iam_role.name
}


resource "aws_launch_configuration" "ec2_public_launch_configuration" {
  image_id                    = "ami-0bcf5425cdc1d8a85"
  instance_type               = "t2.micro"
  key_name                    = var.ec2_key_pair_name
  associate_public_ip_address = true
  #count = 1
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups             = [aws_security_group.dev_ec2.id]

  user_data = <<EOF
    #!/bin/bash
    yum update –y
    amazon-linux-extras install nginx1.12
    nginx -v
    systemctl start nginx
    systemctl enable nginx
    chmod 2775 /usr/share/nginx/html
    find /usr/share/nginx/html -type d -exec chmod 2775 {} \;
    find /usr/share/nginx/html -type f -exec chmod 0664 {} \;
    echo "<h3>Welcome Abhijeet. Have a great Day</h3>" > /usr/share/nginx/html/index.html
    EOF
}

data "aws_instances" "dev-instances" {

  filter {
    name   = "instance.group-id"
    values = [aws_security_group.dev_ec2.id]
  }

  instance_state_names = [ "running", "stopped" ]
  depends_on           = [aws_autoscaling_group.dev_auto_ec2]
}
