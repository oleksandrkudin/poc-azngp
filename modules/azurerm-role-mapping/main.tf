resource "azurerm_role_assignment" "this" {
  for_each = { for value in flatten([
    for mapping_key, mapping_value in var.role_mappings : [
      for role_name in mapping_value.role_definition_names : {
        key         = mapping_key
        "role_name" = role_name
        scope       = mapping_value.scope
      }
    ]
  ]) : format("%s_%s", value.key, replace(value.role_name, " ", "_")) => value }


  role_definition_name = each.value.role_name
  principal_id         = var.principal_id
  scope                = each.value.scope
}