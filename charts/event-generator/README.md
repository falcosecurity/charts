# Event-generator

[event-generator](https://github.com/falcosecurity/event-generator) is a tool designed to generate events for both syscalls and k8s audit. The tool can be used to check if Falco is working properly. It does so by performing a variety of suspect actions which trigger security events. The event-generator implements a [minimalistic framework](https://github.com/falcosecurity/event-generator/tree/main/events) which makes it easy to implement new actions.

## Introduction

This chart helps to deploy the event-generator in a kubernetes cluster in order to test an already deployed Falco instance.

## Adding `falcosecurity` repository

Before installing the chart, add the `falcosecurity` charts repository:

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
```

## Installing the Chart

To install the chart with default values and release name `event-generator` run:

```bash
helm install event-generator falcosecurity/event-generator
```

After a few seconds, event-generator should be running in the `default` namespace.

In order to install the event-generator in a custom namespace run:

```bash
# change the name of the namespace to fit your requirements.
kubectl create ns "ns-event-generator"
helm install event-generator falcosecurity/event-generator --namespace "ns-event-generator"
```
With the default values in `values.yaml`, the chart deploys the event-generator as a k8s `deployment` running the `run` command against syscall actions in a loop.
For more info check the next section.

> **Tip**: List all releases using `helm list`, a release is a name used to track a specific deployment

### Commands, actions and options

The event-generator tool accepts four commands: `run`, `test`, `suite-run` and `suite-test`. `run` and `test` exercise a hardcoded set of Go-coded actions; the suite commands consume YAML-described test scenarios instead. `test` and `suite-test` additionally verify that Falco triggered the expected rule for each generated action; see the [`suite` documentation](https://github.com/falcosecurity/event-generator/blob/main/docs/event-generator_suite.md) for the YAML format.

`run` and `test` accept an argument that determines the actions to be performed:

```bash
event-generator run/test [regexp]
```

Without arguments, all actions are performed; otherwise, only those actions matching the given regular expression. If we want to `test` just the actions related to k8s the following command does the trick:

```bash
event-generator test ^k8saudit
```
The list of the supported actions can be found [here](https://github.com/falcosecurity/event-generator#list-actions).

Two more options apply to `run` and `test`:
+ `--loop` to run actions in a loop
+ `--sleep` to set the length of time to wait before running an action (default to 1s)

### Deployment modes in k8s
Based on commands, actions and options configured the event-generator could be deployed as a k8s `job` or `deployment`. If `config.loop` is set, a `deployment` is used since it is a long running process, otherwise a `job`. Suite commands always run once and therefore always render as a `job`.

For example, to run `test` once against the k8s audit actions instead of the defaults:
```yaml
config:
  command: test
  actions: "^k8saudit"
  loop: false
```

When the command is `test` or `suite-test`, the event-generator runs an HTTP server that Falco posts alerts to. The chart provisions a Service exposing this server on port `8080` by default. Falco must be configured with `http_output.enabled=true` and `http_output.url` pointing at this Service (with default settings, `http://<release-name>-event-generator.<namespace>.svc.cluster.local:8080`), and with `json_output=true` so alerts are delivered as JSON. `suite-test` additionally requires Falco to append `proc.env` to its alert output fields (`append_output[]={"extra_fields": ["proc.env"]}`), since the event-generator matches alerts back to the originating test by inspecting a test UID it propagates through the process-chain environment. TLS or mTLS is configurable via `config.http.securityMode` and `config.http.tls.existingSecret`, which must reference a Kubernetes Secret holding the cert material; if the Secret stores its entries under non-default keys, override `config.http.tls.secretKeys.{cert,key,caRoot}` to match. For `suite-test`, set `config.suite.skipOutcomeVerification: true` to disable outcome verification entirely; the HTTP server and Service are not rendered, and the suite behaves like `suite-run`.

### Test suites
The `suite-run` and `suite-test` commands consume YAML test descriptions. There are two ways to provide them: set `config.suite.descriptions` to render them inline into a chart-managed ConfigMap, or set `config.suite.existingConfigMap` to mount a ConfigMap you already created. Either way, the descriptions land at `config.suite.descriptionDir` inside the pod, and each top-level map key becomes a separate file.

Suite commands default to `securityContext.privileged: true`, since they could perform complex actions that require a wide range of capabilities. Set `securityContext.privileged: false` to opt out.

A minimal `suite-run` deployment with inline descriptions:
```yaml
config:
  command: suite-run
  loop: false
  suite:
    descriptions:
      example.yaml: |
        tests:
          - name: read_sensitive_file
            rule: Read sensitive file untrusted
            runner: HostRunner
            steps:
              - type: syscall
                name: open_etc_shadow
                syscall: open
                args: { pathname: /etc/shadow, flags: O_RDONLY }
```

See the [`suite` documentation](https://github.com/falcosecurity/event-generator/blob/main/docs/event-generator_suite.md) for the YAML format.

## Uninstalling the Chart
To uninstall the `event-generator` release:
```bash
helm uninstall event-generator
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the main configurable parameters of the event-generator chart v0.4.0 and their default values. See `values.yaml` for full list.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity, like the nodeSelector but with more expressive syntax. |
| config.actions | string | `"^syscall"` | Regular expression used to select the actions to be run. Honored only when command is `run` or `test`. |
| config.command | string | `"run"` | The event-generator accepts four commands: run: performs suspect actions. test: performs actions and verifies Falco alerts via HTTP. suite-run: runs YAML-described test suites without verification. suite-test: runs YAML-described test suites and verifies Falco alerts via HTTP. The `run` and `test` commands honor `actions`, `loop` and `sleep`; the suite commands honor the `suite` section below. Both `test` and `suite-test` additionally honor the `http` section. See https://github.com/falcosecurity/event-generator for the full reference. |
| config.http.address | string | `"0.0.0.0:8080"` | Address the HTTP server binds to inside the pod. Use 0.0.0.0:<port> so the Service can reach it. |
| config.http.securityMode | string | `"insecure"` | Security mode for the HTTP server: `insecure`, `tls` or `mtls`. |
| config.http.service.nodePort | string | `""` | Static NodePort to expose when `type` is `NodePort` or `LoadBalancer`. Leave empty to let Kubernetes pick one from the cluster's node port range automatically. |
| config.http.service.port | int | `8080` | Service port. The container listens on the port encoded in `address`. |
| config.http.service.type | string | `"ClusterIP"` | Service type used to expose the HTTP server. Falco must be able to reach this Service. |
| config.http.tls.existingSecret | string | `""` | Existing Kubernetes Secret holding the cert material. Required when `securityMode` is `tls` or `mtls`. The keys listed under `secretKeys` are projected at `/etc/falco/certs/{server.crt,server.key,ca.crt}` inside the pod and passed to the event-generator via the `--http-server-*` flags. |
| config.http.tls.secretKeys.caRoot | string | `"ca.crt"` | Secret key holding the CA root certificate (only used when `securityMode` is `mtls`). Projected at `/etc/falco/certs/ca.crt`. |
| config.http.tls.secretKeys.cert | string | `"server.crt"` | Secret key holding the server certificate. Projected at `/etc/falco/certs/server.crt`. |
| config.http.tls.secretKeys.key | string | `"server.key"` | Secret key holding the server private key. Projected at `/etc/falco/certs/server.key`. |
| config.loop | bool | `true` | Runs in a loop the actions. If set to "true", the event-generator is deployed as a k8s Deployment; otherwise as a Job. `suite-run` and `suite-test` ignore this value, resulting in the event-generator being always deployed as a Job. |
| config.sleep | string | `""` | The length of time to wait before running an action. Non-zero values should contain a corresponding time unit (e.g. 1s, 2m, 3h). A value of zero means no sleep. (default 100ms). Honored only when command is `run` or `test`. |
| config.suite.descriptionDir | string | `"/etc/event-generator/descriptions"` | In-pod mount point for the descriptions; passed to the event-generator binary as `--description-dir`. |
| config.suite.descriptions | object | `{}` | Inline YAML descriptions rendered into a chart-managed ConfigMap. Each map key becomes a file name inside `descriptionDir`; the value is the YAML content. Ignored when `existingConfigMap` is set. Example: descriptions:   my_test.yaml: |     tests:       - name: example         rule: Read sensitive file untrusted         runner: HostRunner         steps:           - type: syscall             name: open_etc_shadow             syscall: open             args: { pathname: /etc/shadow, flags: O_RDONLY } |
| config.suite.existingConfigMap | string | `""` | Existing ConfigMap holding YAML descriptions. When set, `descriptions` is ignored and the existing ConfigMap is mounted at `descriptionDir`. Each ConfigMap data key becomes a file in that directory. |
| config.suite.reportFormat | string | `"text"` | Report format for `suite-test`: `text`, `json` or `yaml`. |
| config.suite.skipOutcomeVerification | bool | `false` | Skip outcome verification (only meaningful for `suite-test`). When true, `suite-test` behaves like `suite-run` and the `http.*` settings are ignored. |
| config.suite.timeout | string | `"1m"` | Maximum duration of the test suite execution. |
| fullnameOverride | string | `""` | Used to override the chart full name. |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"falcosecurity/event-generator","tag":"latest"}` | Number of old history to retain to allow rollback (If not set, default Kubernetes value is set to 10) revisionHistoryLimit: 1 |
| image.pullPolicy | string | `"IfNotPresent"` | Pull policy for the event-generator image |
| image.repository | string | `"falcosecurity/event-generator"` | Repository from where the image is pulled. |
| image.tag | string | `"latest"` | Images' tag to select a development/custom version of event-generator instead of a release. Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Secrets used to pull the image from a private repository. |
| nameOverride | string | `""` | Used to override the chart name. |
| nodeSelector | object | `{}` | Selectors to choose a given node where to run the pods. |
| podAnnotations | object | `{}` | Annotations to be added to the pod. |
| podSecurityContext | object | `{}` | Security context for the pod. |
| replicasCount | int | `1` | Number of replicas of the event-generator (meaningful when installed as a deployment). |
| securityContext | object | `{}` | Security context for the containers. When command is `suite-run` or `suite-test`, the chart defaults `privileged: true` because those commands could perform complex actions that require a wide range of capabilities in order to properly work. Setting `privileged` explicitly here overrides that default. |
| tolerations | list | `[]` | Tolerations to allow the pods to be scheduled on nodes whose taints the pod tolerates. |
