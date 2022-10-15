terraform {
  required_version = ">= 1.3.0"

  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    aci = {
      source  = "CiscoDevNet/aci"
      version = ">=2.0.0"
    }
  }
}

resource "aci_rest_managed" "fvTenant" {
  dn         = "uni/tn-TF"
  class_name = "fvTenant"
}

resource "aci_rest_managed" "fvAp" {
  dn         = "${aci_rest_managed.fvTenant.id}/ap-AP1"
  class_name = "fvAp"
}

module "main" {
  source = "../.."

  tenant                      = aci_rest_managed.fvTenant.content.name
  application_profile         = aci_rest_managed.fvAp.content.name
  name                        = "EPG1"
  alias                       = "EPG1-ALIAS"
  description                 = "My Description"
  flood_in_encap              = false
  intra_epg_isolation         = true
  preferred_group             = true
  custom_qos_policy           = "CQP1"
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
}

data "aci_rest_managed" "fvAEPg" {
  dn = "${aci_rest_managed.fvAp.id}/epg-${module.main.name}"

  depends_on = [module.main]
}

resource "test_assertions" "fvAEPg" {
  component = "fvAEPg"

  equal "name" {
    description = "name"
    got         = data.aci_rest_managed.fvAEPg.content.name
    want        = module.main.name
  }

  equal "nameAlias" {
    description = "nameAlias"
    got         = data.aci_rest_managed.fvAEPg.content.nameAlias
    want        = "EPG1-ALIAS"
  }

  equal "descr" {
    description = "descr"
    got         = data.aci_rest_managed.fvAEPg.content.descr
    want        = "My Description"
  }

  equal "floodOnEncap" {
    description = "floodOnEncap"
    got         = data.aci_rest_managed.fvAEPg.content.floodOnEncap
    want        = "disabled"
  }

  equal "pcEnfPref" {
    description = "pcEnfPref"
    got         = data.aci_rest_managed.fvAEPg.content.pcEnfPref
    want        = "enforced"
  }

  equal "prefGrMemb" {
    description = "prefGrMemb"
    got         = data.aci_rest_managed.fvAEPg.content.prefGrMemb
    want        = "include"
  }
}

data "aci_rest_managed" "fvRsCustQosPol" {
  dn = "${data.aci_rest_managed.fvAEPg.id}/rscustQosPol"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsCustQosPol" {
  component = "fvRsCustQosPol"

  equal "tnQosCustomPolName" {
    description = "tnQosCustomPolName"
    got         = data.aci_rest_managed.fvRsCustQosPol.content.tnQosCustomPolName
    want        = "CQP1"
  }
}

data "aci_rest_managed" "fvRsBd" {
  dn = "${data.aci_rest_managed.fvAEPg.id}/rsbd"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsBd" {
  component = "fvRsBd"

  equal "tnFvBDName" {
    description = "tnFvBDName"
    got         = data.aci_rest_managed.fvRsBd.content.tnFvBDName
    want        = "BD1"
  }
}

data "aci_rest_managed" "fvSubnet" {
  dn = "${data.aci_rest_managed.fvAEPg.id}/subnet-[1.1.1.1/24]"

  depends_on = [module.main]
}

resource "test_assertions" "fvSubnet" {
  component = "fvSubnet"

  equal "ip" {
    description = "ip"
    got         = data.aci_rest_managed.fvSubnet.content.ip
    want        = "1.1.1.1/24"
  }

  equal "descr" {
    description = "descr"
    got         = data.aci_rest_managed.fvSubnet.content.descr
    want        = "Subnet Description"
  }

  equal "ctrl" {
    description = "ctrl"
    got         = data.aci_rest_managed.fvSubnet.content.ctrl
    want        = "nd,querier"
  }

  equal "scope" {
    description = "scope"
    got         = data.aci_rest_managed.fvSubnet.content.scope
    want        = "public,shared"
  }
}

