terraform {
 required_providers {
  aws = {
   source = "hashicorp/aws"
  }
 }
}
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet for us-east-1a"
  }
}

resource "aws_instance" "ec2_instance" {
    ami = "ami-0557a15b87f6559cf"
    subnet_id = "${aws_default_subnet.default_az1.id}"
    instance_type = "t2.micro"
    key_name = "key"
    vpc_security_group_ids = [aws_security_group.sg-1.id]
    root_block_device {
    volume_type = "gp2"
    volume_size = "8"
    delete_on_termination = true
    }
} 