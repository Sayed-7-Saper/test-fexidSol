output "e_ip" {
  value = aws_eip.eip.public_ip

}
output "nat" {
  value = aws_nat_gateway.natgw.id

}
output "gateway_id" {
  value = aws_internet_gateway.igw.id

}

output "subnet_id" {
  value = { for subnet in aws_subnet.subnets : subnet.tags_all["Name"] => subnet.id }

}
output "vpcid" {
  value = aws_vpc.main.id

}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}
output "availability_zones" {
  value = data.aws_availability_zones.available.names
}