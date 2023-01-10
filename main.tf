locals {
  additional_ip_list = flatten([
    for st_ep in var.static_endpoints : [
      for ip in lookup(st_ep, "additional_ips", []) : {
        id   = "${st_ep.name}-${ip}"
        name = st_ep.name
        ip   = ip
      }
    ]
  ])
}

resource "aci_rest_managed" "fvAEPg" {
  dn         = "uni/tn-${var.tenant}/ap-${var.application_profile}/epg-${var.name}"
  class_name = "fvAEPg"
  content = {
    name         = var.name
    nameAlias    = var.alias
    descr        = var.description
    floodOnEncap = var.flood_in_encap == true ? "enabled" : "disabled"
    pcEnfPref    = var.intra_epg_isolation == true ? "enforced" : "unenforced"
    prefGrMemb   = var.preferred_group == true ? "include" : "exclude"
    prio         = var.qos_class
  }
}

resource "aci_rest_managed" "fvRsBd" {
  dn         = "${aci_rest_managed.fvAEPg.dn}/rsbd"
  class_name = "fvRsBd"
  content = {
    tnFvBDName = var.bridge_domain
  }
}

resource "aci_rest_managed" "fvRsCustQosPol" {
  count      = var.custom_qos_policy != "" ? 1 : 0
  dn         = "${aci_rest_managed.fvAEPg.dn}/rscustQosPol"
  class_name = "fvRsCustQosPol"
  content = {
    tnQosCustomPolName = var.custom_qos_policy
  }
}

resource "aci_rest_managed" "fvSubnet" {
  for_each   = { for subnet in var.subnets : subnet.ip => subnet }
  dn         = "${aci_rest_managed.fvAEPg.dn}/subnet-[${each.value.ip}]"
  class_name = "fvSubnet"
  content = {
    ip    = each.value.ip
    descr = each.value.description != null ? each.value.description : ""
    ctrl  = join(",", concat(each.value.nd_ra_prefix == true ? ["nd"] : [], each.value.no_default_gateway == true ? ["no-default-gateway"] : [], each.value.igmp_querier == true ? ["querier"] : []))
    scope = join(",", concat(each.value.public == true ? ["public"] : ["private"], each.value.shared == true ? ["shared"] : []))
  }
}

resource "aci_rest_managed" "fvRsCons" {
  for_each   = toset(var.contract_consumers)
  dn         = "${aci_rest_managed.fvAEPg.dn}/rscons-${each.value}"
  class_name = "fvRsCons"
  content = {
    tnVzBrCPName = each.value
  }
}

resource "aci_rest_managed" "fvRsProv" {
  for_each   = toset(var.contract_providers)
  dn         = "${aci_rest_managed.fvAEPg.dn}/rsprov-${each.value}"
  class_name = "fvRsProv"
  content = {
    tnVzBrCPName = each.value
  }
}

resource "aci_rest_managed" "fvRsConsIf" {
  for_each   = toset(var.contract_imported_consumers)
  dn         = "${aci_rest_managed.fvAEPg.dn}/rsconsIf-${each.value}"
  class_name = "fvRsConsIf"
  content = {
    tnVzCPIfName = each.value
  }
}

resource "aci_rest_managed" "fvRsIntraEpg" {
  for_each   = toset(var.contract_intra_epgs)
  dn         = "${aci_rest_managed.fvAEPg.dn}/rsintraEpg-${each.value}"
  class_name = "fvRsIntraEpg"
  content = {
    tnVzBrCPName = each.value
  }
}

resource "aci_rest_managed" "fvRsDomAtt" {
  for_each   = toset(var.physical_domains)
  dn         = "${aci_rest_managed.fvAEPg.dn}/rsdomAtt-[uni/phys-${each.value}]"
  class_name = "fvRsDomAtt"
  content = {
    tDn = "uni/phys-${each.value}"
  }
}

resource "aci_rest_managed" "fvRsPathAtt_port" {
  for_each   = { for sp in var.static_ports : "${sp.node_id}-${sp.port}-vl-${sp.vlan}" => sp if sp.channel == null && sp.fex_id == null && sp.sub_port == null }
  dn         = "${aci_rest_managed.fvAEPg.dn}/rspathAtt-[${format("topology/pod-%s/paths-%s/pathep-[eth%s/%s]", each.value.pod_id, each.value.node_id, each.value.module, each.value.port)}]"
  class_name = "fvRsPathAtt"
  content = {
    tDn         = format("topology/pod-%s/paths-%s/pathep-[eth%s/%s]", each.value.pod_id, each.value.node_id, each.value.module, each.value.port)
    encap       = "vlan-${each.value.vlan}"
    mode        = each.value.mode
    instrImedcy = each.value.deployment_immediacy
  }
}

