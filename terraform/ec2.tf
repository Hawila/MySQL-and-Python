
resource "aws_iam_role" "ec2-iam-role" {
 name = "sprint-ec2-iam-role"
 path = "/"
 assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "ec2.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF
}

resource "aws_iam_policy" "eks-fullaccess" {
  name        = "eks-access"
  path        = "/"
  description = "Allow Full access to Kubernates cluster"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action: [
        "eks:*",
        "ecr:*",
      ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

 resource "aws_iam_role_policy_attachment" "eks-fullaccess" {
  policy_arn = aws_iam_policy.eks-fullaccess.arn
  role    = aws_iam_role.ec2-iam-role.name
 }
 
 

  resource "aws_iam_instance_profile" "ec2_profile"{
    name = "ec2-profile"
    role = aws_iam_role.ec2-iam-role.name
  }

resource "aws_instance" "ec2_instance" {
    ami = "ami-0557a15b87f6559cf"
    subnet_id = "${aws_subnet.public_1.id}"
    instance_type = "t2.micro"
    key_name = "ec2-key"
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    vpc_security_group_ids = [aws_security_group.sg-1.id]
    root_block_device {
    volume_type = "gp2"
    volume_size = "8"
    delete_on_termination = true
    }
    provisioner "local-exec" {
      command = "echo target ansible_host='${self.public_ip}' ansible_ssh_user=ubuntu ansible_ssh_private_key_file=~/ec2-key.pem ansible_python_interpreter=/usr/bin/python3 > ../ansible/inventory.txt"
    }
} 
