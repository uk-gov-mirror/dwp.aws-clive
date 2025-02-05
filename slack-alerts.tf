resource "aws_cloudwatch_event_rule" "aws_clive_failed" {
  name          = "aws_clive_failed"
  description   = "Sends failed message to slack when aws_clive cluster terminates with errors"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED_WITH_ERRORS"
    ],
    "name": [
      "aws_clive"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "aws_clive_terminated" {
  name          = "aws_clive_terminated"
  description   = "Sends failed message to slack when aws_clive cluster terminates by user request"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED"
    ],
    "name": [
      "aws_clive"
    ],
    "stateChangeReason": [
      "{\"code\":\"USER_REQUEST\",\"message\":\"User request\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "aws_clive_success" {
  name          = "aws_clive_success"
  description   = "checks that all steps complete"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED"
    ],
    "name": [
      "aws_clive"
    ],
    "stateChangeReason": [
      "{\"code\":\"ALL_STEPS_COMPLETED\",\"message\":\"Steps completed\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "aws_clive_running" {
  name          = "aws_clive_running"
  description   = "checks that aws_clive is running"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "RUNNING"
    ],
    "name": [
      "aws_clive"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_metric_alarm" "aws_clive_failed" {
  count                     = local.aws_clive_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_clive_failed"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors cluster failed with errors"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.aws_clive_failed.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "aws_clive_failed",
      notification_type = "Error",
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "aws_clive_terminated" {
  count                     = local.aws_clive_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_clive_terminated"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors cluster terminated by user request"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.aws_clive_terminated.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "aws_clive_terminated",
      notification_type = "Information",
      severity          = "High"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "aws_clive_success" {
  count                     = local.aws_clive_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_clive_success"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring aws_clive completion"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.aws_clive_success.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "aws_clive_success",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_metric_alarm" "aws_clive_running" {
  count                     = local.aws_clive_alerts[local.environment] == true ? 1 : 0
  alarm_name                = "aws_clive_running"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring aws_clive running"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.aws_clive_running.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "aws_clive_running",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
}
