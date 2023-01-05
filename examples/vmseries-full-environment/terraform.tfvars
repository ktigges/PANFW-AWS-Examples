# - AWS Provider Authentication and Attributes
region = "us-east-1"


# - General
name_prefix = ""
global_tags = {
  ManagedBy = "terraform"
}


# - Network Configuration
# -- VPCs
vpcs = {
  "vpc-bastion" = {
    cidr                    = "10.104.0.0/23"
    create_internet_gateway = false
    security_groups         = {}
  }
  "vpc-test" = {
    cidr                    = "10.106.0.0/23"
    create_internet_gateway = true
    security_groups = {
      web_app = {
        name = "web_application"
        rules = {
          all_outbound = {
            description = "Permit All traffic outbound"
            type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
          http = {
            description = "Permit HTTP to test app"
            type        = "ingress", from_port = "80", to_port = "80", protocol = "tcp"
            cidr_blocks = ["10.106.0.32/28", "10.106.1.32/28"]
          }
        }
      }
    }
  }
  "vpc-ew" = {
    cidr                    = "10.100.0.0/23"
    create_internet_gateway = true
    security_groups = {
      vmseries_data = {
        name = "vmseries_data"
        rules = {
          all_outbound = {
            description = "Permit All traffic outbound"
            type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
          geneve = {
            description = "Permit GENEVE to GWLB subnets"
            type        = "ingress", from_port = "6081", to_port = "6081", protocol = "udp"
            cidr_blocks = ["10.100.0.48/28", "10.100.1.48/28"]
          }
          health_probe = {
            description = "Permit Port 80 Health Probe to GWLB subnets"
            type        = "ingress", from_port = "80", to_port = "80", protocol = "tcp"
            cidr_blocks = ["10.100.0.48/28", "10.100.1.48/28"]
          }
        }
      }
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
          panorama_ssh = {
            description = "Permit Panorama SSH (Optional)"
            type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8"]
          }
          panorama_mgmt = {
            description = "Permit Panorama Management"
            type        = "ingress", from_port = "3978", to_port = "3978", protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8"]
          }
          panorama_log = {
            description = "Permit Panorama Logging"
            type        = "ingress", from_port = "28443", to_port = "28443", protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8"]
          }
        }
      }
    }
  }
  "vpc-ns" = {
    cidr                    = "10.100.2.0/23"
    create_internet_gateway = true
    security_groups = {
      vmseries_data = {
        name = "vmseries_data"
        rules = {
          all_outbound = {
            description = "Permit All traffic outbound"
            type        = "egress", from_port = "0", to_port = "0", protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
          geneve = {
            description = "Permit GENEVE to GWLB subnets"
            type        = "ingress", from_port = "6081", to_port = "6081", protocol = "udp"
            cidr_blocks = ["10.100.2.48/28", "10.100.3.48/28"]
          }
          health_probe = {
            description = "Permit Port 80 Health Probe to GWLB subnets"
            type        = "ingress", from_port = "80", to_port = "80", protocol = "tcp"
            cidr_blocks = ["10.100.2.48/28", "10.100.3.48/28"]
          }
        }
      }
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
          panorama_ssh = {
            description = "Permit Panorama SSH (Optional)"
            type        = "ingress", from_port = "22", to_port = "22", protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8"]
          }
          panorama_mgmt = {
            description = "Permit Panorama Management"
            type        = "ingress", from_port = "3978", to_port = "3978", protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8"]
          }
          panorama_log = {
            description = "Permit Panorama Logging"
            type        = "ingress", from_port = "28443", to_port = "28443", protocol = "tcp"
            cidr_blocks = ["10.0.0.0/8"]
          }
        }
      }
      vmseries_public = {
        name = "vmseries_public"
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
          http = {
            description = "Permit HTTP"
            type        = "ingress", from_port = "80", to_port = "80", protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"] # TODO: update here
          }
        }
      }
    }
  }
}
# --- VPC East/West
vpc_subnets = {
  # Do not modify value of `set=`, it is an internal identifier referenced by main.tf.
  "10.100.0.0/28"  = { az = "us-east-1a", set = "mgmt", vpc = "vpc-ew" }
  "10.100.1.0/28"  = { az = "us-east-1b", set = "mgmt", vpc = "vpc-ew" }
  "10.100.0.16/28" = { az = "us-east-1a", set = "private", vpc = "vpc-ew" }
  "10.100.1.16/28" = { az = "us-east-1b", set = "private", vpc = "vpc-ew" }
  "10.100.0.32/28" = { az = "us-east-1a", set = "gwlb", vpc = "vpc-ew" }
  "10.100.1.32/28" = { az = "us-east-1b", set = "gwlb", vpc = "vpc-ew" }
  "10.100.0.48/28" = { az = "us-east-1a", set = "gwlbe-ew", vpc = "vpc-ew" }
  "10.100.1.48/28" = { az = "us-east-1b", set = "gwlbe-ew", vpc = "vpc-ew" }
  "10.100.0.64/28" = { az = "us-east-1a", set = "tgw", vpc = "vpc-ew" }
  "10.100.1.64/28" = { az = "us-east-1b", set = "tgw", vpc = "vpc-ew" }

  "10.100.2.0/28"  = { az = "us-east-1a", set = "mgmt", vpc = "vpc-ns" }
  "10.100.3.0/28"  = { az = "us-east-1b", set = "mgmt", vpc = "vpc-ns" }
  "10.100.2.16/28" = { az = "us-east-1a", set = "private", vpc = "vpc-ns" }
  "10.100.3.16/28" = { az = "us-east-1b", set = "private", vpc = "vpc-ns" }
  "10.100.2.32/28" = { az = "us-east-1a", set = "gwlb", vpc = "vpc-ns" }
  "10.100.3.32/28" = { az = "us-east-1b", set = "gwlb", vpc = "vpc-ns" }
  "10.100.2.48/28" = { az = "us-east-1a", set = "gwlbe-outbound", vpc = "vpc-ns" }
  "10.100.3.48/28" = { az = "us-east-1b", set = "gwlbe-outbound", vpc = "vpc-ns" }
  "10.100.2.64/28" = { az = "us-east-1a", set = "tgw", vpc = "vpc-ns" }
  "10.100.3.64/28" = { az = "us-east-1b", set = "tgw", vpc = "vpc-ns" }
  "10.100.2.80/28" = { az = "us-east-1a", set = "public", vpc = "vpc-ns" }
  "10.100.3.80/28" = { az = "us-east-1b", set = "public", vpc = "vpc-ns" }

  "10.104.0.0/28" = { az = "us-east-1a", set = "web", vpc = "vpc-bastion" }
  "10.104.1.0/28" = { az = "us-east-1b", set = "web", vpc = "vpc-bastion" }

  "10.106.0.16/28" = { az = "us-east-1a", set = "alb", vpc = "vpc-test" }
  "10.106.1.16/28" = { az = "us-east-1b", set = "alb", vpc = "vpc-test" }
  "10.106.0.32/28" = { az = "us-east-1a", set = "gwlbe", vpc = "vpc-test" }
  "10.106.1.32/28" = { az = "us-east-1b", set = "gwlbe", vpc = "vpc-test" }
  "10.106.0.48/28" = { az = "us-east-1a", set = "web", vpc = "vpc-test" }
  "10.106.1.48/28" = { az = "us-east-1b", set = "web", vpc = "vpc-test" }
}

