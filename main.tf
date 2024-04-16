# Create AVD workspace
resource "azurerm_virtual_desktop_workspace" "this" {
  location                      = var.location
  name                          = var.name
  resource_group_name           = var.resource_group_name
  description                   = var.description
  friendly_name                 = var.name
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
}

# Create Diagnostic Settings for AVD workspace
resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${var.name}"
  target_resource_id             = azurerm_virtual_desktop_workspace.this.id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  log_analytics_workspace_id     = each.value.workspace_resource_id
  partner_solution_id            = each.value.marketplace_partner_resource_id
  storage_account_id             = each.value.storage_account_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories
    content {
      category = enabled_log.value
    }
  }
  dynamic "enabled_log" {
    for_each = each.value.log_groups
    content {
      category_group = enabled_log.value
    }
  }
}
