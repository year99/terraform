variable "ami_id" {
  type    = string
  default = "ami-06ca3ca175f37dd66" // Ubuntu 20.04
}

variable "ami_key_pair" {
  type    = string
  default = "terraform-ec2" // Key pair name
}

