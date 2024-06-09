

resource "azurerm_management_group" "mgmt_group" {
  display_name = "mgmt-${var.project_name}-${var.env}"

  subscription_ids = [
    var.subscription_id
  ]
}

resource "azurerm_management_group_policy_assignment" "mgmt_policy" {
  name                 = "policy-${var.project_name}-${var.env}"
  policy_definition_id = var.allowed_location_policy_id
  management_group_id  = azurerm_management_group.mgmt_group.id
  display_name         = "Allowed Locations Policy Assignment"
  description          = "Policy assignment to restrict locations to India and the USA."
  location             = "global"
  parameters = jsonencode({
    listOfAllowedLocations = {
      value = [
        "centralindia",
        "southindia",
        "westindia",
        "eastus",
        "eastus2",
        "centralus",
        "northcentralus",
        "southcentralus",
        "westus",
        "westus2"
      ]
    }
  })
}