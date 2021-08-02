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

  tenant              = aci_rest.fvTenant.content.name
  application_profile = aci_rest.fvAp.content.name
  name                = "EPG1"
  bridge_domain       = "BD1"
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