vpc_routes = [
  { vpc = "vpc-ns", set = "mgmt", cidr = "0.0.0.0/0", type = "gwlb", designator = "gwlb-endpoint-ns" },
  { vpc = "vpc-ns", set = "mgmt", cidr = "10.0.0.0/8", type = "tgw", designator = "tgwa-ns" },
  { vpc = "vpc-ns", set = "public", cidr = "0.0.0.0/0", type = "igw" },
  { vpc = "vpc-ns", set = "gwlbe-outbound", cidr = "10.0.0.0/8", type = "tgw", designator = "tgwa-ns" },
  { vpc = "vpc-ns", set = "tgw", cidr = "0.0.0.0/0", type = "gwlb", designator = "gwlb-endpoint-ns" },

  { vpc = "vpc-ew", set = "mgmt", cidr = "0.0.0.0/0", type = "tgw", designator = "tgwa-ew" },
  { vpc = "vpc-ew", set = "gwlbe-ew", cidr = "0.0.0.0/0", type = "tgw", designator = "tgwa-ew" },
  { vpc = "vpc-ew", set = "tgw", cidr = "0.0.0.0/0", type = "gwlb", designator = "gwlb-endpoint-ew" },

  { vpc = "vpc-bastion", set = "web", cidr = "0.0.0.0/0", type = "tgw", designator = "tgwa-bastion" },

  { vpc = "vpc-test", set = "alb", cidr = "0.0.0.0/0", type = "gwlb", designator = "gwlb-endpoint-test" },
  { vpc = "vpc-test", set = "gwlbe", cidr = "0.0.0.0/0", type = "igw" },
  { vpc = "vpc-test", set = "web", cidr = "0.0.0.0/0", type = "tgw", designator = "tgwa-test" },
]