data "aci_rest_managed" "fvRsCons" {
  dn = "${data.aci_rest_managed.fvAEPg.id}/rscons-CON1"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsCons" {
  component = "fvRsCons"

  equal "tnVzBrCPName" {
    description = "tnVzBrCPName"
    got         = data.aci_rest_managed.fvRsCons.content.tnVzBrCPName
    want        = "CON1"
  }
}

data "aci_rest_managed" "fvRsProv" {
  dn = "${data.aci_rest_managed.fvAEPg.id}/rsprov-CON1"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsProv" {
  component = "fvRsProv"

  equal "tnVzBrCPName" {
    description = "tnVzBrCPName"
    got         = data.aci_rest_managed.fvRsProv.content.tnVzBrCPName
    want        = "CON1"
  }
}

data "aci_rest_managed" "fvRsConsIf" {
  dn = "${data.aci_rest_managed.fvAEPg.id}/rsconsIf-I_CON1"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsConsIf" {
  component = "fvRsConsIf"

  equal "tnVzCPIfName" {
    description = "tnVzCPIfName"
    got         = data.aci_rest_managed.fvRsConsIf.content.tnVzCPIfName
    want        = "I_CON1"
  }
}

data "aci_rest_managed" "fvRsDomAtt" {
  dn = "${data.aci_rest_managed.fvAEPg.id}/rsdomAtt-[uni/phys-PHY1]"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsDomAtt" {
  component = "fvRsDomAtt"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest_managed.fvRsDomAtt.content.tDn
    want        = "uni/phys-PHY1"
  }
}

data "aci_rest_managed" "fvRsPathAtt" {
  dn = "${data.aci_rest_managed.fvAEPg.id}/rspathAtt-[topology/pod-1/paths-101/pathep-[eth1/10/1]]"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsPathAtt" {
  component = "fvRsPathAtt"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest_managed.fvRsPathAtt.content.tDn
    want        = "topology/pod-1/paths-101/pathep-[eth1/10/1]"
  }

  equal "encap" {
    description = "encap"
    got         = data.aci_rest_managed.fvRsPathAtt.content.encap
    want        = "vlan-123"
  }

  equal "mode" {
    description = "mode"
    got         = data.aci_rest_managed.fvRsPathAtt.content.mode
    want        = "untagged"
  }

  equal "instrImedcy" {
    description = "instrImedcy"
    got         = data.aci_rest_managed.fvRsPathAtt.content.instrImedcy
    want        = "lazy"
  }
}

data "aci_rest_managed" "fvStCEp" {
  dn = "${data.aci_rest_managed.fvAEPg.id}/stcep-11:11:11:11:11:11-type-silent-host"

  depends_on = [module.main]
}

resource "test_assertions" "fvStCEp" {
  component = "fvStCEp"

  equal "encap" {
    description = "encap"
    got         = data.aci_rest_managed.fvStCEp.content.encap
    want        = "vlan-123"
  }

  equal "id" {
    description = "id"
    got         = data.aci_rest_managed.fvStCEp.content.id
    want        = "0"
  }

  equal "ip" {
    description = "ip"
    got         = data.aci_rest_managed.fvStCEp.content.ip
    want        = "1.1.1.10"
  }

  equal "mac" {
    description = "mac"
    got         = data.aci_rest_managed.fvStCEp.content.mac
    want        = "11:11:11:11:11:11"
  }

  equal "name" {
    description = "name"
    got         = data.aci_rest_managed.fvStCEp.content.name
    want        = "EP1"
  }

  equal "nameAlias" {
    description = "nameAlias"
    got         = data.aci_rest_managed.fvStCEp.content.nameAlias
    want        = "EP1-ALIAS"
  }

  equal "type" {
    description = "type"
    got         = data.aci_rest_managed.fvStCEp.content.type
    want        = "silent-host"
  }
}

