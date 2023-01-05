# General
region = "us-east-1"
name   = "TF-EXAMPLE-VM"
global_tags = {
  ManagedBy   = "Terraform"
  Application = "Palo Alto Networks VM-Series NGFW"
}

# VPC
security_vpc_name = "VPC-LAB1"
security_vpc_cidr = "10.1.0.0/16"

# Subnets
security_vpc_subnets = {
  # Do not modify value of `set=`, it is an internal identifier referenced by main.tf.
  "10.1.1.0/24" = { az = "us-east-1a", set = "mgmt",  create_subnet = false, name="SN-VPC-LAB1-10.1.1.0", create_route_table = false, associate_route_table = false, route_table_name = "RT-VPC-LAB1" }
  "10.1.2.0/24" = { az = "us-east-1a", set = "private",  create_subnet = false, name="SN-VPC-LAB1-10.1.2.0", create_route_table = false, associate_route_table = false, route_table_name = "RT-VPC-LAB1" }
  "10.1.250.0/24" = { az = "us-east-1a", set = "public",  create_subnet = false, name="VPC1-Inside1-10.1.250.0", create_route_table = false, associate_route_table = false, route_table_name = "RT-VPC-LAB1" }

}

# Security Groups
security_vpc_security_groups = {
  vmseries_mgmt = {
    name = "vmseries_mgmt"
    rules = {
      all_outbound = {
        description = "Permit All traffic outbound"
        type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
      https = {
        description = "Permit HTTPS"
        type        = "ingress", from_port = "443", to_port = "443", protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # TODO: update here
      }
      ssh = {
        description = "Permit SSH"
        type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # TODO: update here
      }
    }
  }
  vmseries_permit_all = {
    name = "vmseries_permit_all"
    rules = {
      all_outbound = {
        description = "Permit All traffic outbound"
        type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
      https = {
        description = "Permit HTTPS"
        type        = "ingress", from_port = "0", to_port = "0", protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"] # TODO: update here
      }
      
    }
  }
}

# VM-Series
ssh_key_name     = "LAB1-KP"
vmseries_version = "10.2.2"
vmseries = {
  vmseries01 = {
    az = "us-east-1a"
    interfaces = {
      mgmt = {
        device_index      = 0
        security_group    = "vmseries_mgmt"
        source_dest_check = true
        subnet            = "mgmt"
        create_public_ip  = true

      }
      public = {
        device_index      = 1
        security_group    = "vmseries_permit_all"
        source_dest_check = false
        subnet            = "public"
        create_public_ip  = false

      }
      private = {
        device_index      = 2
        security_group    = "vmseries_permit_all"
        source_dest_check = false
        subnet            = "private"
        create_public_ip  = false

      }
    }
  }
}

bootstrap_options = "plugin-op-commands=aws-gwlb-inspect:enable,aws-gwlb-overlay-routing:enable;type=dhcp-client;hostname=vms01"

ebs_kms_key_alias = "alias/aws/ebs"

# Routes
security_vpc_routes_outbound_destin_cidrs = ["0.0.0.0/0"]
