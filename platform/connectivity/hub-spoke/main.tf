module "hub_spoke" {
  source         = "../../../modules/hub-spoke"
  location       = var.location
  hub            = var.hub
  spokes         = var.spokes
  firewall       = var.firewall
  transit_routes = var.transit_routes
}
