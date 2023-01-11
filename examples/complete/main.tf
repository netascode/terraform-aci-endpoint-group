module "aci_endpoint_group" {
  source  = "netascode/endpoint-group/aci"
  version = ">= 0.2.2"

  tenant                      = "ABC"
  application_profile         = "AP1"
  name                        = "EPG1"
  alias                       = "EPG1-ALIAS"
  description                 = "My Description"
  flood_in_encap              = false
  intra_epg_isolation         = true
  preferred_group             = true
  qos_class                   = "level1"
  custom_qos_policy           = "CQP1"
  bridge_domain               = "BD1"
  contract_consumers          = ["CON1"]
  contract_providers          = ["CON1"]
  contract_imported_consumers = ["I_CON1"]
  contract_intra_epgs         = ["CON1"]
  physical_domains            = ["PHY1"]
  subnets = [{
    description        = "Subnet Description"
    ip                 = "1.1.1.1/24"
    public             = true
    shared             = true
    igmp_querier       = true
    nd_ra_prefix       = true
    no_default_gateway = false
    },
    {
      ip                 = "2.2.2.2/32"
      no_default_gateway = true
      next_hop_ip        = "192.168.1.1"
    },
    {
      ip                 = "3.3.3.3/32"
      no_default_gateway = true
      anycast_mac        = "00:00:00:01:02:03"
    },
    {
      ip                 = "4.4.4.4/32"
      no_default_gateway = true
      nlb_group          = "230.1.1.1"
      nlb_mode           = "mode-mcast-igmp"
    }
  ]
  vmware_vmm_domains = [{
    name                 = "VMW1"
    u_segmentation       = true
    delimiter            = ":"
    vlan                 = 123
    netflow              = false
    deployment_immediacy = "lazy"
    resolution_immediacy = "lazy"
    allow_promiscuous    = true
    forged_transmits     = true
    mac_changes          = true
    custom_epg_name      = "custom-epg-name"
  }]
  static_ports = [{
    node_id              = 101
    vlan                 = 123
    pod_id               = 1
    port                 = 10
    sub_port             = 1
    module               = 1
    deployment_immediacy = "lazy"
    mode                 = "untagged"
    },
    {
      node_id  = 101
      node2_id = 102
      fex_id   = 151
      fex2_id  = 152
      vlan     = 2
      channel  = "ipg_vpc_test"
    },
    {
      node_id = 101
      fex_id  = 151
      vlan    = 2
      channel = "ipg_regular-po_test"
    },
    {
      node_id = 101
      fex_id  = 151
      port    = 1
      vlan    = 2
  }]
  static_endpoints = [{
    name           = "EP1"
    alias          = "EP1-ALIAS"
    mac            = "11:11:11:11:11:11"
    ip             = "1.1.1.10"
    type           = "silent-host"
    node_id        = 101
    node2_id       = 102
    vlan           = 123
    pod_id         = 1
    channel        = "VPC1"
    additional_ips = ["1.1.1.11"]
  }]
  l4l7_virtual_ips = [
    {
      ip          = "1.2.3.4"
      description = "My Virtual IP"
    }
  ]
  l4l7_address_pools = [
    {
      name            = "POOL1"
      gateway_address = "1.1.1.1/24"
      from            = "1.1.1.10"
      to              = "1.1.1.100"
    }
  ]
}
