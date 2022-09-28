variable "tenant" {
  description = "Tenant name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{0,64}$", var.tenant))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "application_profile" {
  description = "Application profile name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{0,64}$", var.application_profile))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "name" {
  description = "Endpoint group name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{0,64}$", var.name))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "alias" {
  description = "Alias."
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{0,64}$", var.alias))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "description" {
  description = "Description."
  type        = string
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]{0,128}$", var.description))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `\\`, `!`, `#`, `$`, `%`, `(`, `)`, `*`, `,`, `-`, `.`, `/`, `:`, `;`, `@`, ` `, `_`, `{`, `|`, }`, `~`, `?`, `&`, `+`. Maximum characters: 128."
  }
}

variable "flood_in_encap" {
  description = "Flood in encapsulation."
  type        = bool
  default     = false
}

variable "intra_epg_isolation" {
  description = "Intra EPG isolation."
  type        = bool
  default     = false
}

variable "preferred_group" {
  description = "Preferred group membership."
  type        = bool
  default     = false
}

variable "bridge_domain" {
  description = "Bridge domain name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{0,64}$", var.bridge_domain))
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "contract_consumers" {
  description = "List of contract consumers."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for c in var.contract_consumers : can(regex("^[a-zA-Z0-9_.-]{0,64}$", c))
    ])
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "contract_providers" {
  description = "List of contract providers."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for c in var.contract_providers : can(regex("^[a-zA-Z0-9_.-]{0,64}$", c))
    ])
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "contract_imported_consumers" {
  description = "List of imported contract consumers."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for c in var.contract_imported_consumers : can(regex("^[a-zA-Z0-9_.-]{0,64}$", c))
    ])
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "physical_domains" {
  description = "List of physical domains."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for pd in var.physical_domains : can(regex("^[a-zA-Z0-9_.-]{0,64}$", pd))
    ])
    error_message = "Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}

variable "subnets" {
  description = "List of subnets. Default value `public`: `false`. Default value `shared`: `false`. Default value `igmp_querier`: `false`. Default value `nd_ra_prefix`: `true`. Default value `no_default_gateway`: `false`."
  type = list(object({
    description        = optional(string, "")
    ip                 = string
    public             = optional(bool, false)
    shared             = optional(bool, false)
    igmp_querier       = optional(bool, false)
    nd_ra_prefix       = optional(bool, true)
    no_default_gateway = optional(bool, false)
  }))
  default = []

  validation {
    condition = alltrue([
      for s in var.subnets : s.description == null || can(regex("^[a-zA-Z0-9\\!#$%()*,-./:;@ _{|}~?&+]{0,128}$", s.description))
    ])
    error_message = "`description`: Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `\\`, `!`, `#`, `$`, `%`, `(`, `)`, `*`, `,`, `-`, `.`, `/`, `:`, `;`, `@`, ` `, `_`, `{`, `|`, }`, `~`, `?`, `&`, `+`. Maximum characters: 128."
  }
}

