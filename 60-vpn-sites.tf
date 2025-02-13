resource "azurerm_vpn_site" "vpn_site" {
  for_each = var.vpn_sites

  address_cidrs = lookup(each.value, "address_cidrs", null) != null ? split(",", replace(lookup(each.value, "address_cidrs", null), " ", "")) : []
  device_model  = lookup(each.value, "device_model", null)
  device_vendor = lookup(each.value, "device_vendor ", null)
  dynamic "link" {
    for_each = lookup(var.vpn_site_links, each.key, null) != null ? lookup(var.vpn_site_links, each.key, null) : []
    content {
      dynamic "bgp" {
        for_each = lookup(link.value, "asn", null) != null ? [1] : []
        content {
          asn             = lookup(link.value, "asn", null)
          peering_address = lookup(link.value, "peering_address", null)
        }
      }
      fqdn          = lookup(link.value, "fqdn", null)
      ip_address    = lookup(link.value, "ip_address", null)
      name          = lookup(link.value, "name", null)
      provider_name = lookup(link.value, "provider_name", null)
      speed_in_mbps = lookup(link.value, "speed_in_mbps", null)
    }
  }
  location            = lookup(each.value, "location", azurerm_resource_group.virtual_wan_resource_group[0].location)
  name                = each.key
  resource_group_name = lookup(each.value, "resource_group_name", azurerm_resource_group.virtual_wan_resource_group[0].name)
  virtual_wan_id      = azurerm_virtual_wan.virtual_wan[lookup(each.value, "virtual_wan_name", null)].id

  tags = var.common_tags
}
