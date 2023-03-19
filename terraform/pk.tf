 resource "tls_private_key" "pk" {
      algorithm = "RSA"
      rsa_bits = 4096
}

  resource "aws_key_pair" "key" {
    key_name   = "ec2-key"
    public_key = tls_private_key.pk.public_key_openssh

    provisioner "local-exec" {
      command = "echo '${tls_private_key.pk.private_key_pem}' > ~/ec2-key.pem"
    }
 }