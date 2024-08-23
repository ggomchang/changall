resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "cg-loggroup"
}

resource "aws_cloudwatch_log_metric_filter" "cloudwatch_log_filter" {
  name           = "cg-loggroup-filter"
  pattern        = "StartSession"
  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group.name

  metric_transformation {
    name      = "cg-loggroup-filter-metric"
    namespace = "cg-loggroup-filter"
    value     = "1"
  }
}

resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard" {
  dashboard_name = "cg-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type : "metric",
        x : 0,
        y : 0,
        width : 12,
        height : 6,
        properties : {
          metrics : [
            ["cg-loggroup-filter", "cg-loggroup-filter-metric", { "label" : "SSM Access: $${LAST}" }],
          ]
          view : "timeSeries",
          region : "ap-northeast-2",
          title : "SSM Access Count",
          stat : "Sum",
          period: 1,
          yAxis: {
            left: {
              min: 0,
              max: 20
            }
          },
          annotations: {
            horizontal: [
              {
                label: "Warning",
                value: 10,
                color: "#ff7f0e"
              }
            ]
          }
        }
      },
      {
        type : "log",
        x : 0,
        y : 6,
        width : 24,
        height : 6
        properties : {
          title : "SSM Access Logs",
          region : "ap-northeast-2",
          query : "SOURCE 'cg-loggroup' | fields eventTime, eventSource, requestParameters.state as state, userIdentity.accountId as accountId, requestParameters.filters.1.value as sessionId | filter eventSource =~ /^(?i)ssm.amazonaws.com$/ | filter isPresent(requestParameters.filters.1.value) | sort eventTime desc",
          view : "table"
        }
      }
    ]
  })

  depends_on = [
  aws_cloudwatch_log_group.cloudwatch_log_group,
  aws_cloudwatch_log_metric_filter.cloudwatch_log_filter
]
}
