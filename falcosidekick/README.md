# Falcosidekick

![falcosidekick](https://github.com/falcosecurity/falcosidekick/raw/master/imgs/falcosidekick_color.png)

![release](https://flat.badgen.net/github/release/falcosecurity/falcosidekick/latest?color=green) ![last commit](https://flat.badgen.net/github/last-commit/falcosecurity/falcosidekick) ![licence](https://flat.badgen.net/badge/license/MIT/blue) ![docker pulls](https://flat.badgen.net/docker/pulls/falcosecurity/falcosidekick?icon=docker)

## Description

A simple daemon for enhancing available outputs for [Falco](https://sysdig.com/opensource/falco/). It takes a falco's event and forwards it to different outputs.

It works as a single endpoint for as many as you want `falco` instances :

![falco_with_falcosidekick](https://github.com/falcosecurity/falcosidekick/raw/master/imgs/falco_with_falcosidekick.png)

## Outputs

Currently available outputs are :

* [**Slack**](https://slack.com)
* [**Rocketchat**](https://rocket.chat/)
* [**Mattermost**](https://mattermost.com/)
* [**Teams**](https://products.office.com/en-us/microsoft-teams/group-chat-software)
* [**Datadog**](https://www.datadoghq.com/)
* [**Discord**](https://www.discord.com/)
* [**AlertManager**](https://prometheus.io/docs/alerting/alertmanager/)
* [**Elasticsearch**](https://www.elastic.co/)
* [**Loki**](https://grafana.com/oss/loki)
* [**NATS**](https://nats.io/)
* [**Influxdb**](https://www.influxdata.com/products/influxdb-overview/)
* [**AWS Lambda**](https://aws.amazon.com/lambda/features/)
* [**AWS SQS**](https://aws.amazon.com/sqs/features/)
* [**AWS SNS**](https://aws.amazon.com/sns/features/)
* **SMTP** (email)
* [**Opsgenie**](https://www.opsgenie.com/)
* [**StatsD**](https://github.com/statsd/statsd) (for monitoring of `falcosidekick`)
* [**DogStatsD**](https://docs.datadoghq.com/developers/dogstatsd/?tab=go) (for monitoring of `falcosidekick`)
* **Webhook**
* [**Azure Event Hubs**](https://azure.microsoft.com/en-in/services/event-hubs/)

## Adding `falcosecurity` repository

Prior to install the chart, add the `falcosecurity` charts repository:

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
```

## Installing the Chart

To install the chart with the release name `falcosidekick` run:

```bash
helm install falcosidekick falcosecurity/falcosidekick
```

After a few seconds, Falcosidekick should be running.

> **Tip**: List all releases using `helm list`, a release is a name used to track a specific deployment

## Uninstalling the Chart

To uninstall the `falcosidekick` deployment:

```bash
helm uninstall falcosidekick
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the Falcosidekick chart and their default values.

| Parameter                        | Description                                                                                                                                                               | Default                                                                                           |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `replicaCount`                   | number of running pods                                                                                                                                                    | `1`                                                                                               |
| `listenport`                     | port to listen for daemon                                                                                                                                                 | `2801`                                                                                            |
| `debug`                          | if *true* all outputs will print in stdout the payload they send                                                                                                          | `false`                                                                                           |
| `customfields`                   | a list of comma separated custom fields to add to falco events, syntax is "key:value,key:value"                                                                           |                                                                                                   |
| `checkcert`                      | check if ssl certificate of the output is valid                                                                                                                           | `true`                                                                                            |
| `slack.webhookurl`               | Slack Webhook URL (ex: https://hooks.slack.com/services/XXXX/YYYY/ZZZZ), if not `empty`, Slack output is *enabled*                                                        |                                                                                                   |
| `slack.footer`                   | Slack Footer                                                                                                                                                              | https://github.com/falcosecurity/falcosidekick                                                    |
| `slack.icon`                     | Slack icon (avatar)                                                                                                                                                       | https://raw.githubusercontent.com/falcosecurity/falcosidekick/master/imgs/falcosidekick_color.png |
| `slack.username`                 | Slack username                                                                                                                                                            | `falcosidekick`                                                                                   |
| `slack.outputformat`             | `all` (default), `text` (only text is displayed in Slack), `fields` (only fields are displayed in Slack)                                                                  | `all`                                                                                             |
| `slack.minimumpriority`          | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `slack.messageformat`            | a Go template to format Slack Text above Attachment, displayed in addition to the output from `slack.outputformat`. If empty, no Text is displayed before Attachment      |                                                                                                   |
| `rocketchat.webhookurl`          | Rocketchat Webhook URL (ex: https://XXXX/hooks/YYYY), if not `empty`, Rocketchat output is *enabled*                                                                      |                                                                                                   |
| `rocketchat.icon`                | Rocketchat icon (avatar)                                                                                                                                                  | https://raw.githubusercontent.com/falcosecurity/falcosidekick/master/imgs/falcosidekick_color.png |
| `rocketchat.username`            | Rocketchat username                                                                                                                                                       | `falcosidekick`                                                                                   |
| `rocketchat.outputformat`        | `all` (default), `text` (only text is displayed in Rocketcaht), `fields` (only fields are displayed in Rocketchat)                                                        | `all`                                                                                             |
| `rocketchat.minimumpriority`     | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `rockerchat.messageformat`       | a Go template to format Rocketchat Text above Attachment, displayed in addition to the output from `slack.outputformat`. If empty, no Text is displayed before Attachment |                                                                                                   |
| `mattermost.webhookurl`          | Mattermost Webhook URL (ex: https://XXXX/hooks/YYYY), if not `empty`, Mattermost output is *enabled*                                                                      |                                                                                                   |
| `mattermost.footer`              | Mattermost Footer                                                                                                                                                         | https://github.com/falcosecurity/falcosidekick                                                    |
| `mattermost.icon`                | Mattermost icon (avatar)                                                                                                                                                  | https://raw.githubusercontent.com/falcosecurity/falcosidekick/master/imgs/falcosidekick_color.png |
| `mattermost.username`            | Mattermost username                                                                                                                                                       | `falcosidekick`                                                                                   |
| `mattermost.outputformat`        | `all` (default), `text` (only text is displayed in Slack), `fields` (only fields are displayed in Mattermost)                                                             | `all`                                                                                             |
| `mattermost.minimumpriority`     | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `mattermost.messageformat`       | a Go template to format Mattermost Text above Attachment, displayed in addition to the output from `slack.outputformat`. If empty, no Text is displayed before Attachment |                                                                                                   |
| `teams.webhookurl`               | Teams Webhook URL (ex: https://outlook.office.com/webhook/XXXXXX/IncomingWebhook/YYYYYY"), if not `empty`, Teams output is *enabled*                                      |                                                                                                   |
| `teams.activityimage`            | Teams section image                                                                                                                                                       | https://raw.githubusercontent.com/falcosecurity/falcosidekick/master/imgs/falcosidekick_color.png |
| `teams.outputformat`             | `all` (default), `text` (only text is displayed in Teams), `facts` (only facts are displayed in Teams)                                                                    | `all`                                                                                             |
| `teams.minimumpriority`          | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `datadog.apikey`                 | Datadog API Key, if not `empty`, Datadog output is *enabled*                                                                                                              |                                                                                                   |
| `datadog.host`                   | Datadog host. Override if you are on the Datadog EU site. Defaults to american site with "https://api.datadoghq.com"                                                      | https://api.datadoghq.com                                                                         |
| `datadog.minimumpriority`        | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `discord.webhookurl`             | Discord WebhookURL (ex: https://discord.com/api/webhooks/xxxxxxxxxx...), if not empty, Discord output is enabled                                                          |                                                                                                   |
| `discord.icon`                   | Discord icon (avatar)                                                                                                                                                     | https://raw.githubusercontent.com/falcosecurity/falcosidekick/master/imgs/falcosidekick_color.png |
| `discord.minimumpriority`        | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `alertmanager.hostport`          | AlertManager http://host:port, if not `empty`, AlertManager is *enabled*                                                                                                  |                                                                                                   |
| `alertmanager.minimumpriority`   | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `elasticsearch.hostport`         | Elasticsearch http://host:port, if not `empty`, Elasticsearch is *enabled*                                                                                                |                                                                                                   |
| `elasticsearch.index`            | Elasticsearch index                                                                                                                                                       | `falco`                                                                                           |
| `elasticsearch.type`             | Elasticsearch document type                                                                                                                                               | `event`                                                                                           |
| `elasticsearch.suffix`           | date suffix for index rotation : `daily`, `monthly`, `annually`, `none`                                                                                                   | `daily`                                                                                           |
| `elasticsearch.minimumpriority`  | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `influxdb.hostport`              | Influxdb http://host:port, if not `empty`, Influxdb is *enabled*                                                                                                          |                                                                                                   |
| `influxdb.database`              | Influxdb database                                                                                                                                                         | `falco`                                                                                           |
| `influxdb.user`                  | User to use if auth is enabled in Influxdb                                                                                                                                |                                                                                                   |
| `influxdb.password`              | Password to use if auth is enabled in Influxdb                                                                                                                            |                                                                                                   |
| `influxdb.minimumpriority`       | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `loki.hostport`                  | Loki http://host:port, if not `empty`, Loki is *enabled*                                                                                                                  |                                                                                                   |
| `loki.minimumpriority`           | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `nats.hostport`                  | NATS "nats://host:port", if not `empty`, NATS is *enabled*                                                                                                                |                                                                                                   |
| `nats.minimumpriority`           | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `aws.accesskeyid`                | AWS Access Key Id (optionnal if you use EC2 Instance Profile)                                                                                                             |                                                                                                   |
| `aws.secretaccesskey`            | AWS Secret Access Key (optionnal if you use EC2 Instance Profile)                                                                                                         |                                                                                                   |
| `aws.region`                     | AWS Region (optionnal if you use EC2 Instance Profile)                                                                                                                    |                                                                                                   |
| `aws.lambda.functionname`        | AWS Lambda Function Name, if not empty, AWS Lambda output is enabled                                                                                                      |                                                                                                   |
| `aws.lambda.minimumpriority`     | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `aws.sns.topicarn`               | AWS SNS TopicARN, if not empty, AWS SNS output is enabled                                                                                                                 |                                                                                                   |
| `aws.sns.rawjson`                | Send RawJSON from `falco` or parse it to AWS SNS                                                                                                                          |                                                                                                   |
| `aws.sns.minimumpriority`        | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `aws.sqs.url`                    | AWS SQS Queue URL, if not empty, AWS SQS output is enabled                                                                                                                |                                                                                                   |
| `aws.sqs.minimumpriority`        | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `smtp.hostport`                  | "host:port" address of SMTP server, if not empty, SMTP output is enabled                                                                                                  |                                                                                                   |
| `smtp.user`                      | user to access SMTP server                                                                                                                                                |                                                                                                   |
| `smtp.password`                  | password to access SMTP server                                                                                                                                            |                                                                                                   |
| `smtp.from`                      | Sender address (mandatory if SMTP output is enabled)                                                                                                                      |                                                                                                   |
| `smtp.to`                        | comma-separated list of Recipident addresses, can't be empty (mandatory if SMTP output is enabled)                                                                        |                                                                                                   |
| `smtp.outputformat`              | html, text                                                                                                                                                                | `html`                                                                                            |
| `smtp.minimumpriority`           | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `opsgenie.apikey`                | Opsgenie API Key, if not empty, Opsgenie output is enabled                                                                                                                |                                                                                                   |
| `opsgenie.region`                | (`us` or `eu`) region of your domain                                                                                                                                      | `us`                                                                                              |
| `opsgenie.minimumpriority`       | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `statsd.forwarder`               | The address for the StatsD forwarder, in the form http://host:port, if not empty StatsD is enabled                                                                        |                                                                                                   |
| `statsd.namespace`               | A prefix for all metrics                                                                                                                                                  | `falcosidekick`                                                                                   |
| `dogstatsd.forwarder`            | The address for the DogStatsD forwarder, in the form http://host:port, if not empty DogStatsD is enabled                                                                  |                                                                                                   |
| `dogstatsd.namespace`            | A prefix for all metrics                                                                                                                                                  | `falcosidekick`                                                                                   |
| `dogstatsd.tags`                 | A comma-separated list of tags to add to all metrics                                                                                                                      |                                                                                                   |
| `webhook.address`                | Webhook address, if not empty, Webhook output is enabled                                                                                                                  |                                                                                                   |
| `webhook.minimumpriority`        | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |
| `azure.eventhub.name`            | Name of the Hub, if not empty, EventHub is *enabled*                                                                                                                      |                                                                                                   |
| `azure.eventhub.namespace`       | Name of the space the Hub is in                                                                                                                                           |                                                                                                   |
| `azure.eventhub.minimumpriority` | minimum priority of event for using use this output, order is `emergency|alert|critical|error|warning|notice|informational|debug or ""`                                   | `debug`                                                                                           |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
helm install falcosidekick --set debug=true falcosecurity/falcosidekick
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example:

```bash
helm install falcosidekick -f values.yaml falcosecurity/falcosidekick
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Metrics

A `prometheus` endpoint can be scrapped at `/metrics`.
