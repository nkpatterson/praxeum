variable "instance_name" {}
variable "location" {
	default = "westus2"
}
variable "b2c_tenant" {
	default = "cloudskillsouthwest"
}
variable "b2c_policy" {
	default = "B2C_1_SignUpSignIn"
}
variable "b2c_client_id" {
	default = "2e941d7a-fe74-4aa6-9881-9f70364a7cc3"
}
variable "b2c_client_secret" {}