# -- TGW
transit_gateway_name = "tgw"
transit_gateway_asn  = "65200"
transit_gateway_attachments = {
  "tgwa-ew" = {
    name            = "tgwa-east-west"
    subnet_set      = "tgw"
    vpc             = "vpc-ew"
    route_table     = "from_security_vpc"
    propagate_to_rt = "from_spoke_vpc"
  }
  "tgwa-ns" = {
    name            = "tgwa-north-south"
    subnet_set      = "tgw"
    vpc             = "vpc-ns"
    route_table     = "from_security_vpc"
    propagate_to_rt = "from_spoke_vpc"
  }
  "tgwa-bastion" = {
    name            = "tgwa-bastion"
    subnet_set      = "web"
    vpc             = "vpc-bastion"
    route_table     = "from_spoke_vpc"
    propagate_to_rt = "from_security_vpc"
  }
  "tgwa-test" = {
    name            = "tgwa-test"
    subnet_set      = "web"
    vpc             = "vpc-test"
    route_table     = "from_spoke_vpc"
    propagate_to_rt = "from_security_vpc"
  }
}
transit_gateway_route_tables = {
  "from_security_vpc" = {
    create = true
    name   = "from_security"
    routes = {
      "sec_vpc_ns" = {
        cidr                = "0.0.0.0/0"
        is_blackhole        = false
        next_hop_attachment = "tgwa-ns"
      }
      "mgmt_1a_ew" = {
        cidr                = "10.100.0.0/28"
        is_blackhole        = false
        next_hop_attachment = "tgwa-ew"
      }
      "mgmt_1b_ew" = {
        cidr                = "10.100.1.0/28"
        is_blackhole        = false
        next_hop_attachment = "tgwa-ew"
      }
    }
  }
  "from_spoke_vpc" = {
    create = true
    name   = "from_spokes"
    routes = {
      "sec_vpc_ns" = {
        cidr                = "0.0.0.0/0"
        is_blackhole        = false
        next_hop_attachment = "tgwa-ns"
      }
      "sec_vpc_ew" = {
        cidr                = "10.0.0.0/8"
        is_blackhole        = false
        next_hop_attachment = "tgwa-ew"
      }
    }
  }
  "from_customer" = {
    create = true
    name   = "from_customer"
    routes = {
      "test_app_vpc" = {
        cidr                = "10.104.0.0/23"
        is_blackhole        = false
        next_hop_attachment = "tgwa-ew"
      }
      "mgmt_1a_ew" = {
        cidr                = "10.100.0.0/28"
        is_blackhole        = false
        next_hop_attachment = "tgwa-ew"
      }
      "mgmt_1b_ew" = {
        cidr                = "10.100.1.0/28"
        is_blackhole        = false
        next_hop_attachment = "tgwa-ew"
      }
      "mgmt_1a_ns" = {
        cidr                = "10.100.2.0/28"
        is_blackhole        = false
        next_hop_attachment = "tgwa-ns"
      }
      "mgmt_1b_ns" = {
        cidr                = "10.100.3.0/28"
        is_blackhole        = false
        next_hop_attachment = "tgwa-ns"
      }
    }
  }
}


# -- GWLB
gwlbs = {
  "security-gwlb-ew" = {
    vpc                      = "vpc-ew"
    subnet_set               = "gwlb"
    vmseries_pair_designator = "ew"
  }
  "security-gwlb-ns" = {
    vpc                      = "vpc-ns"
    subnet_set               = "gwlb"
    vmseries_pair_designator = "ns"
  }
}
gwlb_endpoints = {
  "gwlb-endpoint-ew" = {
    gwlb       = "security-gwlb-ew"
    vpc        = "vpc-ew"
    subnet_set = "gwlbe-ew"
  }
  "gwlb-endpoint-ns" = {
    gwlb       = "security-gwlb-ns"
    vpc        = "vpc-ns"
    subnet_set = "gwlbe-outbound"
  }
  "gwlb-endpoint-test" = {
    gwlb       = "security-gwlb-ns"
    vpc        = "vpc-test"
    subnet_set = "gwlbe"
  }
}


