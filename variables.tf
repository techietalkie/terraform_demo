variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}



variable "ec2_auto_scale_role_name" {
  description = "EC2 auto scale role Name"
  default = "myEc2AutoScaleRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}


variable "health_check_path" {
  default = "/"
}

/* variable "tag" {
} */

variable "ec2_key_pair_name" {
  default = "myEC2KeyPair"
}

variable "tag_dev" {
  default = "dev"
}
