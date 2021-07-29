# Falcosidekick

![falcosidekick](https://github.com/falcosecurity/falcosidekick/raw/master/imgs/falcosidekick_color.png)

![release](https://flat.badgen.net/github/release/falcosecurity/falcosidekick/latest?color=green) ![last commit](https://flat.badgen.net/github/last-commit/falcosecurity/falcosidekick) ![licence](https://flat.badgen.net/badge/license/MIT/blue) ![docker pulls](https://flat.badgen.net/docker/pulls/falcosecurity/falcosidekick?icon=docker)

## Description

A simple daemon for connecting [`Falco`](https://github.com/falcosecurity/falco) to your ecossytem. It takes a `Falco`'s events and
forward them to different outputs in a fan-out way.

It works as a single endpoint for as many as you want `Falco` instances :

![falco_with_falcosidekick](https://github.com/falcosecurity/falcosidekick/raw/master/imgs/falco_with_falcosidekick.png)

## Outputs

`Falcosidekick` manages a large variety of outputs with different purposes.

### Chat

- [**Slack**](https://slack.com)
- [**Rocketchat**](https://rocket.chat/)
- [**Mattermost**](https://mattermost.com/)
- [**Teams**](https://products.office.com/en-us/microsoft-teams/group-chat-software)
- [**Discord**](https://www.discord.com/)
- [**Google Chat**](https://workspace.google.com/products/chat/)

### Metrics / Observability

- [**Datadog**](https://www.datadoghq.com/)
- [**Influxdb**](https://www.influxdata.com/products/influxdb-overview/)
- [**StatsD**](https://github.com/statsd/statsd) (for monitoring of `falcosidekick`)
- [**DogStatsD**](https://docs.datadoghq.com/developers/dogstatsd/?tab=go) (for monitoring of `falcosidekick`)
- [**Prometheus**](https://prometheus.io/) (for both events and monitoring of `falcosidekick`)
- [**Wavefront**](https://www.wavefront.com)

### Alerting

- [**AlertManager**](https://prometheus.io/docs/alerting/alertmanager/)
- [**Opsgenie**](https://www.opsgenie.com/)
- [**PagerDuty**](https://pagerduty.com/)

### Logs

- [**Elasticsearch**](https://www.elastic.co/)
- [**Loki**](https://grafana.com/oss/loki)
- [**AWS CloudWatchLogs**](https://aws.amazon.com/cloudwatch/features/)
### Object Storage

- [**AWS S3**](https://aws.amazon.com/s3/features/)
- [**GCP Storage**](https://cloud.google.com/storage)

### FaaS / Serverless

- [**AWS Lambda**](https://aws.amazon.com/lambda/features/)
- [**Kubeless**](https://kubeless.io/)
- [**OpenFaaS**](https://www.openfaas.com)
- [**GCP Cloud Run**](https://cloud.google.com/run)
- [**GCP Cloud Functions**](https://cloud.google.com/functions)

### Message queue / Streaming

- [**NATS**](https://nats.io/)
- [**STAN (NATS Streaming)**](https://docs.nats.io/nats-streaming-concepts/intro)
- [**AWS SQS**](https://aws.amazon.com/sqs/features/)
- [**AWS SNS**](https://aws.amazon.com/sns/features/)
- [**GCP PubSub**](https://cloud.google.com/pubsub)
- [**Apache Kafka**](https://kafka.apache.org/)
- [**RabbitMQ**](https://www.rabbitmq.com/)
- [**Azure Event Hubs**](https://azure.microsoft.com/en-in/services/event-hubs/)
  
### Email

- **SMTP**

### Web

- **Webhook**
- [**WebUI**](https://github.com/falcosecurity/falcosidekick-ui) (a Web UI for displaying latest events in real time)

## Adding `falcosecurity` repository

Prior to install the chart, add the `falcosecurity` charts repository:

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
```

## Installing the Chart

### Install Falco + Falcosidekick + Falcosidekick-ui

To install the chart with the release name `falcosidekick` run:

```bash
helm install falcosidekick falcosecurity/falcosidekick --set webui.enabled=true
```

### With Helm chart of Falco

`Falco`, `Falcosidekick` and `Falcosidekick-ui` can be installed together in one command. All values to configure `Falcosidekick` will have to be
prefixed with `falcosidekick.`.

```bash
helm install falco falcosecurity/falco --set falcosidekick.enabled=true --set falcosidekick.webui.enabled=true
```

After a few seconds, Falcosidekick should be running.

> **Tip**: List all releases using `helm list`, a release is a name used to track a specific deployment

## Minumiun Kubernetes version

The minimum Kubernetes version required is 1.17.x

## Uninstalling the Chart

To uninstall the `falcosidekick` deployment:

```bash
helm uninstall falcosidekick
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the main configurable parameters of the Falcosidekick chart and their default values. See `values.yaml` for full list.

| Parameter                                   | Description                                                                                                                                                                            | Default                                                                                           |
| ------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `replicaCount`                              | number of running pods                                                                                                                                                                 | `1`                                                                                               |
| `podAnnotations`                            | additions annotations on the pods                                                                                                                                                      | `{}`                                                                                              |
| `listenport`                                | port to listen for daemon                                                                                                                                                              | `2801`                                                                                            |
| `config.debug`                              | if *true* all outputs will print in stdout the payload they send                                                                                                                       | `false`                                                                                           |
| `config.customfields`                       | a list of escaped comma separated custom fields to add to falco events, syntax is "key:value\,key:value"                                                                               |                                                                                                   |
| `config.mutualtlsfilespath`                 | folder which will used to store client.crt, client.key and ca.crt files for mutual tls | `"/etc/certs"`
| `config.checkcert`                          | check if ssl certificate of the output is valid                                                                                                                                        | `true`                                                                                            |
| `config.slack.webhookurl`                   | Slack Webhook URL (ex: https://hooks.slack.com/services/XXXX/YYYY/ZZZZ), if not `empty`, Slack output is *enabled*                                                                     |                                                                                                   |
| `config.slack.footer`                       | Slack Footer                                                                                                                                                                           | https://github.com/falcosecurity/falcosidekick                                                    |
| `config.slack.icon`                         | Slack icon (avatar)                                                                                                                                                                    | https://raw.githubusercontent.com/falcosecurity/falcosidekick/master/imgs/falcosidekick_color.png |
| `config.slack.username`                     | Slack username                                                                                                                                                                         | `falcosidekick`                                                                                   |
| `config.slack.outputformat`                 | `all` (default), `text` (only text is displayed in Slack), `fields` (only fields are displayed in Slack)                                                                               | `all`                                                                                             |
| `config.slack.minimumpriority`              | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.slack.messageformat`                | a Go template to format Slack Text above Attachment, displayed in addition to the output from `slack.outputformat`. If empty, no Text is displayed before Attachment                   |                                                                                                   |
| `config.rocketchat.webhookurl`              | Rocketchat Webhook URL (ex: https://XXXX/hooks/YYYY), if not `empty`, Rocketchat output is *enabled*                                                                                   |                                                                                                   |
| `config.rocketchat.icon`                    | Rocketchat icon (avatar)                                                                                                                                                               | https://raw.githubusercontent.com/falcosecurity/falcosidekick/master/imgs/falcosidekick_color.png |
| `config.rocketchat.username`                | Rocketchat username                                                                                                                                                                    | `falcosidekick`                                                                                   |
| `config.rocketchat.outputformat`            | `all` (default), `text` (only text is displayed in Rocketcaht), `fields` (only fields are displayed in Rocketchat)                                                                     | `all`                                                                                             |
| `config.rocketchat.minimumpriority`         | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.rockerchat.messageformat`           | a Go template to format Rocketchat Text above Attachment, displayed in addition to the output from `slack.outputformat`. If empty, no Text is displayed before Attachment              |                                                                                                   |
| `config.rockerchat.mutualtls`           | if true, checkcert flag will be ignored (server cert will always be checked)              |                                                                                                   |
| `config.rockerchat.checkcert`           | check if ssl certificate of the output is valid           | `true`                                                                                         |
| `config.mattermost.webhookurl`              | Mattermost Webhook URL (ex: https://XXXX/hooks/YYYY), if not `empty`, Mattermost output is *enabled*                                                                                   |                                                                                                   |
| `config.mattermost.footer`                  | Mattermost Footer                                                                                                                                                                      | https://github.com/falcosecurity/falcosidekick                                                    |
| `config.mattermost.icon`                    | Mattermost icon (avatar)                                                                                                                                                               | https://raw.githubusercontent.com/falcosecurity/falcosidekick/master/imgs/falcosidekick_color.png |
| `config.mattermost.username`                | Mattermost username                                                                                                                                                                    | `falcosidekick`                                                                                   |
| `config.mattermost.outputformat`            | `all` (default), `text` (only text is displayed in Slack), `fields` (only fields are displayed in Mattermost)                                                                          | `all`                                                                                             |
| `config.mattermost.minimumpriority`         | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.mattermost.messageformat`           | a Go template to format Mattermost Text above Attachment, displayed in addition to the output from `slack.outputformat`. If empty, no Text is displayed before Attachment              |                                                                                                   |
| `config.mattermost.mutualtls`           | if true, checkcert flag will be ignored (server cert will always be checked) |
| `config.mattermost.checkcert`           | check if ssl certificate of the output is valid   |  `true`                                                                                                 |
| `config.teams.webhookurl`                   | Teams Webhook URL (ex: https://outlook.office.com/webhook/XXXXXX/IncomingWebhook/YYYYYY"), if not `empty`, Teams output is *enabled*                                                   |                                                                                                   |
| `config.teams.activityimage`                | Teams section image                                                                                                                                                                    | https://raw.githubusercontent.com/falcosecurity/falcosidekick/master/imgs/falcosidekick_color.png |
| `config.teams.outputformat`                 | `all` (default), `text` (only text is displayed in Teams), `facts` (only facts are displayed in Teams)                                                                                 | `all`                                                                                             |
| `config.teams.minimumpriority`              | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.datadog.apikey`                     | Datadog API Key, if not `empty`, Datadog output is *enabled*                                                                                                                           |                                                                                                   |
| `config.datadog.host`                       | Datadog host. Override if you are on the Datadog EU site. Defaults to american site with "https://api.datadoghq.com"                                                                   | https://api.datadoghq.com                                                                         |
| `config.datadog.minimumpriority`            | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.discord.webhookurl`                 | Discord WebhookURL (ex: https://discord.com/api/webhooks/xxxxxxxxxx...), if not empty, Discord output is enabled                                                                       |                                                                                                   |
| `config.discord.icon`                       | Discord icon (avatar)                                                                                                                                                                  | https://raw.githubusercontent.com/falcosecurity/falcosidekick/master/imgs/falcosidekick_color.png |
| `config.discord.minimumpriority`            | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.alertmanager.hostport`              | AlertManager http://host:port, if not `empty`, AlertManager is *enabled*                                                                                                               |                                                                                                   |
| `config.alertmanager.minimumpriority`       | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.alertmanager.mutualtls`       | if true, checkcert flag will be ignored (server cert will always be checked)   |
| `config.alertmanager.checkcert`       | check if ssl certificate of the output is valid  | `true`
| `config.elasticsearch.hostport`             | Elasticsearch http://host:port, if not `empty`, Elasticsearch is *enabled*                                                                                                             |                                                                                                   |
| `config.elasticsearch.index`                | Elasticsearch index                                                                                                                                                                    | `falco`                                                                                           |
| `config.elasticsearch.type`                 | Elasticsearch document type                                                                                                                                                            | `event`                                                                                           |
| `config.elasticsearch.suffix`               | date suffix for index rotation : `daily`, `monthly`, `annually`, `none`                                                                                                                | `daily`  
| `config.elasticsearch.username`                | use this username to authenticate to Elasticsearch if the username is not empty                                                                                                                                                                 |                                                                                           |
| `config.elasticsearch.password`                 | use this password to authenticate to Elasticsearch if the password is not empty ||
| `config.elasticsearch.minimumpriority`      | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.elasticsearch.mutualtls`      | if true, checkcert flag will be ignored (server cert will always be checked)   |
| `config.elasticsearch.checkcert`      | check if ssl certificate of the output is valid  | `true`                                                                                           |
| `config.influxdb.hostport`                  | Influxdb http://host:port, if not `empty`, Influxdb is *enabled*                                                                                                                       |                                                                                                   |
| `config.influxdb.database`                  | Influxdb database                                                                                                                                                                      | `falco`                                                                                           |
| `config.influxdb.user`                      | User to use if auth is enabled in Influxdb                                                                                                                                             |                                                                                                   |
| `config.influxdb.password`                  | Password to use if auth is enabled in Influxdb                                                                                                                                         |                                                                                                   |
| `config.influxdb.minimumpriority`           | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.influxdb.mutualtls`           | if true, checkcert flag will be ignored (server cert will always be checked)   |                                                                                           |
| `config.influxdb.checkcert`           | check if ssl certificate of the output is valid  | `true`                                                                                            |
| `config.loki.hostport`                      | Loki http://host:port, if not `empty`, Loki is *enabled*                                                                                                                               |                                                                                                   |
| `config.loki.minimumpriority`               | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.loki.mutualtls`               | if true, checkcert flag will be ignored (server cert will always be checked)   |                                                                                           |
| `config.loki.checkcert`               | check if ssl certificate of the output is valid  | `true`                                                                                            |
| `config.nats.hostport`                      | NATS "nats://host:port", if not `empty`, NATS is *enabled*                                                                                                                             |                                                                                                   |
| `config.nats.mutualtls`                      | if true, checkcert flag will be ignored (server cert will always be checked)   |                                                                                                               |                                                                                                   |
| `config.nats.checkcert`                      | check if ssl certificate of the output is valid  | `true`                                                                                                    |
| `config.nats.minimumpriority`               | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.stan.hostport`                      | Stan nats://{domain or ip}:{port}, if not empty, STAN output is *enabled*                                                                                                              |                                                                                                   |
| `config.stan.clusterid`                     | Cluster name, if not empty, STAN output is *enabled*                                                                                                                                   | `debug`                                                                                           |
| `config.stan.clientid`                      | Client ID, if not empty, STAN output is *enabled*                                                                                                                                      |                                                                                                   |
| `config.stan.mutualtls`                      | if true, checkcert flag will be ignored (server cert will always be checked)   |                                                                                                                                      |                                                                                                   |
| `config.stan.checkcert`                      | check if ssl certificate of the output is valid  | `true`                                                                                                                                 |                                                                                                   |
| `config.stan.minimumpriority`               | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.aws.accesskeyid`                    | AWS Access Key Id (optionnal if you use EC2 Instance Profile)                                                                                                                          |                                                                                                   |
| `config.aws.rolearn`                    | AWS IAM role ARN for falcosidekick service account to associate with (optionnal if you use EC2 Instance Profile)                                                                                                                          |                                                                                                   |
| `config.aws.secretaccesskey`                | AWS Secret Access Key (optionnal if you use EC2 Instance Profile)                                                                                                                      |                                                                                                   |
| `config.aws.region`                         | AWS Region (optionnal if you use EC2 Instance Profile)                                                                                                                                 |                                                                                                   |
| `config.aws.cloudwatchlogs.loggroup`        | AWS CloudWatch Logs Group name, if not empty, CloudWatch Logs output is enabled                                                                                                        |                                                                                                   |
| `config.aws.cloudwatchlogs.logstream`       | AWS CloudWatch Logs Stream name, if empty, Falcosidekick will try to create a log stream                                                                                               | `debug`                                                                                           |
| `config.aws.cloudwatchlogs.minimumpriority` | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.aws.lambda.functionname`            | AWS Lambda Function Name, if not empty, AWS Lambda output is enabled                                                                                                                   |                                                                                                   |
| `config.aws.lambda.minimumpriority`         | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.aws.sns.topicarn`                   | AWS SNS TopicARN, if not empty, AWS SNS output is enabled                                                                                                                              |                                                                                                   |
| `config.aws.sns.rawjson`                    | Send RawJSON from `falco` or parse it to AWS SNS                                                                                                                                       |                                                                                                   |
| `config.aws.sns.minimumpriority`            | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.aws.sqs.url`                        | AWS SQS Queue URL, if not empty, AWS SQS output is enabled                                                                                                                             |                                                                                                   |
| `config.aws.sqs.minimumpriority`            | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                       |
| `config.aws.s3.bucket`                      | AWS S3, bucket name                                        |  |
| `config.aws.s3.prefix`                      | AWS S3, name of prefix, keys will have format: s3://<bucket>/<prefix>/YYYY-MM-DD/YYYY-MM-DDTHH:mm:ss.s+01:00.json                                                                          |                                                                                                   |
| `config.aws.s3.minimumpriority`             | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug` 
| `config.smtp.hostport`                      | "host:port" address of SMTP server, if not empty, SMTP output is enabled                                                                                                               |                                                                                                   |
| `config.smtp.user`                          | user to access SMTP server                                                                                                                                                             |                                                                                                   |
| `config.smtp.password`                      | password to access SMTP server                                                                                                                                                         |                                                                                                   |
| `config.smtp.from`                          | Sender address (mandatory if SMTP output is enabled)                                                                                                                                   |                                                                                                   |
| `config.smtp.to`                            | comma-separated list of Recipident addresses, can't be empty (mandatory if SMTP output is enabled)                                                                                     |                                                                                                   |
| `config.smtp.outputformat`                  | html, text                                                                                                                                                                             | `html`                                                                                            |
| `config.smtp.minimumpriority`               | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.opsgenie.apikey`                    | Opsgenie API Key, if not empty, Opsgenie output is enabled                                                                                                                             |                                                                                                   |
| `config.opsgenie.region`                    | (`us` or `eu`) region of your domain                                                                                                                                                   | `us`                                                                                              |
| `config.opsgenie.mutualtls`                    | if true, checkcert flag will be ignored (server cert will always be checked)   |                                                                                                                                                   | `us`                                                                                              |
| `config.opsgenie.checkcert`                    | check if ssl certificate of the output is valid  | `true`                                                                                                                                                  | `us`                                                                                              |
| `config.opsgenie.minimumpriority`           | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.statsd.forwarder`                   | The address for the StatsD forwarder, in the form http://host:port, if not empty StatsD is enabled                                                                                     |                                                                                                   |
| `config.statsd.namespace`                   | A prefix for all metrics                                                                                                                                                               | `falcosidekick`                                                                                   |
| `config.dogstatsd.forwarder`                | The address for the DogStatsD forwarder, in the form http://host:port, if not empty DogStatsD is enabled                                                                               |                                                                                                   |
| `config.dogstatsd.namespace`                | A prefix for all metrics                                                                                                                                                               | `falcosidekick`                                                                                   |
| `config.dogstatsd.tags`                     | A comma-separated list of tags to add to all metrics                                                                                                                                   |                                                                                                   |
| `config.webhook.address`                    | Webhook address, if not empty, Webhook output is enabled                                                                                                                               |                                                                                                   |
| `config.webhook.customHeaders`              | a list of comma separated custom headers to add, syntax is "key:value\,key:value"                                                                                                       |                                                                                                   |
| `config.webhook.mutualtls`              | if true, checkcert flag will be ignored (server cert will always be checked)   |                                                                                                       |                                                                                                   |
| `config.webhook.checkcert`              | check if ssl certificate of the output is valid  | `true`                                                                                                       |                                                                                                   |
| `config.webhook.minimumpriority`            | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.azure.eventHub.name`                | Name of the Hub, if not empty, EventHub is *enabled*                                                                                                                                   |                                                                                                   |
| `config.azure.eventHub.namespace`           | Name of the space the Hub is in                                                                                                                                                        |                                                                                                   |
| `config.azure.eventHub.minimumpriority`     | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.gcp.credentials`                    | Base64 encoded JSON key file for the GCP service account                                                                                                                               |                                                                                                   |
| `config.gcp.pubsub.projectid`               | ID of the GCP project                                                                                                                                                                  |                                                                                                   |
| `config.gcp.pubsub.topic`                   | Name of the Pub/Sub topic                                                                                                                                                              |                                                                                                   |
| `config.gcp.eventhub.minimumpriority`       | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.gcp.storage.prefix`                 | Name of prefix, keys will have format: gs://<bucket>/<prefix>/YYYY-MM-DD/YYYY-MM-DDTHH:mm:ss.s+01:00.json                                                                                                                                                      |                                                                                                   |
| `config.gcp.storage.bucket`                 | The name of the bucket                                                                                                                                                              |                                                                                                   |
| `config.gcp.storage.minimumpriority`       | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |                                                                                                   |
| `config.gcp.cloudfunctions.name`                 | The name of the Cloud Function which is in form `projects/<project_id>/locations/<region>/functions/<function_name>`                                                          |                                                                                                   |
| `config.gcp.cloudfunctions.minimumpriority`       | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                |                                                                                                   |
| `config.gcp.cloudrun.enpoint`                 |  the URL of the Cloud Run function                                                       |                                                                                                   |
| `config.gcp.cloudrun.jwt`                 |  JWT for the private access to Cloud Run function                                                       |                                                                                                   |
| `config.gcp.cloudrun.minimumpriority`       | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                |                                                                                              |
| `config.googlechat.webhookurl`              | Google Chat Webhook URL (ex: https://chat.googleapis.com/v1/spaces/XXXXXX/YYYYYY), if not `empty`, Google Chat output is *enabled*                                                     |                                                                                                   |
| `config.googlechat.outputformat`            | `all` (default), `text` (only text is displayed in Google chat)                                                                                                                        | `all`                                                                                             |
| `config.googlechat.minimumpriority`         | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.googlechat.messageformat`           | a Go template to format Google Chat Text above Attachment, displayed in addition to the output from `config.googlechat.outputformat`. If empty, no Text is displayed before Attachment |                                                                                                   |
| `config.kafka.hostport`                          | The Host:Port of the Kafka (ex: kafka:9092). if not empty, Kafka output is *enabled*                                           |                                                                                                   |
| `config.kafka.topic`                        | `all` (default), `text` (only text is displayed in Google chat)                                                                                                                        | `all`                                                                                             |
| `config.kafka.partition`                    | a Go template to format Google Chat Text above Attachment, displayed in addition to the output from `config.googlechat.outputformat`. If empty, no Text is displayed before Attachment |                                                                                                   |
| `config.kafka.minimumpriority`              | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.pagerduty.routingkey`                   | Pagerduty Routing Key, if not empty, Pagerduty output is enabled                                                                                                                           |                                                                                                   |                                                                   |                                                                                                   |
| `config.pagerduty.minimumpriority`          | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.kubeless.function`                         | Name of Kubeless function, if not empty, EventHub is *enabled*                                                                                                                         |                                                                                                   |
| `config.kubeless.namespace`                        | Namespace of Kubeless function (mandatory)                                                                                                                                             |                                                                                                   |
| `config.kubeless.port`                             | Port of service of Kubeless function. Default is `8080`                                                                                                                                |                                                                                                   |
| `config.kubeless.mutualtls`                             | if true, checkcert flag will be ignored (server cert will always be checked)   |                                                                                                                                |                                                                                                   |
| `config.kubeless.checkcert`                             | check if ssl certificate of the output is valid  | `true`                                                                                                                                |                                                                                                   |
| `config.kubeless.minimumpriority`                  | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.openfaas.functionname`                     | Name of OpenFaaS function, if not empty, OpenFaaS is enabled                                                                                                                         |                                                                                                   |
| `config.openfaas.functionnamespace`                | Namespace of OpenFaaS function, "openfaas-fn" (default)                                                                                                                                             | `openfaas-fn`
| `config.openfaas.gatewayservice`                   | Service of OpenFaaS Gateway, "gateway" (default)                                                                                                                         |  `gateway`                                                                                                 |
| `config.openfaas.gatewayport`                      | Port of service of OpenFaaS Gateway Default is `8080`                                                                                                                                |  `8080`                                                                                            |
| `config.openfaas.gatewaynamespace`                 | Namespace of OpenFaaS Gateway, "openfaas" (default)                                                                                                                                             |                                                                                                   | `openfaas`
| `config.openfaas.mutualtls`                 | if true, checkcert flag will be ignored (server cert will always be checked)   |                                                                                                                                            |                                                                                                   | `openfaas`
| `config.openfaas.checkcert`                 | check if ssl certificate of the output is valid  | `true`                                                                                                                                             |                                                                                                   | `openfaas`
| `config.openfaas.minimumpriority`                  | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.cloudevents.address`                       | CloudEvents consumer http address, if not empty, CloudEvents output is *enabled*                                                                                                       |                                                                                                   |
| `config.cloudevents.extension`                     | Extensions to add in the outbound Event, useful for routing                                                                                                                            |                                                                                                   |
| `config.cloudevents.minimumpriority`               | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.rabbitmq.url`                              | Rabbitmq URL, if not empty, Rabbitmq output is *enabled*                                                                                                       |                                                                                                   |
| `config.rabbitmq.queue`                     | Rabbitmq Queue name                                                                                                                          |                                                                                                   |
| `config.rabbitmq.minimumpriority`               | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `config.wavefront.endpointtype`   | Wavefront endpoint type, must be 'direct' or 'proxy'. If not empty, with endpointhost, Wavefront output is enabled
| `config.wavefront.endpointhost`   | Wavefront endpoint address (only the host). If not empty, with endpointhost, Wavefront output is enabled
| `config.wavefront.endpointtoken`   | Wavefront token. Must be used only when endpointtype is 'direct'
| `config.wavefront.endpointmetricport`   | Port to send metrics. Only used when endpointtype is 'proxy' | 2878
| `config.wavefront.metricname`   | Metric to be created in Wavefront. Defaults to falco.alert | falco.alert
| `config.wavefront.batchsize`   | Wavefront batch size. If empty uses the default 10000. Only used when endpointtype is 'direct' | 10000
| `config.wavefront.flushintervalseconds`   | Wavefront flush interval in seconds. Defaults to 1 | 1
| `config.wavefront.minimumpriority`  | minimum priority of event for using use this output, order is `emergency\|alert\|critical\|error\|warning\|notice\|informational\|debug or ""`                                                | `debug`                                                                                           |
| `image.registry`                                 | The image registry to pull from                                                                  | `docker.io`                        |
| `image.repository`                               | The image repository to pull from                                                                | `falcosecurity/falcosidekick`     |
| `image.tag`                                      | The image tag to pull                                                                            | `2.23.1`                            |
| `image.pullPolicy`                               | The image pull policy                                                                            | `IfNotPresent`                     |
| `webui.darkmode`                             | enable Falcosidekick-UI darkmode                                                                                                                                                                | `false`                                                                                           |
| `webui.enabled`                             | enable Falcosidekick-UI                                                                                                                                                                | `false`                                                                                           |
| `webui.image.registry`                                 | The web UI image registry to pull from                                                                  | `docker.io`                        |
| `webui.image.repository`                               | The web UI image repository to pull from                                                                | `falcosecurity/falcosidekick-ui`     |
| `webui.image.tag`                                      | The web UI image tag to pull                                                                            | `v1.1.0`                            |
| `webui.image.pullPolicy`                               | The web UI image pull policy                                                                            | `IfNotPresent`                     |
| `extraVolumes`                               | Extra volumes for sidekick deployment                                                                            |                                  |
| `extraVolumeMounts`                               | Extra volume mounts for sidekick deployment                                                                            |                                  |



Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

> **Tip**: You can use the default [values.yaml](values.yaml)

## Metrics

A `prometheus` endpoint can be scrapped at `/metrics`.
