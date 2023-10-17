module "network" {
  source   = "./Modules/network"
  Name     = var.Name
  vpc_cidr = var.vpcid

  vpc_subnets = {
    "public1" = {
      cidr        = var.public1["cidr"]
      AZ          = 0
      route_table = "public_route"
      map_pub     = true
    }
    "private1" = {
      cidr        = var.private1["cidr"]
      AZ          = 0
      route_table = "private_route"
      map_pub     = false
    }
    "public2" = {
      cidr        = var.public2["cidr"]
      AZ          = 1
      route_table = "public_route"
      map_pub     = true
    }
    "private2" = {
      cidr        = var.private2["cidr"]
      AZ          = 1
      route_table = "private_route"
      map_pub     = false
    }
     "private3" = {
      cidr        = var.private3["cidr"]
      AZ          = 1
      route_table = "private_route"
      map_pub     = false
    }
     "private4" = {
      cidr        = var.private4["cidr"]
      AZ          = 1
      route_table = "private_route"
      map_pub     = false
    }
    
    
  }

  route_table = {
    "public_route" = {
      cidr       = "0.0.0.0/0"
      gateway_id = module.network.gateway_id
    }
    "private_route" = {
      cidr       = "0.0.0.0/0"
      gateway_id = module.network.nat
    }
  }
}

module "jenkins" {
  source = "./Modules/EC2"
  Name   = var.Name

  vpc_id = module.network.vpcid

  #EC2
  EC2_Name     = "jenkins"
  EC2_Port     = 8080
  duckdnstoken = var.duckdnstoken
  instance_ami = {
    name_ami = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    owners   = ["amazon"]
  }
  instance_type                = "t2.medium"
  EBS_volume                   = 8
  key_pair                     = var.key_pair
  associate_map_public_address = true
  ec2_subnet_id                = module.network.subnet_id["public1"]

  #Security Group
  sg_name = "jenkins_security_group"
  sg_rules = {
    "ssh port"     = { type = "ingress", port = "22", protocol = "tcp", cidr_blocks = ["${chomp(data.http.myip.body)}/32"] }
    "jenkins port" = { type = "ingress", port = "8080", protocol = "tcp", cidr_blocks = [var.IPS] }
    "HTTP port"    = { type = "ingress", port = "80", protocol = "tcp", cidr_blocks = [var.IPS] }
    "HTTPS port"   = { type = "ingress", port = "443", protocol = "tcp", cidr_blocks = [var.IPS] }
    "egress all"   = { type = "egress", port = "0", protocol = "-1", cidr_blocks = [var.IPS] }
  }
}



module "ECR" {
  source = "./Modules/ECR"
  ecr_repositories = {
    go_app = {
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      force_delete         = true

    }
  }

}
module "EKS" {
  source = "./Modules/EKS"
  Name   = var.Name

  subnet_list    = [module.network.subnet_id["private1"], module.network.subnet_id["private2"]]
  key_pair       = var.key_pair
  instance_types = var.instance_types
  cidr           = var.vpcid
  vpcid          = module.network.vpcid
  scaling_config = {
    desired_size = var.scaling_config["desired_size"]
    max_size     = var.scaling_config["max_size"]
    min_size     = var.scaling_config["min_size"]
  }
}