data "aci_rest_managed" "fvStIp" {
  dn = "${data.aci_rest_managed.fvStCEp.id}/ip-[1.1.1.11]"

  depends_on = [module.main]
}

resource "test_assertions" "fvStIp" {
  component = "fvStIp"

  equal "addr" {
    description = "addr"
    got         = data.aci_rest_managed.fvStIp.content.addr
    want        = "1.1.1.11"
  }
}

data "aci_rest_managed" "fvRsStCEpToPathEp" {
  dn = "${data.aci_rest_managed.fvStCEp.id}/rsstCEpToPathEp-[topology/pod-1/protpaths-101-102/pathep-[VPC1]]"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsStCEpToPathEp" {
  component = "fvRsStCEpToPathEp"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest_managed.fvRsStCEpToPathEp.content.tDn
    want        = "topology/pod-1/protpaths-101-102/pathep-[VPC1]"
  }
}

data "aci_rest_managed" "fvRsDomAtt_vmm" {
  dn = "${data.aci_rest_managed.fvAEPg.id}/rsdomAtt-[uni/vmmp-VMware/dom-VMW1]"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsDomAtt_vmm" {
  component = "fvRsDomAtt_vmm"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest_managed.fvRsDomAtt_vmm.content.tDn
    want        = "uni/vmmp-VMware/dom-VMW1"
  }

  equal "classPref" {
    description = "classPref"
    got         = data.aci_rest_managed.fvRsDomAtt_vmm.content.classPref
    want        = "useg"
  }

  equal "delimiter" {
    description = "delimiter"
    got         = data.aci_rest_managed.fvRsDomAtt_vmm.content.delimiter
    want        = "|"
  }

  equal "encap" {
    description = "encap"
    got         = data.aci_rest_managed.fvRsDomAtt_vmm.content.encap
    want        = "vlan-124"
  }

  equal "encapMode" {
    description = "encapMode"
    got         = data.aci_rest_managed.fvRsDomAtt_vmm.content.encapMode
    want        = "auto"
  }

  equal "primaryEncap" {
    description = "primaryEncap"
    got         = data.aci_rest_managed.fvRsDomAtt_vmm.content.primaryEncap
    want        = "vlan-123"
  }

  equal "netflowPref" {
    description = "netflowPref"
    got         = data.aci_rest_managed.fvRsDomAtt_vmm.content.netflowPref
    want        = "disabled"
  }

  equal "instrImedcy" {
    description = "instrImedcy"
    got         = data.aci_rest_managed.fvRsDomAtt_vmm.content.instrImedcy
    want        = "lazy"
  }

  equal "resImedcy" {
    description = "resImedcy"
    got         = data.aci_rest_managed.fvRsDomAtt_vmm.content.resImedcy
    want        = "lazy"
  }

  equal "switchingMode" {
    description = "switchingMode"
    got         = data.aci_rest_managed.fvRsDomAtt_vmm.content.switchingMode
    want        = "native"
  }

  equal "customEpgName" {
    description = "customEpgName"
    got         = data.aci_rest_managed.fvRsDomAtt_vmm.content.customEpgName
    want        = "custom-epg-name"
  }
}

data "aci_rest_managed" "vmmSecP" {
  dn = "${data.aci_rest_managed.fvRsDomAtt_vmm.id}/sec"

  depends_on = [module.main]
}

resource "test_assertions" "vmmSecP" {
  component = "vmmSecP"

  equal "allowPromiscuous" {
    description = "allowPromiscuous"
    got         = data.aci_rest_managed.vmmSecP.content.allowPromiscuous
    want        = "accept"
  }

  equal "forgedTransmits" {
    description = "forgedTransmits"
    got         = data.aci_rest_managed.vmmSecP.content.forgedTransmits
    want        = "accept"
  }

  equal "macChanges" {
    description = "macChanges"
    got         = data.aci_rest_managed.vmmSecP.content.macChanges
    want        = "accept"
  }
}
