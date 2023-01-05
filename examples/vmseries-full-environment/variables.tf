# - AWS Provider Authentication and Attributes
variable "region" {
  description = "A region used for deployment."
  type        = string
}


# - General
variable "name_prefix" {
  description = "A prefix that will be added to all resource names."
  default     = ""
  type        = string
}
variable "global_tags" {
  description = "A map of tags that will be added to all resources."
  default     = {}
  type        = map(any)
}


# - Network Configuration
# -- VPCs
variable "vpcs" {
  description = <<-EOF
  VPC definition. This is a map where key is the VPC name and value has the following properties:

  - `cidr` : a VPC address space
  - `create_internet_gateway` : bool, controls if an IGW will be created in this particular VPC
  - `security_groups` : a map of security groups hosted in this VPC, for structure see below.

  In the security group definition key is used only for internal indexing of resources. Value contains the following properties:

  - `name` : the actual name of the Security Group
  - `rules` : a map of security rules.

  Security rules have again the map structure, where key is the rule name and value has the following properties:

  - `description` : a rule description
  - `type` : rule type, either `ingress` or `egress`
  - `from_port` : port that starts the port range defined by this rules
  - `to_port` : port that ends the port range, when set to the same value as `from_port` this makes a rule serving a single port; set both values to `0` to create all-ports rule
  - `protocol` : a protocol used by this rule, see AWS documentation for all possible values; the most common ones are: `tcp`, `udp`, `icmp` or `-1` for all
  - `cidr_blocks` : a list of cidr served by this rule.

  Example:
  ```
  {
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
  }
  ```
  EOF
}
variable "vpc_subnets" {
  description = <<-EOF
  Subnets definition.
  
  Following format is supported:
  ```
  {
    "x.x.x.x/y" = {
      az = "availability zone name"
      set = "subnet set name as referenced by main.tf"
      vpc = "vpc name - key in the `security_vpc` map"
    }
  }
  ```

  Example: 
  ```
  {
    "10.100.0.0/28"  = { az = "us-east-1a", set = "mgmt", vpc = "vpc-ew" }
  }
  ```
  EOF
  type        = map(any)
}
variable "vpc_routes" {
  description = <<-EOF
  A list of routes for all VPC, each list element is a map. Three combinations are available, each for a different next hop resource.

  IGW Example:
  ```
  { 
    vpc  = "vpc-ns"       # VPC key name like in `security_vpc` variable
    set  = "mgmt"       # Subnet set name like in the `security_vpc_subnets` variable
    cidr = "0.0.0.0/0"    # Destination cidr
    type = "igw"          # Next how resource type, in this case an IGW
  }
  ```
  
  TGW Example:
  ```
  { 
    vpc         = "vpc-ns"       # VPC key name like in `security_vpc` variable
    set         = "private"      # Subnet set name like in the `security_vpc_subnets` variable
    cidr        = "0.0.0.0/0"    # Destination cidr
    type        = "tgw"          # Next how resource type, in this case a TGW endpoint
    designator  = "sec_ns"       # TGW attachment key name like in the `transit_gateway_attachments` variable
  }
  ```
  GWLB Example:
  ```
  { 
    vpc         = "vpc-ns"            # VPC key name like in `security_vpc` variable
    set         = "private"           # Subnet set name like in the `security_vpc_subnets` variable
    cidr        = "10.0.0.0/8"        # Destination cidr
    type        = "gwlb"              # Next how resource type, in this case an IGW
    designator  = "gwlb-endpoint-ns"  # GWLB endpoint key name like in the `gwlb_endpoints` variable
  }
  ```
  EOF
}


