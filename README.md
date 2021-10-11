<!-- BEGIN_TF_DOCS -->
[![Tests](https://github.com/netascode/terraform-aci-endpoint-group/actions/workflows/test.yml/badge.svg)](https://github.com/netascode/terraform-aci-endpoint-group/actions/workflows/test.yml)

# Terraform ACI Endpoint Group Module

Manages ACI Endpoint Group

Location in GUI:
`Tenants` » `XXX` » `Application Profiles` » `XXX` » `Application EPGs`

## Examples

```hcl
module "aci_endpoint_group" {
  source  = "netascode/endpoint-group/aci"
  version = ">= 0.0.2"

  tenant                      = "ABC"
  application_profile         = "AP1"
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
    module               = 1
    deployment_immediacy = "lazy"
    mode                 = "untagged"
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

```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aci"></a> [aci](#requirement\_aci) | >= 0.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aci"></a> [aci](#provider\_aci) | >= 0.2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Tenant name. | `string` | n/a | yes |
| <a name="input_application_profile"></a> [application\_profile](#input\_application\_profile) | Application profile name. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Endpoint group name. | `string` | n/a | yes |
| <a name="input_alias"></a> [alias](#input\_alias) | Alias. | `string` | `""` | no |
| <a name="input_description"></a> [description](#input\_description) | Description. | `string` | `""` | no |
| <a name="input_flood_in_encap"></a> [flood\_in\_encap](#input\_flood\_in\_encap) | Flood in encapsulation. | `bool` | `false` | no |
| <a name="input_intra_epg_isolation"></a> [intra\_epg\_isolation](#input\_intra\_epg\_isolation) | Intra EPG isolation. | `bool` | `false` | no |
| <a name="input_preferred_group"></a> [preferred\_group](#input\_preferred\_group) | Preferred group membership. | `bool` | `false` | no |
| <a name="input_bridge_domain"></a> [bridge\_domain](#input\_bridge\_domain) | Bridge domain name. | `string` | n/a | yes |
| <a name="input_contract_consumers"></a> [contract\_consumers](#input\_contract\_consumers) | List of contract consumers. | `list(string)` | `[]` | no |
| <a name="input_contract_providers"></a> [contract\_providers](#input\_contract\_providers) | List of contract providers. | `list(string)` | `[]` | no |
| <a name="input_contract_imported_consumers"></a> [contract\_imported\_consumers](#input\_contract\_imported\_consumers) | List of imported contract consumers. | `list(string)` | `[]` | no |
| <a name="input_physical_domains"></a> [physical\_domains](#input\_physical\_domains) | List of physical domains. | `list(string)` | `[]` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnets. Default value `public`: `false`. Default value `shared`: `false`. Default value `igmp_querier`: `false`. Default value `nd_ra_prefix`: `true`. Default value `no_default_gateway`: `false`. | <pre>list(object({<br>    description        = optional(string)<br>    ip                 = string<br>    public             = optional(bool)<br>    shared             = optional(bool)<br>    igmp_querier       = optional(bool)<br>    nd_ra_prefix       = optional(bool)<br>    no_default_gateway = optional(bool)<br>  }))</pre> | `[]` | no |
| <a name="input_vmware_vmm_domains"></a> [vmware\_vmm\_domains](#input\_vmware\_vmm\_domains) | List of VMware VMM domains. Default value `u_segmentation`: `false`. Default value `netflow`: `false`. Choices `deployment_immediacy`: `immediate`, `lazy`. Default value `deployment_immediacy`: `lazy`. Choices `resolution_immediacy`: `immediate`, `lazy`, `pre-provision`. Default value `resolution_immediacy`: `immediate`. Default value `allow_promiscuous`: `false`. Default value `forged_transmits`: `false`. Default value `mac_changes`: `false`. | <pre>list(object({<br>    name                 = string<br>    u_segmentation       = optional(bool)<br>    delimiter            = optional(string)<br>    vlan                 = optional(number)<br>    primary_vlan         = optional(number)<br>    secondary_vlan       = optional(number)<br>    netflow              = optional(bool)<br>    deployment_immediacy = optional(string)<br>    resolution_immediacy = optional(string)<br>    allow_promiscuous    = optional(bool)<br>    forged_transmits     = optional(bool)<br>    mac_changes          = optional(bool)<br>    custom_epg_name      = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_static_ports"></a> [static\_ports](#input\_static\_ports) | List of static ports. Allowed values `node_id`, `node2_id`: `1` - `4000`. Allowed values `vlan`: `1` - `4096`. Allowed values `pod_id`: `1` - `255`. Default value `pod_id`: `1`. Allowed values `port`: `1` - `127`. Allowed values `module`: `1` - `9`. Default value `module`: `1`. Choices `deployment_immediacy`: `immediate`, `lazy`. Default value `deployment_immediacy`: `lazy`. Choices `mode`: `regular`, `native`, `untagged`. Default value `mode`: `regular`. | <pre>list(object({<br>    node_id              = number<br>    node2_id             = optional(number)<br>    vlan                 = number<br>    pod_id               = optional(number)<br>    port                 = optional(number)<br>    module               = optional(number)<br>    channel              = optional(string)<br>    deployment_immediacy = optional(string)<br>    mode                 = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_static_endpoints"></a> [static\_endpoints](#input\_static\_endpoints) | List of static endpoints. Format `mac`: `12:34:56:78:9A:BC`. Choices `type`: `silent-host`, `tep`, `vep`. Allowed values `node_id`, `node2_id`: `1` - `4000`. Allowed values `vlan`: `1` - `4096`. Allowed values `pod_id`: `1` - `255`. Default value `pod_id`: `1`. Allowed values `port`: `1` - `127`. Allowed values `module`: `1` - `9`. Default value `module`: `1`. | <pre>list(object({<br>    name           = string<br>    alias          = optional(string)<br>    mac            = string<br>    ip             = optional(string)<br>    type           = string<br>    node_id        = optional(string)<br>    node2_id       = optional(string)<br>    vlan           = optional(string)<br>    pod_id         = optional(string)<br>    port           = optional(string)<br>    module         = optional(string)<br>    channel        = optional(string)<br>    additional_ips = optional(list(string))<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dn"></a> [dn](#output\_dn) | Distinguished name of `fvAEPg` object. |
| <a name="output_name"></a> [name](#output\_name) | Endpoint group name. |

## Resources

| Name | Type |
|------|------|
| [aci_rest.fvAEPg](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvRsBd](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvRsCons](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvRsConsIf](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvRsDomAtt](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvRsDomAtt_vmm](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvRsPathAtt_channel](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvRsPathAtt_port](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvRsProv](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvRsStCEpToPathEp_channel](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvRsStCEpToPathEp_port](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvStCEp](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvStIp](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvSubnet](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.vmmSecP](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
<!-- END_TF_DOCS -->