variable "vmware_vmm_domains" {
  description = "List of VMware VMM domains. Default value `u_segmentation`: `false`. Default value `netflow`: `false`. Choices `deployment_immediacy`: `immediate`, `lazy`. Default value `deployment_immediacy`: `lazy`. Choices `resolution_immediacy`: `immediate`, `lazy`, `pre-provision`. Default value `resolution_immediacy`: `immediate`. Default value `allow_promiscuous`: `false`. Default value `forged_transmits`: `false`. Default value `mac_changes`: `false`."
  type = list(object({
    name                 = string
    u_segmentation       = optional(bool, false)
    delimiter            = optional(string, "")
    vlan                 = optional(number)
    primary_vlan         = optional(number)
    secondary_vlan       = optional(number)
    netflow              = optional(bool, false)
    deployment_immediacy = optional(string, "lazy")
    resolution_immediacy = optional(string, "immediate")
    allow_promiscuous    = optional(bool, false)
    forged_transmits     = optional(bool, false)
    mac_changes          = optional(bool, false)
    custom_epg_name      = optional(string, "")
  }))
  default = []

  validation {
    condition = alltrue([
      for dom in var.vmware_vmm_domains : can(regex("^[a-zA-Z0-9_.-]{0,64}$", dom.name))
    ])
    error_message = "`name`: Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }

  validation {
    condition = alltrue([
      for dom in var.vmware_vmm_domains : dom.vlan == null || try(dom.vlan >= 1 && dom.vlan <= 4096, false)
    ])
    error_message = "`vlan`: Minimum value: `1`. Maximum value: `4096`."
  }

  validation {
    condition = alltrue([
      for dom in var.vmware_vmm_domains : dom.primary_vlan == null || try(dom.primary_vlan >= 1 && dom.primary_vlan <= 4096, false)
    ])
    error_message = "`primary_vlan`: Minimum value: `1`. Maximum value: `4096`."
  }

  validation {
    condition = alltrue([
      for dom in var.vmware_vmm_domains : dom.secondary_vlan == null || try(dom.secondary_vlan >= 1 && dom.secondary_vlan <= 4096, false)
    ])
    error_message = "`secondary_vlan`: Minimum value: `1`. Maximum value: `4096`."
  }

  validation {
    condition = alltrue([
      for dom in var.vmware_vmm_domains : dom.deployment_immediacy == null || try(contains(["immediate", "lazy"], dom.deployment_immediacy), false)
    ])
    error_message = "`deployment_immediacy`: Allowed values are `immediate` or `lazy`."
  }

  validation {
    condition = alltrue([
      for dom in var.vmware_vmm_domains : dom.resolution_immediacy == null || try(contains(["immediate", "lazy", "pre-provision"], dom.resolution_immediacy), false)
    ])
    error_message = "`resolution_immediacy`: Allowed values are `immediate`, `lazy` or `pre-provision`."
  }

  validation {
    condition = alltrue([
      for dom in var.vmware_vmm_domains : dom.custom_epg_name == null || can(regex("^.{0,80}$", dom.custom_epg_name))
    ])
    error_message = "`custom_epg_name`: Maximum characters: 80."
  }
}

variable "static_ports" {
  description = "List of static ports. Allowed values `node_id`, `node2_id`: `1` - `4000`. Allowed values `fex_id`, `fex2_id`: `101` - `199`. Allowed values `vlan`: `1` - `4096`. Allowed values `pod_id`: `1` - `255`. Default value `pod_id`: `1`. Allowed values `port`: `1` - `127`. Allowed values `sub_port`: `1` - `16`. Allowed values `module`: `1` - `9`. Default value `module`: `1`. Choices `deployment_immediacy`: `immediate`, `lazy`. Default value `deployment_immediacy`: `lazy`. Choices `mode`: `regular`, `native`, `untagged`. Default value `mode`: `regular`."
  type = list(object({
    node_id              = number
    node2_id             = optional(number)
    fex_id               = optional(number)
    fex2_id              = optional(number)
    vlan                 = number
    pod_id               = optional(number, 1)
    port                 = optional(number)
    sub_port             = optional(number)
    module               = optional(number, 1)
    channel              = optional(string)
    deployment_immediacy = optional(string, "lazy")
    mode                 = optional(string, "regular")
  }))
  default = []

  validation {
    condition = alltrue([
      for sp in var.static_ports : (sp.node_id >= 1 && sp.node_id <= 4000)
    ])
    error_message = "`node_id`: Minimum value: `1`. Maximum value: `4000`."
  }

  validation {
    condition = alltrue([
      for sp in var.static_ports : sp.node2_id == null || try(sp.node2_id >= 1 && sp.node2_id <= 4000, false)
    ])
    error_message = "`node2_id`: Minimum value: `1`. Maximum value: `4000`."
  }

  validation {
    condition = alltrue([
      for sp in var.static_ports : sp.fex_id == null || try(sp.fex_id >= 101 && sp.fex_id <= 199, false)
    ])
    error_message = "`fex_id`: Minimum value: `101`. Maximum value: `199`."
  }

  validation {
    condition = alltrue([
      for sp in var.static_ports : sp.fex2_id == null || try(sp.fex2_id >= 101 && sp.fex2_id <= 199, false)
    ])
    error_message = "`fex2_id`: Minimum value: `101`. Maximum value: `199`."
  }

  validation {
    condition = alltrue([
      for sp in var.static_ports : (sp.vlan >= 1 && sp.vlan <= 4096)
    ])
    error_message = "`vlan`: Minimum value: `1`. Maximum value: `4096`."
  }

  validation {
    condition = alltrue([
      for sp in var.static_ports : sp.pod_id == null || try(sp.pod_id >= 1 && sp.pod_id <= 255, false)
    ])
    error_message = "`pod_id`: Minimum value: `1`. Maximum value: `255`."
  }

  validation {
    condition = alltrue([
      for sp in var.static_ports : sp.port == null || try(sp.port >= 1 && sp.port <= 127, false)
    ])
    error_message = "`port`: Minimum value: `1`. Maximum value: `127`."
  }

  validation {
    condition = alltrue([
      for sp in var.static_ports : sp.sub_port == null || try(sp.sub_port >= 1 && sp.sub_port <= 16, false)
    ])
    error_message = "`sub_port`: Minimum value: `1`. Maximum value: `16`."
  }

  validation {
    condition = alltrue([
      for sp in var.static_ports : sp.module == null || try(sp.module >= 1 && sp.module <= 9, false)
    ])
    error_message = "`module`: Minimum value: `1`. Maximum value: `9`."
  }

  validation {
    condition = alltrue([
      for sp in var.static_ports : sp.channel == null || can(regex("^[a-zA-Z0-9_.-]{0,64}$", sp.channel))
    ])
    error_message = "`channel`: Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }

  validation {
    condition = alltrue([
      for sp in var.static_ports : sp.deployment_immediacy == null || try(contains(["immediate", "lazy"], sp.deployment_immediacy), false)
    ])
    error_message = "`deployment_immediacy`: Allowed values are `immediate` or `lazy`."
  }

  validation {
    condition = alltrue([
      for sp in var.static_ports : sp.mode == null || try(contains(["regular", "native", "untagged"], sp.mode), false)
    ])
    error_message = "`mode`: Allowed values are `regular`, `native` or `untagged`."
  }
}

variable "static_endpoints" {
  description = "List of static endpoints. Format `mac`: `12:34:56:78:9A:BC`. Choices `type`: `silent-host`, `tep`, `vep`. Allowed values `node_id`, `node2_id`: `1` - `4000`. Allowed values `vlan`: `1` - `4096`. Allowed values `pod_id`: `1` - `255`. Default value `pod_id`: `1`. Allowed values `port`: `1` - `127`. Allowed values `module`: `1` - `9`. Default value `module`: `1`."
  type = list(object({
    name           = string
    alias          = optional(string, "")
    mac            = string
    ip             = optional(string, "0.0.0.0")
    type           = string
    node_id        = optional(string)
    node2_id       = optional(string)
    vlan           = optional(string)
    pod_id         = optional(string, 1)
    port           = optional(string)
    module         = optional(string, 1)
    channel        = optional(string)
    additional_ips = optional(list(string), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for se in var.static_endpoints : can(regex("^[a-zA-Z0-9_.-]{0,64}$", se.name))
    ])
    error_message = "`name`: Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }

  validation {
    condition = alltrue([
      for se in var.static_endpoints : se.alias == null || can(regex("^[a-zA-Z0-9_.-]{0,64}$", se.alias))
    ])
    error_message = "`alias`: Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }

  validation {
    condition = alltrue([
      for se in var.static_endpoints : can(regex("^([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})$", se.mac))
    ])
    error_message = "`mac`: Format: `12:34:56:78:9A:BC`."
  }

  validation {
    condition = alltrue([
      for se in var.static_endpoints : se.type == null || try(contains(["silent-host", "tep", "vep"], se.type), false)
    ])
    error_message = "`type`: Allowed values are `silent-host`, `tep` or `vep`."
  }

  validation {
    condition = alltrue([
      for se in var.static_endpoints : (se.node_id >= 1 && se.node_id <= 4000)
    ])
    error_message = "`node_id`: Minimum value: `1`. Maximum value: `4000`."
  }

  validation {
    condition = alltrue([
      for se in var.static_endpoints : se.node2_id == null || try(se.node2_id >= 1 && se.node2_id <= 4000, false)
    ])
    error_message = "`node2_id`: Minimum value: `1`. Maximum value: `4000`."
  }

  validation {
    condition = alltrue([
      for se in var.static_endpoints : (se.vlan >= 1 && se.vlan <= 4096)
    ])
    error_message = "`vlan`: Minimum value: `1`. Maximum value: `4096`."
  }

  validation {
    condition = alltrue([
      for se in var.static_endpoints : se.pod_id == null || try(se.pod_id >= 1 && se.pod_id <= 255, false)
    ])
    error_message = "`pod_id`: Minimum value: `1`. Maximum value: `255`."
  }

  validation {
    condition = alltrue([
      for se in var.static_endpoints : se.port == null || try(se.port >= 1 && se.port <= 127, false)
    ])
    error_message = "`port`: Minimum value: `1`. Maximum value: `127`."
  }

  validation {
    condition = alltrue([
      for se in var.static_endpoints : se.module == null || try(se.module >= 1 && se.module <= 9, false)
    ])
    error_message = "`module`: Minimum value: `1`. Maximum value: `9`."
  }

  validation {
    condition = alltrue([
      for se in var.static_endpoints : se.channel == null || can(regex("^[a-zA-Z0-9_.-]{0,64}$", se.channel))
    ])
    error_message = "`channel`: Allowed characters: `a`-`z`, `A`-`Z`, `0`-`9`, `_`, `.`, `-`. Maximum characters: 64."
  }
}
