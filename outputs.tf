// Output the public IP of the instance
output "instance_public_ip" { // Output the public IP of the instance
  value = aws_instance.tf-ec2.public_ip
}