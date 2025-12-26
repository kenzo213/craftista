output "region" {
  value = var.aws_region
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "ecr_repo_urls" {
  value = { for k, v in aws_ecr_repository.repos : k => v.repository_url }
}
