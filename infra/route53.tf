################################################################################
# Route53 - Zones
# https://github.com/terraform-aws-modules/terraform-aws-route53
################################################################################

module "route53_zones" {

  # Only run the modules for the given condition
  count = contains(local.dev_and_prod_envs, terraform.workspace) ? 1 : 0

  # Module source path
  source = "terraform-aws-modules/route53/aws//modules/zones"

  # Module version
  version = "~> 2.10.2"

  # Zones
  zones = var.zones
}

resource "aws_route53_record" "ifood_case_dev_alias" {
  # Cria o registro apenas nos ambientes de desenvolvimento/produção
  for_each = contains(local.dev_and_prod_envs, terraform.workspace) ? var.cloudfront_s3_buckets : {}

  # A ID da sua Hosted Zone para o domínio
  zone_id = data.aws_route53_zone.domains[each.value.domain].zone_id

  # O NOME do subdomínio completo que você quer criar (ifood-case-dev.nglui.com)
  name = each.value.name

  # Tipo de registro: 'A' é usado com o bloco 'alias' para apontar para o CloudFront.
  type = "A"

  # Bloco ALIAS (O mapeamento que liga o subdomínio ao CloudFront)
  alias {
    # O domínio da sua Distribuição CloudFront (ex: dXXXXXXXX.cloudfront.net)
    name = module.cloudfront_s3_buckets[each.key].cloudfront_distribution_domain_name

    # O ID da Hosted Zone do CloudFront (é um valor fixo da AWS)
    zone_id = module.cloudfront_s3_buckets[each.key].cloudfront_distribution_hosted_zone_id

    # Não avaliar a saúde do target
    evaluate_target_health = false
  }
}
