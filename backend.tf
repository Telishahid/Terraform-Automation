terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket-31-batch"
    key = "main"
    region = "us-east-1"
    dynamodb_table = "my-dynamodb-table"
  }
}
