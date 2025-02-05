resource "aws_s3_bucket_object" "metadata_script" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  key        = "component/aws-clive/metadata.sh"
  content    = file("${path.module}/bootstrap_actions/metadata.sh")
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
}

resource "aws_s3_bucket_object" "download_scripts_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/aws-clive/download_scripts.sh"
  content = templatefile("${path.module}/bootstrap_actions/download_scripts.sh",
    {
      VERSION                 = local.aws_clive_version[local.environment]
      aws_clive_LOG_LEVEL     = local.aws_clive_log_level[local.environment]
      ENVIRONMENT_NAME        = local.environment
      S3_COMMON_LOGGING_SHELL = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, data.terraform_remote_state.common.outputs.application_logging_common_file.s3_id)
      S3_LOGGING_SHELL        = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.logging_script.key)
      scripts_location        = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, "component/aws-clive")
  })
}

resource "aws_s3_bucket_object" "download_sql_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/aws-clive/download_sql.sh"
  content = templatefile("${path.module}/bootstrap_actions/download_sql.sh",
    {
      version                 = local.dataworks_clive_version[local.environment]
      s3_artefact_bucket_id = data.terraform_remote_state.management_artefact.outputs.artefact_bucket.id
      s3_config_bucket_id   = format("s3://%s", data.terraform_remote_state.common.outputs.config_bucket.id)
      aws_clive_log_level   = local.aws_clive_log_level[local.environment]
      environment_name      = local.environment
    }
  )
}

resource "aws_s3_bucket_object" "emr_setup_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/aws-clive/emr-setup.sh"
  content = templatefile("${path.module}/bootstrap_actions/emr-setup.sh",
    {
      aws_clive_LOG_LEVEL             = local.aws_clive_log_level[local.environment]
      aws_default_region              = "eu-west-2"
      full_proxy                      = data.terraform_remote_state.internal_compute.outputs.internet_proxy.url
      full_no_proxy                   = local.no_proxy
      acm_cert_arn                    = aws_acm_certificate.aws_clive.arn
      private_key_alias               = "private_key"
      truststore_aliases              = join(",", var.truststore_aliases)
      truststore_certs                = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem"
      dks_endpoint                    = data.terraform_remote_state.crypto.outputs.dks_endpoint[local.environment]
      cwa_metrics_collection_interval = local.cw_agent_metrics_collection_interval
      cwa_namespace                   = local.cw_agent_namespace
      cwa_log_group_name              = aws_cloudwatch_log_group.aws_clive.name
      S3_CLOUDWATCH_SHELL             = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.cloudwatch_sh.key)
      cwa_bootstrap_loggrp_name       = aws_cloudwatch_log_group.aws_clive_cw_bootstrap_loggroup.name
      cwa_steps_loggrp_name           = aws_cloudwatch_log_group.aws_clive_cw_steps_loggroup.name
      name                            = local.emr_cluster_name
  })
}

resource "aws_s3_bucket_object" "ssm_script" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "component/aws-clive/start_ssm.sh"
  content = file("${path.module}/bootstrap_actions/start_ssm.sh")
}


resource "aws_s3_bucket_object" "logging_script" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "component/aws-clive/logging.sh"
  content = file("${path.module}/bootstrap_actions/logging.sh")
}

resource "aws_cloudwatch_log_group" "aws_clive" {
  name              = local.cw_agent_log_group_name
  retention_in_days = 180
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "aws_clive_cw_bootstrap_loggroup" {
  name              = local.cw_agent_bootstrap_loggrp_name
  retention_in_days = 180
  tags              = local.common_tags
}

resource "aws_cloudwatch_log_group" "aws_clive_cw_steps_loggroup" {
  name              = local.cw_agent_steps_loggrp_name
  retention_in_days = 180
  tags              = local.common_tags
}

resource "aws_s3_bucket_object" "cloudwatch_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/aws-clive/cloudwatch.sh"
  content = templatefile("${path.module}/bootstrap_actions/cloudwatch.sh",
    {
      emr_release = var.emr_release[local.environment]
    }
  )
}

resource "aws_s3_bucket_object" "metrics_setup_sh" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws-clive/metrics-setup.sh"
  content = templatefile("${path.module}/bootstrap_actions/metrics-setup.sh",
    {
      proxy_url         = data.terraform_remote_state.internal_compute.outputs.internet_proxy.url
      metrics_pom       = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.metrics_pom.key)
      prometheus_config = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.prometheus_config.key)
    }
  )
}

resource "aws_s3_bucket_object" "metrics_pom" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws-clive/metrics/pom.xml"
  content    = file("${path.module}/bootstrap_actions/metrics_config/pom.xml")
}

resource "aws_s3_bucket_object" "prometheus_config" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/aws-clive/metrics/prometheus_config.yml"
  content    = file("${path.module}/bootstrap_actions/metrics_config/prometheus_config.yml")
}
