variable "env_name" {
  type        = string
}
variable "infra_type" {
  type        = string
}
variable "var_count" {
  type        = number
  default = 2
}
variable "test_variable" {
  type = list(map(string))
  default = [ {   name  = "test_bucket_1",   value  = "true" }, {   name  = "test_bucket_2",   value  = "true" }] 
}

