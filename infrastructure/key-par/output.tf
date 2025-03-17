output "key" {
  description = "The name of the AWS key pair"
  value       = aws_key_pair.key.key_name
}
