# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Reference the existing security group
data "aws_security_group" "dickson_sec_group" {
  name   = "dickson_sec_group"
  vpc_id = data.aws_vpc.default.id
}

# Allow HTTP traffic on port 80
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = data.aws_security_group.dickson_sec_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  description = "Allow HTTP traffic"
}

# Launch EC2 instance
resource "aws_instance" "my_ec2" {
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "t3.micro"

  # Existing AWS key pair
  key_name = "frontend"

  # Attach existing security group
  vpc_security_group_ids = [
    data.aws_security_group.dickson_sec_group.id
  ]

  # Install Nginx and deploy website
  user_data = <<-EOF
    #!/bin/bash

    apt update -y
    apt install -y nginx git

    # Remove default Nginx page
    rm -f /var/www/html/index.nginx-debian.html

    # Clone GitHub repository
    git clone https://github.com/maduekedickson/complete-pipeline.git /tmp/website

    # Copy website files to Nginx root
    cp -r /tmp/website/website/* /var/www/html/

    # Set permissions
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html

    # Enable and start Nginx
    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = {
    Name = "My RED Web Server"
  }
}