# - VM-Series
vmseries_version = "10.1.6-h6"    # There is no 10.1.6-h3 in us-east-1 region
ssh_key_name     = "fosix-pub-vm" # TODO: your AWS key pair name goes here
vmseries = {
  vmseries01ew = {
    az            = "us-east-1a"
    vpc           = "vpc-ew"
    gwlb_endpoint = "gwlb-endpoint-ew"
    interfaces = {
      data = {
        device_index        = 0
        subnet_set          = "private"
        security_group_name = "vmseries_data"
        source_dest_check   = false
        create_public_ip    = false
      }
      mgmt = {
        device_index        = 1
        subnet_set          = "mgmt"
        security_group_name = "vmseries_mgmt"
        source_dest_check   = true
        create_public_ip    = true
      }
    }
    bootstrap_options = {
      mgmt-interface-swap = "enable"
      plugin-op-commands  = "aws-gwlb-inspect:enable,aws-gwlb-overlay-routing:enable,panorama-licensing-mode-on"
      type                = "dhcp-client"
      panorama-server     = "10.80.0.11"  ## TODO: CHANGE-ME!
      tplname             = "fw-lo-stack" ## TODO: CHANGE-ME!
      dgname              = "fw-lo"       ## TODO: CHANGE-ME!
      auth-key            = ""            ## TODO: CHANGE-ME!
      # vm-auth-key         = "" ## TODO: CHANGE-ME!
      # authcodes           = "" ## TODO: CHANGE-ME!
    }
    subinterface = "ethernet1/1.10"
  }
  vmseries02ew = {
    az            = "us-east-1b"
    vpc           = "vpc-ew"
    gwlb_endpoint = "gwlb-endpoint-ew"
    interfaces = {
      data = {
        device_index        = 0
        subnet_set          = "private"
        security_group_name = "vmseries_data"
        source_dest_check   = false
        create_public_ip    = false
      }
      mgmt = {
        device_index        = 1
        subnet_set          = "mgmt"
        security_group_name = "vmseries_mgmt"
        source_dest_check   = true
        create_public_ip    = true
      }
    }
    bootstrap_options = {
      mgmt-interface-swap = "enable"
      plugin-op-commands  = "aws-gwlb-inspect:enable,aws-gwlb-overlay-routing:enable,panorama-licensing-mode-on"
      type                = "dhcp-client"
      panorama-server     = "10.80.0.11"  ## TODO: CHANGE-ME!
      tplname             = "fw-lo-stack" ## TODO: CHANGE-ME!
      dgname              = "fw-lo"       ## TODO: CHANGE-ME!
      auth-key            = ""            ## TODO: CHANGE-ME!
      # vm-auth-key         = "" ## TODO: CHANGE-ME!
      # authcodes           = "" ## TODO: CHANGE-ME!
    }
    subinterface = "ethernet1/1.10"
  }
  vmseries01ns = {
    az            = "us-east-1a"
    vpc           = "vpc-ns"
    gwlb_endpoint = "gwlb-endpoint-ns"
    interfaces = {
      data = {
        device_index        = 0
        subnet_set          = "private"
        security_group_name = "vmseries_data"
        source_dest_check   = false
        create_public_ip    = false
      }
      mgmt = {
        device_index        = 1
        subnet_set          = "mgmt"
        security_group_name = "vmseries_mgmt"
        source_dest_check   = true
        create_public_ip    = true
      }
      public = {
        device_index        = 2
        subnet_set          = "public"
        security_group_name = "vmseries_public"
        source_dest_check   = false
        create_public_ip    = true
      }
    }
    bootstrap_options = {
      mgmt-interface-swap = "enable"
      plugin-op-commands  = "aws-gwlb-inspect:enable,aws-gwlb-overlay-routing:enable,panorama-licensing-mode-on"
      type                = "dhcp-client"
      panorama-server     = "10.80.0.11"  ## TODO: CHANGE-ME!
      tplname             = "fw-ns-stack" ## TODO: CHANGE-ME!
      dgname              = "fw-ns"       ## TODO: CHANGE-ME!
      auth-key            = ""            ## TODO: CHANGE-ME!
      # vm-auth-key         = "" ## TODO: CHANGE-ME!
      # authcodes           = "" ## TODO: CHANGE-ME!
    }
    subinterface = "ethernet1/1.20"
  }
  vmseries02ns = {
    az            = "us-east-1b"
    vpc           = "vpc-ns"
    gwlb_endpoint = "gwlb-endpoint-ns"
    interfaces = {
      data = {
        device_index        = 0
        subnet_set          = "private"
        security_group_name = "vmseries_data"
        source_dest_check   = false
        create_public_ip    = false
      }
      mgmt = {
        device_index        = 1
        subnet_set          = "mgmt"
        security_group_name = "vmseries_mgmt"
        source_dest_check   = true
        create_public_ip    = true
      }
      public = {
        device_index        = 2
        subnet_set          = "public"
        security_group_name = "vmseries_public"
        source_dest_check   = false
        create_public_ip    = true
      }
    }
    bootstrap_options = {
      mgmt-interface-swap = "enable"
      plugin-op-commands  = "aws-gwlb-inspect:enable,aws-gwlb-overlay-routing:enable,panorama-licensing-mode-on"
      type                = "dhcp-client"
      panorama-server     = "10.80.0.11"  ## TODO: CHANGE-ME!
      tplname             = "fw-ns-stack" ## TODO: CHANGE-ME!
      dgname              = "fw-ns"       ## TODO: CHANGE-ME!
      auth-key            = ""            ## TODO: CHANGE-ME!
      # vm-auth-key         = "" ## TODO: CHANGE-ME!
      # authcodes           = "" ## TODO: CHANGE-ME!
    }
    subinterface = "ethernet1/1.20"
  }
}