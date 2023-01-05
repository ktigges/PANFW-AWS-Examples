# NGFW module

## Purpose

Terraform code is used to deploy Next Generation Firewalls and related resources.

## Usage

All Firewall VMs will be set up with an SSH key. In order to use an existing AWS Key Pair, fill out the `ssh_key_name` property with existing Key Pair name.

A thing worth noticing is the Gateway Load Balancer (GWLB) configuration. AWS recommends that GWLB is set up in every Availability Zone available in a particular region. Prepared code is set up for `sa-east-1` which has (at the time of writing) zones from `a` to `c`.

Please remebember to define name of existing transit gateway by changing value of `transit_gateway_name` variable.

In order to deploy code, run the following commands:

```
terraform init
terraform apply
```

To cleanup the infrastructure run:

```
terraform destroy
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0, < 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gwlb"></a> [gwlb](#module\_gwlb) | PaloAltoNetworks/vmseries-modules/aws//modules/gwlb | 0.4.0 |
| <a name="module_gwlb_endpoint"></a> [gwlb\_endpoint](#module\_gwlb\_endpoint) | PaloAltoNetworks/vmseries-modules/aws//modules/gwlb_endpoint_set | 0.4.0 |
| <a name="module_subnet_sets"></a> [subnet\_sets](#module\_subnet\_sets) | PaloAltoNetworks/vmseries-modules/aws//modules/subnet_set | 0.4.0 |
| <a name="module_transit_gateway"></a> [transit\_gateway](#module\_transit\_gateway) | PaloAltoNetworks/vmseries-modules/aws//modules/transit_gateway | 0.4.0 |
| <a name="module_transit_gateway_attachment"></a> [transit\_gateway\_attachment](#module\_transit\_gateway\_attachment) | PaloAltoNetworks/vmseries-modules/aws//modules/transit_gateway_attachment | 0.4.0 |
| <a name="module_vmseries"></a> [vmseries](#module\_vmseries) | PaloAltoNetworks/vmseries-modules/aws//modules/vmseries | 0.4.0 |
| <a name="module_vpc_routes"></a> [vpc\_routes](#module\_vpc\_routes) | PaloAltoNetworks/vmseries-modules/aws//modules/vpc_route | 0.4.0 |
| <a name="module_vpcs"></a> [vpcs](#module\_vpcs) | PaloAltoNetworks/vmseries-modules/aws//modules/vpc | 0.4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_global_tags"></a> [global\_tags](#input\_global\_tags) | A map of tags that will be added to all resources. | `map(any)` | `{}` | no |
| <a name="input_gwlb_endpoints"></a> [gwlb\_endpoints](#input\_gwlb\_endpoints) | A map defining GWLB endpoints. Key is the endpoint name, value contains configuration.<br>Following properties are supported:<br><br>- `gwlb` - a name of a GWLB to which this endpoint points to, see `gwlbs` property<br>- `vpc` - vpc name, see `security_vpc` property<br>- `subnet_set` - a set of subnets in which this endpoint will be created, see `security_vpc_subnets` property.<br><br>Example<pre>{<br>  "gwlb-endpoint-ew" = {<br>    gwlb       = "security-gwlb-ew"<br>    vpc        = "vpc-ew"<br>    subnet_set = "gwlbe-ew"<br>  }<br>}</pre> | `map(any)` | n/a | yes |
| <a name="input_gwlbs"></a> [gwlbs](#input\_gwlbs) | Definition of Gateway Load Balancers. A map, where key is the GWLB name and value contains configuration described with with following properties:<br><br>- `vpc` : VPC name hosting GWLB as defined in `security_vpc` property<br>- `subnet_set`: name of a subnet set as defined in `security_vpc_subnets` property<br>- `vmseries_pair_designator` : a suffix common to a name of a set of Firewalls as defined in `vmseries` variable, this is used to add proper FWs as target group attachments, see example for details.<br><br>Example:<pre># `vmseries` property is used to define 4 firewalls, 2 serving North-South traffic, 2 for East-West<br># name suffix, `ns` and `ew` respectively, indicates to which group this FW belongs to<br>vmseries = {<br>  vmseries01ew = { ... firewall definition ... }<br>  vmseries02ew = { ... firewall definition ... }<br>  vmseries01ns = { ... firewall definition ... }<br>  vmseries02ns = { ... firewall definition ... }<br>}<br>   <br>gwlbs = {<br>  # the definition below describes a GWLB for the East-West traffic.<br>  # `vmseries_pair_designator` is used to indicate the correct firewalls that will be added as targets for this LB<br>  # it's simply done by comparing the `vmseries_pair_designator` with the firewall name's suffix<br>  # hence only FWs with names ending with `ew` will be used as targets by this GWLB<br>  "security-gwlb-ew" = {<br>    vpc                      = "vpc-ew"<br>    subnet_set               = "gwlb"<br>    vmseries_pair_designator = "ew"     # for <br>  }<br>}</pre> | `map(any)` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | A prefix that will be added to all resource names. | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | A region used for deployment. | `string` | n/a | yes |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | A name of an SSH public key stored on AWS in the deployment region | `string` | n/a | yes |
| <a name="input_transit_gateway_asn"></a> [transit\_gateway\_asn](#input\_transit\_gateway\_asn) | Private Autonomous System Number (ASN) of the Transit Gateway for the Amazon side of a BGP session.<br>The range is 64512 to 65534 for 16-bit ASNs and 4200000000 to 4294967294 for 32-bit ASNs. | `number` | n/a | yes |
| <a name="input_transit_gateway_attachments"></a> [transit\_gateway\_attachments](#input\_transit\_gateway\_attachments) | Name of the TGW attachments.<br>Example:<pre>{<br>  "security_ew" = {<br>    name            = "transit_gateway_attachment_ew"<br>    subnet_set      = "tgw"<br>    vpc             = "vpc-ew"<br>    route_table     = "from_security"<br>    propagate_to_rt = "from_spoke"<br>  }<br>}</pre> | `map(any)` | n/a | yes |
| <a name="input_transit_gateway_name"></a> [transit\_gateway\_name](#input\_transit\_gateway\_name) | The name tag of the created Transit Gateway. | `string` | n/a | yes |
| <a name="input_transit_gateway_route_tables"></a> [transit\_gateway\_route\_tables](#input\_transit\_gateway\_route\_tables) | Complex input with the Route Tables of the Transit Gateway. Example:<pre>{<br>  "from_security_vpc" = {<br>    create = true<br>    name   = "myrt1"<br>    routes = {<br>      route_name = {<br>        cidr = "1.2.2.0/24"<br>        is_blackhole = false<br>      }<br>    }<br>  }<br>  "from_spoke_vpc" = {<br>    create = true<br>    name   = "myrt2"<br>    routes = {}<br>  }<br>}</pre>Two keys are required:<br><br>- from\_security\_vpc describes which route table routes the traffic coming from the Security VPC,<br>- from\_spoke\_vpc describes which route table routes the traffic coming from the Spoke (App1) VPC.<br><br>Each of these entries can specify `create = true` which creates a new RT with a `name`.<br>With `create = false` the pre-existing RT named `name` is used. | `any` | n/a | yes |
| <a name="input_vmseries"></a> [vmseries](#input\_vmseries) | A map defining all firewalls. Key is the FW name, value contains the actual definition.<br>Following properties are supported:<br><br>- `az` - availability zone in which this vm will be deployed<br>- `vpc` - name of a VPC hosting this VM, see `security_vpc` property<br>- `gwlb_endpoint` - a name of a GWLB endpoint to be automatically matched with a sub-interface during bootstrapping<br>- `subinterface` - a name of a sub-interface that wil be paired with `gwlb_endpoint`<br>- `interfaces` - a map defining all interfaces attached to this FW, see definition below<br>- `bootstrap_options` - a map containing user data bootstrap options, key is the option name, value contains option's configuration, for available options see PanOS documentation.<br><br>`interfaces` map has the following structure: key is the internal (terraform) interface name, value contains configuration. For more details on supported properties see the [vmseries module documentation](https://github.com/PaloAltoNetworks/terraform-aws-vmseries-modules/tree/main/modules/vmseries#input_interfaces). | `any` | n/a | yes |
| <a name="input_vmseries_version"></a> [vmseries\_version](#input\_vmseries\_version) | A version of the PanOS image. | `string` | n/a | yes |
| <a name="input_vpc_routes"></a> [vpc\_routes](#input\_vpc\_routes) | A list of routes for all VPC, each list element is a map. Three combinations are available, each for a different next hop resource.<br><br>IGW Example:<pre>{ <br>  vpc  = "vpc-ns"       # VPC key name like in `security_vpc` variable<br>  set  = "mgmt"       # Subnet set name like in the `security_vpc_subnets` variable<br>  cidr = "0.0.0.0/0"    # Destination cidr<br>  type = "igw"          # Next how resource type, in this case an IGW<br>}</pre>TGW Example:<pre>{ <br>  vpc         = "vpc-ns"       # VPC key name like in `security_vpc` variable<br>  set         = "private"      # Subnet set name like in the `security_vpc_subnets` variable<br>  cidr        = "0.0.0.0/0"    # Destination cidr<br>  type        = "tgw"          # Next how resource type, in this case a TGW endpoint<br>  designator  = "sec_ns"       # TGW attachment key name like in the `transit_gateway_attachments` variable<br>}</pre>GWLB Example:<pre>{ <br>  vpc         = "vpc-ns"            # VPC key name like in `security_vpc` variable<br>  set         = "private"           # Subnet set name like in the `security_vpc_subnets` variable<br>  cidr        = "10.0.0.0/8"        # Destination cidr<br>  type        = "gwlb"              # Next how resource type, in this case an IGW<br>  designator  = "gwlb-endpoint-ns"  # GWLB endpoint key name like in the `gwlb_endpoints` variable<br>}</pre> | `any` | n/a | yes |
| <a name="input_vpc_subnets"></a> [vpc\_subnets](#input\_vpc\_subnets) | Subnets definition.<br><br>Following format is supported:<pre>{<br>  "x.x.x.x/y" = {<br>    az = "availability zone name"<br>    set = "subnet set name as referenced by main.tf"<br>    vpc = "vpc name - key in the `security_vpc` map"<br>  }<br>}</pre>Example:<pre>{<br>  "10.100.0.0/28"  = { az = "us-east-1a", set = "mgmt", vpc = "vpc-ew" }<br>}</pre> | `map(any)` | n/a | yes |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | VPC definition. This is a map where key is the VPC name and value has the following properties:<br><br>- `cidr` : a VPC address space<br>- `create_internet_gateway` : bool, controls if an IGW will be created in this particular VPC<br>- `security_groups` : a map of security groups hosted in this VPC, for structure see below.<br><br>In the security group definition key is used only for internal indexing of resources. Value contains the following properties:<br><br>- `name` : the actual name of the Security Group<br>- `rules` : a map of security rules.<br><br>Security rules have again the map structure, where key is the rule name and value has the following properties:<br><br>- `description` : a rule description<br>- `type` : rule type, either `ingress` or `egress`<br>- `from_port` : port that starts the port range defined by this rules<br>- `to_port` : port that ends the port range, when set to the same value as `from_port` this makes a rule serving a single port; set both values to `0` to create all-ports rule<br>- `protocol` : a protocol used by this rule, see AWS documentation for all possible values; the most common ones are: `tcp`, `udp`, `icmp` or `-1` for all<br>- `cidr_blocks` : a list of cidr served by this rule.<br><br>Example:<pre>{<br>  "vpc-test" = {<br>    cidr                    = "10.106.0.0/23"<br>    create_internet_gateway = true<br>    security_groups = {<br>      web_app = {<br>        name = "web_application"<br>        rules = {<br>          all_outbound = {<br>            description = "Permit All traffic outbound"<br>            type        = "egress", from_port = "0", to_port = "0", protocol = "-1"<br>            cidr_blocks = ["0.0.0.0/0"]<br>          }<br>          http = {<br>            description = "Permit HTTP to test app"<br>            type        = "ingress", from_port = "80", to_port = "80", protocol = "tcp"<br>            cidr_blocks = ["10.106.0.32/28", "10.106.1.32/28"]<br>          }<br>        }<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_gwlb_service_name"></a> [security\_gwlb\_service\_name](#output\_security\_gwlb\_service\_name) | The AWS Service Name of the created GWLB, which is suitable to use for subsequent VPC Endpoints. |
| <a name="output_vmseries_public_ips_ew"></a> [vmseries\_public\_ips\_ew](#output\_vmseries\_public\_ips\_ew) | Map of public IPs created within `vmseries` module instances. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
