# Allow HTTP traffic on port 80
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = data.aws_security_group.dickson_sec_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  description = "Allow HTTP traffic"
}