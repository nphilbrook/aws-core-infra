terraform {
  required_version = "~>1.7"
}

resource "terraform_data" "greeting" {
  input = "hello"
}

output "input" {
  value = terraform_data.greeting.output
}
