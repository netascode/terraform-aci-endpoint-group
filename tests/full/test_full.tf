terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    aci = {
      source  = "netascode/aci"
      version = ">=0.2.0"
    }
  }
}

resource "aci_rest" "fvTenant" {
  dn         = "uni/tn-TF"
  class_name = "fvTenant"
}

resource "aci_rest" "fvAp" {
  dn         = "${aci_rest.fvTenant.id}/ap-AP1"
  class_name = "fvAp"
}

module "main" {
  source = "../.."

  tenant                      = aci_rest.fvTenant.content.name
  application_profile         = aci_rest.fvAp.content.name
  name                        = "EPG1"
  alias                       = "EPG1-ALIAS"
  description                 = "My Description"
  flood_in_encap              = false
  intra_epg_isolation         = true
  preferred_group             = true
  bridge_domain               = "BD1"
  contract_consumers          = ["CON1"]
  contract_providers          = ["CON1"]
  contract_imported_consumers = ["I_CON1"]
  physical_domains            = ["PHY1"]
  subnets = [{
    description        = "Subnet Description"
    ip                 = "1.1.1.1/24"
    public             = true
    shared             = true
    igmp_querier       = true
    nd_ra_prefix       = true
    no_default_gateway = false
  }]
  vmware_vmm_domains = [{
    name                 = "VMW1"
    u_segmentation       = true
    delimiter            = "|"
    primary_vlan         = 123
    secondary_vlan       = 124
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
}

data "aci_rest" "fvAEPg" {
  dn = "${aci_rest.fvAp.id}/epg-${module.main.name}"

  depends_on = [module.main]
}

resource "test_assertions" "fvAEPg" {
  component = "fvAEPg"

  equal "name" {
    description = "name"
    got         = data.aci_rest.fvAEPg.content.name
    want        = module.main.name
  }

  equal "nameAlias" {
    description = "nameAlias"
    got         = data.aci_rest.fvAEPg.content.nameAlias
    want        = "EPG1-ALIAS"
  }

  equal "descr" {
    description = "descr"
    got         = data.aci_rest.fvAEPg.content.descr
    want        = "My Description"
  }

  equal "floodOnEncap" {
    description = "floodOnEncap"
    got         = data.aci_rest.fvAEPg.content.floodOnEncap
    want        = "disabled"
  }

  equal "pcEnfPref" {
    description = "pcEnfPref"
    got         = data.aci_rest.fvAEPg.content.pcEnfPref
    want        = "enforced"
  }

  equal "prefGrMemb" {
    description = "prefGrMemb"
    got         = data.aci_rest.fvAEPg.content.prefGrMemb
    want        = "include"
  }
}

data "aci_rest" "fvRsBd" {
  dn = "${data.aci_rest.fvAEPg.id}/rsbd"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsBd" {
  component = "fvRsBd"

  equal "tnFvBDName" {
    description = "tnFvBDName"
    got         = data.aci_rest.fvRsBd.content.tnFvBDName
    want        = "BD1"
  }
}

data "aci_rest" "fvSubnet" {
  dn = "${data.aci_rest.fvAEPg.id}/subnet-[1.1.1.1/24]"

  depends_on = [module.main]
}

resource "test_assertions" "fvSubnet" {
  component = "fvSubnet"

  equal "ip" {
    description = "ip"
    got         = data.aci_rest.fvSubnet.content.ip
    want        = "1.1.1.1/24"
  }

  equal "descr" {
    description = "descr"
    got         = data.aci_rest.fvSubnet.content.descr
    want        = "Subnet Description"
  }

  equal "ctrl" {
    description = "ctrl"
    got         = data.aci_rest.fvSubnet.content.ctrl
    want        = "nd,querier"
  }

  equal "scope" {
    description = "scope"
    got         = data.aci_rest.fvSubnet.content.scope
    want        = "public,shared"
  }
}

data "aci_rest" "fvRsCons" {
  dn = "${data.aci_rest.fvAEPg.id}/rscons-CON1"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsCons" {
  component = "fvRsCons"

  equal "tnVzBrCPName" {
    description = "tnVzBrCPName"
    got         = data.aci_rest.fvRsCons.content.tnVzBrCPName
    want        = "CON1"
  }
}

data "aci_rest" "fvRsProv" {
  dn = "${data.aci_rest.fvAEPg.id}/rsprov-CON1"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsProv" {
  component = "fvRsProv"

  equal "tnVzBrCPName" {
    description = "tnVzBrCPName"
    got         = data.aci_rest.fvRsProv.content.tnVzBrCPName
    want        = "CON1"
  }
}

data "aci_rest" "fvRsConsIf" {
  dn = "${data.aci_rest.fvAEPg.id}/rsconsIf-I_CON1"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsConsIf" {
  component = "fvRsConsIf"

  equal "tnVzCPIfName" {
    description = "tnVzCPIfName"
    got         = data.aci_rest.fvRsConsIf.content.tnVzCPIfName
    want        = "I_CON1"
  }
}

data "aci_rest" "fvRsDomAtt" {
  dn = "${data.aci_rest.fvAEPg.id}/rsdomAtt-[uni/phys-PHY1]"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsDomAtt" {
  component = "fvRsDomAtt"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest.fvRsDomAtt.content.tDn
    want        = "uni/phys-PHY1"
  }
}

data "aci_rest" "fvRsPathAtt" {
  dn = "${data.aci_rest.fvAEPg.id}/rspathAtt-[topology/pod-1/paths-101/pathep-[eth1/10]]"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsPathAtt" {
  component = "fvRsPathAtt"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest.fvRsPathAtt.content.tDn
    want        = "topology/pod-1/paths-101/pathep-[eth1/10]"
  }

