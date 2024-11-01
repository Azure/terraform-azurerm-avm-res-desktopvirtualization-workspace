# Create AVD workspace
resource "azurerm_virtual_desktop_workspace" "this" {
  location                      = var.virtual_desktop_workspace_location
  name                          = var.virtual_desktop_workspace_name
  resource_group_name           = var.virtual_desktop_workspace_resource_group_name
  description                   = var.virtual_desktop_workspace_description
  friendly_name                 = var.virtual_desktop_workspace_friendly_name != null ? var.virtual_desktop_workspace_friendly_name : var.virtual_desktop_workspace_name
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.virtual_desktop_workspace_tags

  dynamic "timeouts" {
    for_each = var.virtual_desktop_workspace_timeouts == null ? [] : [var.virtual_desktop_workspace_timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

# Create Diagnostic Settings for AVD workspace
resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${var.virtual_desktop_workspace_name}"
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
