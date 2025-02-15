# resource "azuread_application" "b2c_frontend" {
#   display_name = "${var.project_name}-frontend-${var.env}"

#   web {
#     # Some azuread provider versions demand no trailing slash if there is no path, 
#     # or they require it if there's no path segment. Adjust to what your provider version needs:
#     redirect_uris = [
#       "https://dev.fileshare.gregc.online/",
#       "http://localhost:3000/"
#     ]

#     implicit_grant {
#       access_token_issuance_enabled = true
#       id_token_issuance_enabled     = true
#     }
#   }
# }

# resource "azuread_service_principal" "b2c_frontend_sp" {
#   client_id = azuread_application.b2c_frontend.application_id
# }

# resource "azuread_application_password" "b2c_frontend_secret" {
#   application_object_id = azuread_application.b2c_frontend.application_id
#   display_name          = "client-secret"
#   end_date_relative     = "8760h" # 1 year
# }