resource "aci_rest_managed" "fvRsPathAtt_subport" {
  for_each   = { for sp in var.static_ports : "${sp.node_id}-${sp.port}-vl-${sp.vlan}" => sp if sp.channel == null && sp.fex_id == null && sp.sub_port != null }
  dn         = "${aci_rest_managed.fvAEPg.dn}/rspathAtt-[${format("topology/pod-%s/paths-%s/pathep-[eth%s/%s/%s]", each.value.pod_id, each.value.node_id, each.value.module, each.value.port, each.value.sub_port)}]"
  class_name = "fvRsPathAtt"
  content = {
    tDn         = format("topology/pod-%s/paths-%s/pathep-[eth%s/%s/%s]", each.value.pod_id, each.value.node_id, each.value.module, each.value.port, each.value.sub_port)
    encap       = "vlan-${each.value.vlan}"
    mode        = each.value.mode
    instrImedcy = each.value.deployment_immediacy
  }
}

resource "aci_rest_managed" "fvRsPathAtt_channel" {
  for_each   = { for sp in var.static_ports : "${sp.node_id}-${sp.channel}-vl-${sp.vlan}" => sp if sp.channel != null && sp.fex_id == null }
  dn         = "${aci_rest_managed.fvAEPg.dn}/rspathAtt-[${format(each.value.node2_id != null ? "topology/pod-%s/protpaths-%s-%s/pathep-[%s]" : "topology/pod-%s/paths-%s/pathep-[%[4]s]", each.value.pod_id, each.value.node_id, each.value.node2_id, each.value.channel)}]"
  class_name = "fvRsPathAtt"
  content = {
    tDn         = format(each.value.node2_id != null ? "topology/pod-%s/protpaths-%s-%s/pathep-[%s]" : "topology/pod-%s/paths-%s/pathep-[%[4]s]", each.value.pod_id, each.value.node_id, each.value.node2_id, each.value.channel)
    encap       = "vlan-${each.value.vlan}"
    mode        = each.value.mode
    instrImedcy = each.value.deployment_immediacy
  }
}

resource "aci_rest_managed" "fvRsPathAtt_fex_port" {
  for_each   = { for sp in var.static_ports : "${sp.node_id}-${sp.fex_id}-${sp.port}-vl-${sp.vlan}" => sp if sp.channel == null && sp.fex_id != null }
  dn         = "${aci_rest_managed.fvAEPg.dn}/rspathAtt-[${format("topology/pod-%s/paths-%s/extpaths-%s/pathep-[eth%s/%s]", each.value.pod_id, each.value.node_id, each.value.fex_id, each.value.module, each.value.port)}]"
  class_name = "fvRsPathAtt"
  content = {
    tDn         = format("topology/pod-%s/paths-%s/extpaths-%s/pathep-[eth%s/%s]", each.value.pod_id, each.value.node_id, each.value.fex_id, each.value.module, each.value.port)
    encap       = "vlan-${each.value.vlan}"
    mode        = each.value.mode
    instrImedcy = each.value.deployment_immediacy
  }
}

resource "aci_rest_managed" "fvRsPathAtt_fex_channel" {
  for_each   = { for sp in var.static_ports : "${sp.node_id}-${sp.fex_id}-${sp.channel}-vl-${sp.vlan}" => sp if sp.channel != null && sp.fex_id != null }
  dn         = "${aci_rest_managed.fvAEPg.dn}/rspathAtt-[${format(each.value.node2_id != null && each.value.fex2_id != null ? "topology/pod-%s/protpaths-%s-%s/extprotpaths-%s-%s/pathep-[%s]" : "topology/pod-%s/paths-%s/extpaths-%[4]s/pathep-[%[6]s]", each.value.pod_id, each.value.node_id, each.value.node2_id, each.value.fex_id, each.value.fex2_id, each.value.channel)}]"
  class_name = "fvRsPathAtt"
  content = {
    tDn         = format(each.value.node2_id != null && each.value.fex2_id != null ? "topology/pod-%s/protpaths-%s-%s/extprotpaths-%s-%s/pathep-[%s]" : "topology/pod-%s/paths-%s/extpaths-%[4]s/pathep-[%[6]s]", each.value.pod_id, each.value.node_id, each.value.node2_id, each.value.fex_id, each.value.fex2_id, each.value.channel)
    encap       = "vlan-${each.value.vlan}"
    mode        = each.value.mode
    instrImedcy = each.value.deployment_immediacy
  }
}

resource "aci_rest_managed" "fvStCEp" {
  for_each   = { for sp_ep in var.static_endpoints : sp_ep.name => sp_ep }
  dn         = "${aci_rest_managed.fvAEPg.dn}/stcep-${each.value.mac}-type-${each.value.type}"
  class_name = "fvStCEp"
  content = {
    encap     = each.value.type != "vep" ? "vlan-${each.value.vlan}" : "unknown"
    id        = "0"
    ip        = each.value.ip
    mac       = each.value.mac
    name      = each.value.name
    nameAlias = each.value.alias
    type      = each.value.type
  }
}

resource "aci_rest_managed" "fvStIp" {
  for_each   = { for ip in local.additional_ip_list : ip.id => ip }
  dn         = "${aci_rest_managed.fvStCEp[each.value.name].dn}/ip-[${each.value.ip}]"
  class_name = "fvStIp"
  content = {
    addr = each.value.ip
  }
}