# -- TGW
variable "transit_gateway_name" {
  description = "The name tag of the created Transit Gateway."
  type        = string
}
variable "transit_gateway_asn" {
  description = <<-EOF
  Private Autonomous System Number (ASN) of the Transit Gateway for the Amazon side of a BGP session.
  The range is 64512 to 65534 for 16-bit ASNs and 4200000000 to 4294967294 for 32-bit ASNs.
  EOF
  type        = number
}
variable "transit_gateway_attachments" {
  description = <<-EOF
  Name of the TGW attachments.
  Example:
  ```
  {
    "security_ew" = {
      name            = "transit_gateway_attachment_ew"
      subnet_set      = "tgw"
      vpc             = "vpc-ew"
      route_table     = "from_security"
      propagate_to_rt = "from_spoke"
    }
  }
  EOF
  type        = map(any)
}
variable "transit_gateway_route_tables" {
  description = <<-EOF
  Complex input with the Route Tables of the Transit Gateway. Example:

  ```
  {
    "from_security_vpc" = {
      create = true
      name   = "myrt1"
      routes = {
        route_name = {
          cidr = "1.2.2.0/24"
          is_blackhole = false
        }
      }
    }
    "from_spoke_vpc" = {
      create = true
      name   = "myrt2"
      routes = {}
    }
  }
  ```

  Two keys are required:

  - from_security_vpc describes which route table routes the traffic coming from the Security VPC,
  - from_spoke_vpc describes which route table routes the traffic coming from the Spoke (App1) VPC.

  Each of these entries can specify `create = true` which creates a new RT with a `name`.
  With `create = false` the pre-existing RT named `name` is used.
  EOF
}

# -- GWLB
variable "gwlbs" {
  description = <<-EOF
  Definition of Gateway Load Balancers. A map, where key is the GWLB name and value contains configuration described with with following properties:

  - `vpc` : VPC name hosting GWLB as defined in `security_vpc` property
  - `subnet_set`: name of a subnet set as defined in `security_vpc_subnets` property
  - `vmseries_pair_designator` : a suffix common to a name of a set of Firewalls as defined in `vmseries` variable, this is used to add proper FWs as target group attachments, see example for details.

  Example:
  ```
  # `vmseries` property is used to define 4 firewalls, 2 serving North-South traffic, 2 for East-West
  # name suffix, `ns` and `ew` respectively, indicates to which group this FW belongs to
  vmseries = {
    vmseries01ew = { ... firewall definition ... }
    vmseries02ew = { ... firewall definition ... }
    vmseries01ns = { ... firewall definition ... }
    vmseries02ns = { ... firewall definition ... }
  }
   
  gwlbs = {
    # the definition below describes a GWLB for the East-West traffic.
    # `vmseries_pair_designator` is used to indicate the correct firewalls that will be added as targets for this LB
    # it's simply done by comparing the `vmseries_pair_designator` with the firewall name's suffix
    # hence only FWs with names ending with `ew` will be used as targets by this GWLB
    "security-gwlb-ew" = {
      vpc                      = "vpc-ew"
      subnet_set               = "gwlb"
      vmseries_pair_designator = "ew"     # for 
    }
  }
  ```
  EOF
  type        = map(any)
}
variable "gwlb_endpoints" {
  description = <<-EOF
  A map defining GWLB endpoints. Key is the endpoint name, value contains configuration.
  Following properties are supported:

  - `gwlb` - a name of a GWLB to which this endpoint points to, see `gwlbs` property
  - `vpc` - vpc name, see `security_vpc` property
  - `subnet_set` - a set of subnets in which this endpoint will be created, see `security_vpc_subnets` property.

  Example
  ```
  {
    "gwlb-endpoint-ew" = {
      gwlb       = "security-gwlb-ew"
      vpc        = "vpc-ew"
      subnet_set = "gwlbe-ew"
    }
  }
  ```
  EOF
  type        = map(any)
}


# - VM-Series
variable "vmseries_version" {
  description = "A version of the PanOS image."
  type        = string
}
variable "ssh_key_name" {
  description = "A name of an SSH public key stored on AWS in the deployment region"
  type        = string
}
variable "vmseries" {
  description = <<-EOF
  A map defining all firewalls. Key is the FW name, value contains the actual definition.
  Following properties are supported:

  - `az` - availability zone in which this vm will be deployed
  - `vpc` - name of a VPC hosting this VM, see `security_vpc` property
  - `gwlb_endpoint` - a name of a GWLB endpoint to be automatically matched with a sub-interface during bootstrapping
  - `subinterface` - a name of a sub-interface that wil be paired with `gwlb_endpoint`
  - `interfaces` - a map defining all interfaces attached to this FW, see definition below
  - `bootstrap_options` - a map containing user data bootstrap options, key is the option name, value contains option's configuration, for available options see PanOS documentation.

  `interfaces` map has the following structure: key is the internal (terraform) interface name, value contains configuration. For more details on supported properties see the [vmseries module documentation](https://github.com/PaloAltoNetworks/terraform-aws-vmseries-modules/tree/main/modules/vmseries#input_interfaces).
  EOF
}