  equal "encap" {
    description = "encap"
    got         = data.aci_rest.fvRsPathAtt.content.encap
    want        = "vlan-123"
  }

  equal "mode" {
    description = "mode"
    got         = data.aci_rest.fvRsPathAtt.content.mode
    want        = "untagged"
  }

  equal "instrImedcy" {
    description = "instrImedcy"
    got         = data.aci_rest.fvRsPathAtt.content.instrImedcy
    want        = "lazy"
  }
}

data "aci_rest" "fvStCEp" {
  dn = "${data.aci_rest.fvAEPg.id}/stcep-11:11:11:11:11:11-type-silent-host"

  depends_on = [module.main]
}

resource "test_assertions" "fvStCEp" {
  component = "fvStCEp"

  equal "encap" {
    description = "encap"
    got         = data.aci_rest.fvStCEp.content.encap
    want        = "vlan-123"
  }

  equal "id" {
    description = "id"
    got         = data.aci_rest.fvStCEp.content.id
    want        = "0"
  }

  equal "ip" {
    description = "ip"
    got         = data.aci_rest.fvStCEp.content.ip
    want        = "1.1.1.10"
  }

  equal "mac" {
    description = "mac"
    got         = data.aci_rest.fvStCEp.content.mac
    want        = "11:11:11:11:11:11"
  }

  equal "name" {
    description = "name"
    got         = data.aci_rest.fvStCEp.content.name
    want        = "EP1"
  }

  equal "nameAlias" {
    description = "nameAlias"
    got         = data.aci_rest.fvStCEp.content.nameAlias
    want        = "EP1-ALIAS"
  }

  equal "type" {
    description = "type"
    got         = data.aci_rest.fvStCEp.content.type
    want        = "silent-host"
  }
}

data "aci_rest" "fvStIp" {
  dn = "${data.aci_rest.fvStCEp.id}/ip-[1.1.1.11]"

  depends_on = [module.main]
}

resource "test_assertions" "fvStIp" {
  component = "fvStIp"

  equal "addr" {
    description = "addr"
    got         = data.aci_rest.fvStIp.content.addr
    want        = "1.1.1.11"
  }
}

data "aci_rest" "fvRsStCEpToPathEp" {
  dn = "${data.aci_rest.fvStCEp.id}/rsstCEpToPathEp-[topology/pod-1/protpaths-101-102/pathep-[VPC1]]"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsStCEpToPathEp" {
  component = "fvRsStCEpToPathEp"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest.fvRsStCEpToPathEp.content.tDn
    want        = "topology/pod-1/protpaths-101-102/pathep-[VPC1]"
  }
}

data "aci_rest" "fvRsDomAtt_vmm" {
  dn = "${data.aci_rest.fvAEPg.id}/rsdomAtt-[uni/vmmp-VMware/dom-VMW1]"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsDomAtt_vmm" {
  component = "fvRsDomAtt_vmm"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest.fvRsDomAtt_vmm.content.tDn
    want        = "uni/vmmp-VMware/dom-VMW1"
  }

  equal "classPref" {
    description = "classPref"
    got         = data.aci_rest.fvRsDomAtt_vmm.content.classPref
    want        = "useg"
  }

  equal "delimiter" {
    description = "delimiter"
    got         = data.aci_rest.fvRsDomAtt_vmm.content.delimiter
    want        = "|"
  }

  equal "encap" {
    description = "encap"
    got         = data.aci_rest.fvRsDomAtt_vmm.content.encap
    want        = "vlan-124"
  }

  equal "encapMode" {
    description = "encapMode"
    got         = data.aci_rest.fvRsDomAtt_vmm.content.encapMode
    want        = "auto"
  }

  equal "primaryEncap" {
    description = "primaryEncap"
    got         = data.aci_rest.fvRsDomAtt_vmm.content.primaryEncap
    want        = "vlan-123"
  }

  equal "netflowPref" {
    description = "netflowPref"
    got         = data.aci_rest.fvRsDomAtt_vmm.content.netflowPref
    want        = "disabled"
  }

  equal "instrImedcy" {
    description = "instrImedcy"
    got         = data.aci_rest.fvRsDomAtt_vmm.content.instrImedcy
    want        = "lazy"
  }

  equal "resImedcy" {
    description = "resImedcy"
    got         = data.aci_rest.fvRsDomAtt_vmm.content.resImedcy
    want        = "lazy"
  }

  equal "switchingMode" {
    description = "switchingMode"
    got         = data.aci_rest.fvRsDomAtt_vmm.content.switchingMode
    want        = "native"
  }

  equal "customEpgName" {
    description = "customEpgName"
    got         = data.aci_rest.fvRsDomAtt_vmm.content.customEpgName
    want        = "custom-epg-name"
  }
}

data "aci_rest" "vmmSecP" {
  dn = "${data.aci_rest.fvRsDomAtt_vmm.id}/sec"

  depends_on = [module.main]
}

resource "test_assertions" "vmmSecP" {
  component = "vmmSecP"

  equal "allowPromiscuous" {
    description = "allowPromiscuous"
    got         = data.aci_rest.vmmSecP.content.allowPromiscuous
    want        = "accept"
  }

  equal "forgedTransmits" {
    description = "forgedTransmits"
    got         = data.aci_rest.vmmSecP.content.forgedTransmits
    want        = "accept"
  }

  equal "macChanges" {
    description = "macChanges"
    got         = data.aci_rest.vmmSecP.content.macChanges
    want        = "accept"
  }
}
