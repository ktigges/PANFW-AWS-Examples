### VPC AND SUBNETS ###

module "vpcs" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/vpc"
  version = "0.4.0"

  for_each = var.vpcs

  name                    = "${var.name_prefix}${each.key}"
  cidr_block              = each.value.cidr
  security_groups         = each.value.security_groups
  create_internet_gateway = each.value.create_internet_gateway
  enable_dns_hostnames    = true
  enable_dns_support      = true
  instance_tenancy        = "default"
}


module "subnet_sets" {
  # The "set" here means we will repeat in each AZ an identical/similar subnet.
  # The notion of "set" is used a lot here, it extends to nat gateways, routes, routes' next hops,
  # gwlb endpoints and any other resources which would be a single point of failure when placed
  # in a single AZ.
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/subnet_set"
  version = "0.4.0"

  for_each = toset(distinct([for _, v in var.vpc_subnets : "${v.vpc}.${v.set}"]))

  name                = split(".", each.key)[1]
  vpc_id              = module.vpcs[split(".", each.key)[0]].id
  has_secondary_cidrs = module.vpcs[split(".", each.key)[0]].has_secondary_cidrs
  cidrs = { for k, v in var.vpc_subnets : k => v
  if v.set == split(".", each.key)[1] && v.vpc == split(".", each.key)[0] }
}



# # ### TGW AND ATTACHMENTS ###
module "transit_gateway" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/transit_gateway"
  version = "0.4.0"

  name         = "${var.name_prefix}${var.transit_gateway_name}"
  asn          = var.transit_gateway_asn
  route_tables = var.transit_gateway_route_tables
  create       = true
}

module "transit_gateway_attachment" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/transit_gateway_attachment"
  version = "0.4.0"

  for_each = var.transit_gateway_attachments

  name                        = "${var.name_prefix}${each.value.name}"
  vpc_id                      = module.vpcs[each.value.vpc].id
  subnets                     = module.subnet_sets["${each.value.vpc}.${each.value.subnet_set}"].subnets
  transit_gateway_route_table = module.transit_gateway.route_tables[each.value.route_table]
  propagate_routes_to = {
    to1 = module.transit_gateway.route_tables[each.value.propagate_to_rt].id
  }
}

locals {
  tgw_routes_flat = flatten([for k, v in var.transit_gateway_route_tables : [
    for _k, _v in v.routes : {
      rt_name   = k
      r_name    = _k
      cidr      = _v.cidr
      blackhole = _v.is_blackhole
      next_hop  = _v.next_hop_attachment
    }
  ]])

  tgw_routes = { for v in local.tgw_routes_flat : "${v.rt_name}-${v.r_name}" => {
    cidr      = v.cidr
    blackhole = v.blackhole
    next_hop  = v.next_hop
    rt_name   = v.rt_name
  } }
}

resource "aws_ec2_transit_gateway_route" "this" {
  for_each = local.tgw_routes

  transit_gateway_route_table_id = module.transit_gateway.route_tables[each.value.rt_name].id
  transit_gateway_attachment_id  = module.transit_gateway_attachment[each.value.next_hop].attachment.id
  destination_cidr_block         = each.value.cidr
  blackhole                      = each.value.blackhole
}


# ### GWLB AND GWLB ENDPOINTS ###

module "gwlb" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/gwlb"
  version = "0.4.0"

  for_each = var.gwlbs

  name    = "${var.name_prefix}${each.key}"
  vpc_id  = module.vpcs[each.value.vpc].id
  subnets = module.subnet_sets["${each.value.vpc}.${each.value.subnet_set}"].subnets

  # to prevent `cycle` errors this part was moved to a separate resource
  # see EOF -->  resource "aws_lb_target_group_attachment" "this" 
  target_instances = {}
}

module "gwlb_endpoint" {
  source  = "PaloAltoNetworks/vmseries-modules/aws//modules/gwlb_endpoint_set"
  version = "0.4.0"

  for_each = var.gwlb_endpoints

  name              = "${var.name_prefix}${each.key}"
  gwlb_service_name = module.gwlb[each.value.gwlb].endpoint_service.service_name
  vpc_id            = module.vpcs[each.value.vpc].id
  subnets           = module.subnet_sets["${each.value.vpc}.${each.value.subnet_set}"].subnets
}


# ### VMSERIES ###
module "vmseries" {
  for_each = var.vmseries
  source   = "PaloAltoNetworks/vmseries-modules/aws//modules/vmseries"
  version  = "0.4.0"

  name             = "${var.name_prefix}${each.key}"
  vmseries_version = var.vmseries_version
  interfaces = { for k, v in each.value.interfaces : k => {
    device_index       = v.device_index
    security_group_ids = [module.vpcs[each.value.vpc].security_group_ids[v.security_group_name]]
    source_dest_check  = v.source_dest_check
    subnet_id          = module.subnet_sets["${each.value.vpc}.${v.subnet_set}"].subnets[each.value.az].id
    create_public_ip   = v.create_public_ip
  } }

  bootstrap_options = join(";", flatten([
    [
      for k, v in each.value.bootstrap_options :
      "${k}=${v}" if k != "plugin-op-commands"
    ],
    [
      "plugin-op-commands=${format(
        "%s,%s",
        each.value.bootstrap_options["plugin-op-commands"],
        join(",", compact(concat(
          [
            for k, v in module.gwlb_endpoint[each.value.gwlb_endpoint].endpoints :
            format("aws-gwlb-associate-vpce:%s@%s", v.id, each.value.subinterface)
          ]
        )))
        )
      }"
    ]
  ]))

  ssh_key_name = var.ssh_key_name
  tags         = var.global_tags
}

locals {
  gwlb_target_attachments = flatten([
    for k, v in var.gwlbs : [
      for _k, _v in module.vmseries : {
        gwlb             = k
        target_group_arn = module.gwlb[k].target_group.arn
        vmseries         = _k
        instance_id      = _v.instance.id
      } if substr(_k, -2, -1) == v.vmseries_pair_designator
    ]
  ])
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = { for v in local.gwlb_target_attachments : "${v.gwlb}-${v.vmseries}" => {
    target_group_arn = v.target_group_arn
    instance_id      = v.instance_id
  } }

  target_group_arn = each.value.target_group_arn
  target_id        = each.value.instance_id
}


# ### VPC ROUTES ###
module "vpc_routes" {
  for_each = { for v in var.vpc_routes : "${v.vpc}-${v.set}-${v.cidr}" => v }
  source   = "PaloAltoNetworks/vmseries-modules/aws//modules/vpc_route"
  version  = "0.4.0"

  route_table_ids = module.subnet_sets["${each.value.vpc}.${each.value.set}"].unique_route_table_ids
  to_cidr         = each.value.cidr
  next_hop_set = each.value.type == "tgw" ? module.transit_gateway_attachment[each.value.designator].next_hop_set : (
    each.value.type == "gwlb" ? module.gwlb_endpoint[each.value.designator].next_hop_set : module.vpcs[each.value.vpc].igw_as_next_hop_set
  )
}
