module "dynamodb-table_example_global-tables" {
  source  = "terraform-aws-modules/dynamodb-table/aws//examples/global-tables"
  version = "3.1.1"
}