resource "aci_rest_managed" "fvRsStCEpToPathEp_port" {
  for_each   = { for sp_ep in var.static_endpoints : sp_ep.name => sp_ep if sp_ep.port != null }
  dn         = "${aci_rest_managed.fvStCEp[each.value.name].dn}/rsstCEpToPathEp-[${format("topology/pod-%s/paths-%s/pathep-[eth%s/%s]", each.value.pod_id, each.value.node_id, each.value.module, each.value.port)}]"
  class_name = "fvRsStCEpToPathEp"
  content = {
    tDn = format("topology/pod-%s/paths-%s/pathep-[eth%s/%s]", each.value.pod_id, each.value.node_id, each.value.module, each.value.port)
  }
}

resource "aci_rest_managed" "fvRsStCEpToPathEp_channel" {
  for_each   = { for sp_ep in var.static_endpoints : sp_ep.name => sp_ep if sp_ep.channel != null }
  dn         = "${aci_rest_managed.fvStCEp[each.value.name].dn}/rsstCEpToPathEp-[${format(each.value.node2_id != null ? "topology/pod-%s/protpaths-%s-%s/pathep-[%s]" : "topology/pod-%s/paths-%s/pathep-[%[4]s]", each.value.pod_id, each.value.node_id, each.value.node2_id, each.value.channel)}]"
  class_name = "fvRsStCEpToPathEp"
  content = {
    tDn = format(each.value.node2_id != null ? "topology/pod-%s/protpaths-%s-%s/pathep-[%s]" : "topology/pod-%s/paths-%s/pathep-[%[4]s]", each.value.pod_id, each.value.node_id, each.value.node2_id, each.value.channel)
  }
}

resource "aci_rest_managed" "fvRsDomAtt_vmm" {
  for_each   = { for vmm_vwm in var.vmware_vmm_domains : vmm_vwm.name => vmm_vwm }
  dn         = "${aci_rest_managed.fvAEPg.dn}/rsdomAtt-[uni/vmmp-VMware/dom-${each.value.name}]"
  class_name = "fvRsDomAtt"
  content = {
    tDn           = "uni/vmmp-VMware/dom-${each.value.name}"
    classPref     = each.value.u_segmentation == true ? "useg" : "encap"
    delimiter     = each.value.delimiter
    encap         = each.value.primary_vlan != null ? (each.value.secondary_vlan != null ? "vlan-${each.value.secondary_vlan}" : "unknown") : (each.value.vlan != null ? "vlan-${each.value.vlan}" : "unknown")
    encapMode     = "auto"
    primaryEncap  = each.value.primary_vlan != null ? "vlan-${each.value.primary_vlan}" : "unknown"
    netflowPref   = each.value.netflow == true ? "enabled" : "disabled"
    instrImedcy   = each.value.deployment_immediacy
    resImedcy     = each.value.resolution_immediacy
    switchingMode = "native"
    customEpgName = each.value.custom_epg_name
  }
}

resource "aci_rest_managed" "vmmSecP" {
  for_each   = { for vmm_vwm in var.vmware_vmm_domains : vmm_vwm.name => vmm_vwm }
  dn         = "${aci_rest_managed.fvRsDomAtt_vmm[each.key].dn}/sec"
  class_name = "vmmSecP"
  content = {
    allowPromiscuous = each.value.allow_promiscuous == true ? "accept" : "reject"
    forgedTransmits  = each.value.forged_transmits == true ? "accept" : "reject"
    macChanges       = each.value.mac_changes == true ? "accept" : "reject"
  }
}

resource "aci_rest_managed" "fvAEPgLagPolAtt" {
  for_each   = { for vmm_vwm in var.vmware_vmm_domains : vmm_vwm.name => vmm_vwm if vmm_vwm.elag != "" }
  dn         = "${aci_rest_managed.fvRsDomAtt_vmm[each.key].dn}/epglagpolatt"
  class_name = "fvAEPgLagPolAtt"
}

resource "aci_rest_managed" "fvRsVmmVSwitchEnhancedLagPol" {
  for_each   = { for vmm_vwm in var.vmware_vmm_domains : vmm_vwm.name => vmm_vwm if vmm_vwm.elag != "" }
  dn         = "${aci_rest_managed.fvAEPgLagPolAtt[each.key].dn}/rsvmmVSwitchEnhancedLagPol"
  class_name = "fvRsVmmVSwitchEnhancedLagPol"
  content = {
    tDn = "uni/vmmp-VMware/dom-${each.value.name}/vswitchpolcont/enlacplagp-${each.value.elag}"
  }
}

resource "aci_rest_managed" "fvUplinkOrderCont" {
  for_each   = { for vmm_vwm in var.vmware_vmm_domains : vmm_vwm.name => vmm_vwm if vmm_vwm.active_uplinks_order != "" || vmm_vwm.standby_uplinks != "" }
  dn         = "${aci_rest_managed.fvRsDomAtt_vmm[each.key].dn}/uplinkorder"
  class_name = "fvUplinkOrderCont"
  content = {
    active  = each.value.active_uplinks_order
    standby = each.value.standby_uplinks
  }
}
