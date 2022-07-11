# Falco

[Falco](https://falco.org) is a *Cloud Native Runtime Security* tool designed to detect anomalous activity in your applications. You can use Falco to monitor runtime security of your Kubernetes applications and internal components.

## Introduction

The deployment of Falco in a Kubernetes cluster is managed through a **Helm chart**. This chart manages the life cycle of Falco in a cluster by handling all the k8s objects needed by Falco to be seamlessly integrated in your environment. Based on the configuration in `values.yaml` file, the chart will render and install the required k8s objects. Keep in mind that Falco could be deployed in your cluster using a `daemonset` or a `deployment`. See next sections for more info.

## Adding `falcosecurity` repository

Before installing the chart, add the `falcosecurity` charts repository:

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
```

## Installing the Chart

To install the chart with the release name `falco` in namespace `falco` run:

```bash
kubectl create ns falco
helm install falco falcosecurity/falco --namespace falco
```

After a few minutes Falco instances should be running on all your nodes. The status of Falco pods can be inspected through *kubectl*:
```bash
kubectl get pods -n falco -o wide
```
If every thing went smoothly, you should observe an output similar to the following, indicating that all Falco instances are up and running in you cluster:

```bash
NAME          READY   STATUS    RESTARTS   AGE     IP          NODE            NOMINATED NODE   READINESS GATES
falco-57w7q   1/1     Running   0          3m12s   10.244.0.1   control-plane   <none>           <none>
falco-h4596   1/1     Running   0          3m12s   10.244.1.2   worker-node-1   <none>           <none>
falco-kb55h   1/1     Running   0          3m12s   10.244.2.3   worker-node-2   <none>           <none>
```
The cluster in our example has three nodes, one *control-plane* node and two *worker* nodes. The default configuration in `values.yaml` of our helm chart deploys Falco using a `daemonset`. That's the reason why we have one Falco pod in each node. 
> **Tip**: List all releases using `helm list`, a release is a name used to track a specific deployment

### Falco, Event Sources and Kubernetes
Starting from Falco 0.31.0 the [new plugin system](https://falco.org/docs/plugins/) is stable and production ready. The **plugin system** can be seen as the next step in the evolution of Falco. Historically, Falco monitored system events from the **kernel** trying to detect malicious behavior on Linux systems. It also had the capability to process k8s Audit Logs to detect suspicious activity in kubernetes clusters. Since Falco 0.32.0 all the related code to the k8s Audit Logs in Falco was removed and ported in a [plugin](https://github.com/falcosecurity/plugins/tree/master/plugins/k8saudit). At the time being Falco supports different event sources coming from **plugins** or the **drivers** (system events). 

Note that **multiple event sources can not be handled in the same Falco instance**. For instance, you can not have Falco deployed leveraging **drivers** for syscalls events and at the same time load **plugins**. Here you can find the [tracking issue](https://github.com/falcosecurity/falco/issues/2074) about multiple **event sources** in the same Falco instance.
If you need to handle **syscalls** and **plugins** events than consider deploying different Falco instances, one for each use case.
#### About the Driver

Falco needs a **driver** (the [kernel module](https://falco.org/docs/event-sources/drivers/#kernel-module) or the [eBPF probe](https://falco.org/docs/event-sources/drivers/#ebpf-probe)) that taps into the stream of system calls and passes that system calls to Falco. The driver must be installed on the node where Falco is running.

By default the drivers are managed using an *init container* which includes a script (`falco-driver-loader`) that either tries to build the driver on-the-fly or downloads a prebuilt driver as a fallback. Usually, no action is required.

If a prebuilt driver is not available for your distribution/kernel, Falco needs **kernel headers** installed on the host as a prerequisite to building the driver on the fly correctly. You can find instructions on installing the kernel headers for your system under the [Install section](https://falco.org/docs/getting-started/installation/) of the official documentation.

### About Plugins
[Plugins](https://falco.org/docs/plugins/) are used to extend Falco to support new **data sources**. The current **plugin framework** supports *plugins* with the following *capabilities*:

* Event sourcing capability;
* Field extraction capability;

Plugin capabilities are *composable*, we can have a single plugin with both the capabilities. Or on the other hand we can load two different plugins each with its capability, one plugin as a source of events and another as an extractor. A good example of this are the [Kubernetes Audit Events](https://github.com/falcosecurity/plugins/tree/master/plugins/k8saudit) and the [Falcosecurity Json](https://github.com/falcosecurity/plugins/tree/master/plugins/json) *plugins*. By deploying them both we have support for the **K8s Audit Logs** in Falco

Note that **the driver is not required when using plugins**. When *plugins* are enabled Falco is deployed without the *init container*.

### Deploying Falco in Kubernetes
After the clarification of the different **event sources** and how they are consumed by Falco using the **drivers** and the **plugins**, now lets discuss about how Falco is deployed in Kubernetes.

The chart deploys Falco using a `daemonset` or a `deployment` depending on the **event sources**.

####Daemonset
When using the [drivers](#about-the-driver), Falco is deployed as `daemonset`. By using a `daemonset`, k8s assures that a Falco instance will be running in each of our nodes even when we add new nodes to our cluster. So it is the perfect match when we need to monitor all the nodes in our cluster. 
Using the default values of the helm chart we get Falco deployed with the [kernel module](https://falco.org/docs/event-sources/drivers/#kernel-module).

If the [eBPF probe](https://falco.org/docs/event-sources/drivers/#ebpf-probe) is desired, we just need to set `driver.kind=ebpf` as as show in the following snippet:

```yaml
driver:
  enabled: true
  kind: ebpf
```
There are other configurations related the eBPF probe, for more info please check the `values.yaml` file. After you have made made your changes to the configuration file you just need to run:

```bash
helm install falco falcosecurity/falco --namespace "your-custom-name-space"
```

####Deployment
In the scenario when Falco is used with **plugins** as data sources, then the best option is to deploy it as a k8s `deployment`. **Plugins** could be of two types, the ones that follow the **push model** or the **pull model**. A plugin that adopts the firs model expects to receive the data from a remote source in a given endpoint. They just expose and endpoint and wait for data to be posted, for example [Kubernetes Audit Events](https://github.com/falcosecurity/plugins/tree/master/plugins/k8saudit) expects the data to be sent by the *k8s api server* when configured in such way. On the other hand other plugins that abide by the **pull model** retrieves the data from a given remote service. 
The following points explain why a k8s `deployent` is suitable when deploying Falco with plugins:

* need to be reachable when ingesting logs directly from remote services;
* need only one active replica, otherwise events will be sent/received to/from different Falco instances;


## Uninstalling the Chart

To uninstall a Falco release from your Kubernetes cluster always you helm. It will take care to remove all components deployed by the chart and clean up your environment. The following command will remove a release called `falco` in namespace `falco`;

```bash
helm uninstall falco --namespace falco
```

## Loading custom rules

Falco ships with a nice default ruleset. It is a good starting point but sooner or later, we are going to need to add custom rules which fit our needs.

So the question is: How can we load custom rules in our Falco deployment?

We are going to create a file that contains custom rules so that we can keep it in a Git repository.

```bash
cat custom-rules.yaml
```

And the file looks like this one:

```yaml
customRules:
  rules-traefik.yaml: |-
    - macro: traefik_consider_syscalls
      condition: (evt.num < 0)

    - macro: app_traefik
      condition: container and container.image startswith "traefik"

    # Restricting listening ports to selected set

    - list: traefik_allowed_inbound_ports_tcp
      items: [443, 80, 8080]

    - rule: Unexpected inbound tcp connection traefik
      desc: Detect inbound traffic to traefik using tcp on a port outside of expected set
      condition: inbound and evt.rawres >= 0 and not fd.sport in (traefik_allowed_inbound_ports_tcp) and app_traefik
      output: Inbound network connection to traefik on unexpected port (command=%proc.cmdline pid=%proc.pid connection=%fd.name sport=%fd.sport user=%user.name %container.info image=%container.image)
      priority: NOTICE

    # Restricting spawned processes to selected set

    - list: traefik_allowed_processes
      items: ["traefik"]

    - rule: Unexpected spawned process traefik
      desc: Detect a process started in a traefik container outside of an expected set
      condition: spawned_process and not proc.name in (traefik_allowed_processes) and app_traefik
      output: Unexpected process spawned in traefik container (command=%proc.cmdline pid=%proc.pid user=%user.name %container.info image=%container.image)
      priority: NOTICE
```

So next step is to use the custom-rules.yaml file for installing the Falco Helm chart.

```bash
helm install falco -f custom-rules.yaml falcosecurity/falco
```

And we will see in our logs something like:

```bash
Tue Jun  5 15:08:57 2018: Loading rules from file /etc/falco/rules.d/rules-traefik.yaml:
```

And this means that our Falco installation has loaded the rules and is ready to help us.

## Kubernetes Audit Log

The Kubernetes Audit Log is now supported via the built-in [k8saudit](https://github.com/falcosecurity/plugins/tree/master/plugins/k8saudit) plugin. It is entirely up to you to set up the [webhook backend](https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/#webhook-backend) of the Kubernetes API server to forward the Audit Log event to the Falco listening port.

The following snippet shows how to deploy Falco with the [k8saudit](https://github.com/falcosecurity/plugins/tree/master/plugins/k8saudit) plugin:
```yaml
driver:
  enabled: false

collectors:
  enabled: false

controller:
  kind: deployment

services:
  - name: k8saudit-webhook
    type: NodePort
    ports:
      - port: 9765 # See plugin open_params
        nodePort: 30007
        protocol: TCP

falco:
  rulesFile:
    - /etc/falco/k8s_audit_rules.yaml
    - /etc/falco/rules.d
  plugins:
    - name: k8saudit
      library_path: libk8saudit.so
      init_config:
        ""
        # maxEventBytes: 1048576
        # sslCertificate: /etc/falco/falco.pem
      open_params: "http://:9765/k8s-audit"
    - name: json
      library_path: libjson.so
      init_config: ""
  load_plugins: [k8saudit, json]
```
What the above configuration does is:
* disable the drivers by setting `driver.enabled=false`;
* disable the collectors by setting `collectors.enabled=false`;
* deploy the Falco using a k8s *deploment* by setting `controller.kind=deployment`;
* makes our Falco instance reachable by the `k8s api-server` by configuring a service for it in `services`;
* load the correct ruleset for our plugin in `falco.rulesFile`;
* configure the plugins to be loaded, in this case the `k8saudit` and `json`;
* and finally we add our plugins in the `load_plugins` to be loaded by Falco.

The configuration can be found in the `values-k8saudit.yaml` file ready to be used:


```bash
#make sure the falco namespace exists
kubectl create ns falco
helm install falco falcosecurity/falco --namespace falco -f ./values-k8saudit.yaml
```
After a few minutes a Falco instance should be running on your cluster. The status of Falco pod can be inspected through *kubectl*:
```bash
kubectl get pods -n falco -o wide
```
If every thing went smoothly, you should observe an output similar to the following, indicating that the Falco instance is up and running:

```bash
NAME                     READY   STATUS    RESTARTS   AGE    IP           NODE            NOMINATED NODE   READINESS GATES
falco-64484d9579-qckms   1/1     Running   0          101s   10.244.2.2   worker-node-2   <none>           <none>
```

Furthermore you can check that Falco logs through *kubectl logs*

```bash
kubectl logs -n falco falco-64484d9579-qckms
```
In the logs you should have something similar to the following, indcating that Falco has loaded the required plugins:
```bash
Fri Jul  8 16:07:24 2022: Falco version 0.32.0 (driver version 39ae7d40496793cf3d3e7890c9bbdc202263836b)
Fri Jul  8 16:07:24 2022: Falco initialized with configuration file /etc/falco/falco.yaml
Fri Jul  8 16:07:24 2022: Loading plugin (k8saudit) from file /usr/share/falco/plugins/libk8saudit.so
Fri Jul  8 16:07:24 2022: Loading plugin (json) from file /usr/share/falco/plugins/libjson.so
Fri Jul  8 16:07:24 2022: Loading rules from file /etc/falco/k8s_audit_rules.yaml:
Fri Jul  8 16:07:24 2022: Starting internal webserver, listening on port 8765
```
*Note that the support for the dynamic backend (also known as the `AuditSink` object) has been deprecated from Kubernetes and removed from this chart.*

### Manual setup with NodePort on kOps

Using `kops edit cluster`, ensure these options are present, then run `kops update cluster` and `kops rolling-update cluster`:
```yaml
spec:
  kubeAPIServer:
    auditLogMaxBackups: 1
    auditLogMaxSize: 10
    auditLogPath: /var/log/k8s-audit.log
    auditPolicyFile: /srv/kubernetes/assets/audit-policy.yaml
    auditWebhookBatchMaxWait: 5s
    auditWebhookConfigFile: /srv/kubernetes/assets/webhook-config.yaml
  fileAssets:
  - content: |
      # content of the webserver CA certificate
      # remove this fileAsset and certificate-authority from webhook-config if using http
    name: audit-ca.pem
    roles:
    - Master
  - content: |
      apiVersion: v1
      kind: Config
      clusters:
      - name: falco
        cluster:
          # remove 'certificate-authority' when using 'http'
          certificate-authority: /srv/kubernetes/assets/audit-ca.pem
          server: https://localhost:32765/k8s-audit
      contexts:
      - context:
          cluster: falco
          user: ""
        name: default-context
      current-context: default-context
      preferences: {}
      users: []
    name: webhook-config.yaml
    roles:
    - Master
  - content: |
      # ... paste audit-policy.yaml here ...
      # https://raw.githubusercontent.com/falcosecurity/evolution/master/examples/k8s_audit_config/audit-policy.yaml
    name: audit-policy.yaml
    roles:
    - Master
```
## Enabling gRPC

The Falco gRPC server and the Falco gRPC Outputs APIs are not enabled by default.
Moreover, Falco supports running a gRPC server with two main binding types:
- Over a local **Unix socket** with no authentication
- Over the **network** with mandatory mutual TLS authentication (mTLS)

> **Tip**: Once gRPC is enabled, you can deploy [falco-exporter](https://github.com/falcosecurity/falco-exporter) to export metrics to Prometheus.

### gRPC over unix socket (default)

The preferred way to use the gRPC is over a Unix socket.

To install Falco with gRPC enabled over a **unix socket**, you have to:

```shell
helm install falco \
  --set falco.grpc.enabled=true \
  --set falco.grpc_output.enabled=true \
  falcosecurity/falco
```

### gRPC over network

The gRPC server over the network can only be used with mutual authentication between the clients and the server using TLS certificates.
How to generate the certificates is [documented here](https://falco.org/docs/grpc/#generate-valid-ca).

To install Falco with gRPC enabled over the **network**, you have to:

```shell
helm install falco \
  --set falco.grpc.enabled=true \
  --set falco.grpcOutput.enabled=true \
  --set falco.grpc.unixSocketPath="" \
  --set-file certs.server.key=/path/to/server.key \
  --set-file certs.server.crt=/path/to/server.crt \
  --set-file certs.ca.crt=/path/to/ca.crt \
  falcosecurity/falco
```

## Deploy Falcosidekick with Falco

[`Falcosidekick`](https://github.com/falcosecurity/falcosidekick) can be installed with `Falco` by setting `--set falcosidekick.enabled=true`. This setting automatically configures all options of `Falco` for working with `Falcosidekick`.
All values for the configuration of `Falcosidekick` are available by prefixing them with `falcosidekick.`. The full list of available values is [here](https://github.com/falcosecurity/charts/tree/master/falcosidekick#configuration).
For example, to enable the deployment of [`Falcosidekick-UI`](https://github.com/falcosecurity/falcosidekick-ui), add `--set falcosidekick.webui.enabled=true`.

If you use a Proxy in your cluster, the requests between `Falco` and `Falcosidekick` might be captured, use the full FQDN of `Falcosidekick` by using `--set falcosidekick.fullfqdn=true` to avoid that.

## Configuration

The following table lists the configurable parameters of the Falco chart and their default values.
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity constraint for pods' scheduling. |
| certs | object | `{"ca":{"crt":""},"existingSecret":"","server":{"crt":"","key":""}}` | certificates used by webserver and grpc server. paste certificate content or use helm with --set-file or use existing secret containing key, crt, ca as well as pem bundle |
| certs.ca.crt | string | `""` | CA certificate used by gRPC, webserver and AuditSink validation. |
| certs.existingSecret | string | `""` | Existing secret containing the following key, crt and ca as well as the bundle pem. |
| certs.server.crt | string | `""` | Certificate used by gRPC and webserver. |
| certs.server.key | string | `""` | Key used by gRPC and webserver. |
| collectors.containerd.enabled | bool | `true` | Enable ContainerD support. |
| collectors.containerd.socket | string | `"/run/containerd/containerd.sock"` | The path of the ContainerD socket. |
| collectors.crio.enabled | bool | `true` | Enable CRI-O support. |
| collectors.crio.socket | string | `"/run/crio/crio.sock"` | The path of the CRI-O socket. |
| collectors.docker.enabled | bool | `true` | Enable Docker support. |
| collectors.docker.socket | string | `"/var/run/docker.sock"` | The path of the Docker daemon socket. |
| collectors.enabled | bool | `true` | Enable/disable all the metadata collectors. |
| collectors.kubernetes.apiAuth | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` | The apiAuth value is to provide the authentication method Falco should use to connect to the Kubernetes API. The argument's documentation from Falco is provided here for reference:  <bt_file> | <cert_file>:<key_file[#password]>[:<ca_cert_file>], --k8s-api-cert <bt_file> | <cert_file>:<key_file[#password]>[:<ca_cert_file>]     Use the provided files names to authenticate user and (optionally) verify the K8S API server identity.     Each entry must specify full (absolute, or relative to the current directory) path to the respective file.     Private key password is optional (needed only if key is password protected).     CA certificate is optional. For all files, only PEM file format is supported.     Specifying CA certificate only is obsoleted - when single entry is provided     for this option, it will be interpreted as the name of a file containing bearer token.     Note that the format of this command-line option prohibits use of files whose names contain     ':' or '#' characters in the file name. -- Provide the authentication method Falco should use to connect to the Kubernetes API. |
| collectors.kubernetes.apiUrl | string | `"https://$(KUBERNETES_SERVICE_HOST)"` |  |
| collectors.kubernetes.enableNodeFilter | bool | `true` | If true, only the current node (on which Falco is running) will be considered when requesting metadata of pods to the API server. Disabling this option may have a performance penalty on large clusters. |
| collectors.kubernetes.enabled | bool | `true` | Enable Kubernetes meta data collection via a connection to the Kubernetes API server. When this option is disabled, Falco falls back to the container annotations to grap the meta data. In such a case, only the ID, name, namespace, labels of the pod will be available. |
| containerSecurityContext | object | `{}` |  |
| controller.daemonset.updateStrategy.type | string | `"RollingUpdate"` |  |
| controller.deployment.replicas | int | `1` | Number of replicas when installing Falco using a deployment. Change it if you really know what you are doing. For more info check the section on Plugins in the README.md file. |
| controller.kind | string | `"daemonset"` |  |
| customRules | object | `{}` | Third party rules enabled for Falco. More info on the dedicated section in README.md file. |
| driver.ebpf | object | `{"hostNetwork":true,"leastPrivileged":true,"path":null}` | Configuration section for ebpf driver. |
| driver.ebpf.hostNetwork | bool | `true` | Needed to enable eBPF JIT at runtime for performance reasons. Can be skipped if eBPF JIT is enabled from outside the container |
| driver.ebpf.leastPrivileged | bool | `true` | Constrain Falco with capabilities instead of running a privileged container. This option is only supported with the eBPF driver and a kernel >= 5.8. Ensure the eBPF driver is enabled (i.e., setting the `driver.kind` option to `ebpf`). |
| driver.ebpf.path | string | `nil` | Path where the eBPF probe is located. It comes handy when the probe have been installed in the nodes using tools other than the init container deployed with the chart. |
| driver.enabled | bool | `true` | Set it to false if you want to deploy Falco without the drivers. Always set it to false when using Falco with plugins. |
| driver.kind | string | `"module"` | Tell Falco which driver to use. Available options: module (kernel driver) and ebpf (eBPF probe). |
| driver.loader | object | `{"enabled":true,"initContainer":{"enabled":true,"image":{"pullPolicy":"IfNotPresent","registry":"docker.io","repository":"falcosecurity/falco-driver-loader","tag":"0.32.0"}}}` | Configuration for the Falco init container. |
| driver.loader.enabled | bool | `true` | Enable/disable the init container. |
| driver.loader.initContainer.enabled | bool | `true` | Enable/disable the init container. |
| driver.loader.initContainer.image.pullPolicy | string | `"IfNotPresent"` | The image pull policy. |
| driver.loader.initContainer.image.registry | string | `"docker.io"` | The image registry to pull from. |
| driver.loader.initContainer.image.repository | string | `"falcosecurity/falco-driver-loader"` | The image repository to pull from. |
| driver.loader.initContainer.image.tag | string | `"0.32.0"` | Overrides the image tag whose default is the chart appVersion. |
| extra.args | list | `[]` | Extra command-line arguments. |
| extra.env | object | `{}` | Extra environment variables that will be pass onto Falco containers. |
| extra.initContainers | list | `[]` | Additional initContainers for Falco pods. |
| falco.buffered_outputs | bool | `false` | Whether or not output to any of the output channels below is buffered. Defaults to false |
| falco.file_output.enabled | bool | `false` | Enable file output for security notifications. |
| falco.file_output.filename | string | `"./events.txt"` | The filename for logging notifications. |
| falco.file_output.keep_alive | bool | `false` | Open file once or every time a new notification arrives. |
| falco.grpc.bind_address | string | `"unix:///var/run/falco/falco.sock"` | Bind address for the grpc server. |
| falco.grpc.enabled | bool | `false` | Enable the Falco gRPC server. |
| falco.grpc.threadiness | int | `0` | Number of threads (and context) the gRPC server will use, 0 by default, which means "auto". |
| falco.grpc_output.enabled | bool | `false` | Enable the gRPC output and events will be kept in memory until you read them with a gRPC client. |
| falco.http_output.enabled | bool | `false` | Enable http output for security notifications. |
| falco.http_output.url | string | `""` | When set, this will override an auto-generated URL which matches the falcosidekick Service. -- When including Falco inside a parent helm chart, you must set this since the auto-generated URL won't match (#280). |
| falco.http_output.user_agent | string | `"falcosecurity/falco"` |  |
| falco.json_include_output_property | bool | `true` | When using json output, whether or not to include the "output" property itself (e.g. "File below a known binary directory opened for writing (user=root ....") in the json output. |
| falco.json_include_tags_property | bool | `true` | When using json output, whether or not to include the "tags" property itself in the json output. If set to true, outputs caused by rules with no tags will have a "tags" field set to an empty array. If set to false, the "tags" field will not be included in the json output at all. |
| falco.json_output | bool | `false` | Whether to output events in json or text. |
| falco.load_plugins | list | `[]` |  |
| falco.log_level | string | `"info"` | Minimum log level to include in logs. Note: these levels are separate from the priority field of rules. This refers only to the log level of falco's internal logging. Can be one of "emergency", "alert", "critical", "error", "warning", "notice", "info", "debug". |
| falco.log_stderr | bool | `true` | Send information logs to syslog. Note these are *not* security notification logs! These are just Falco lifecycle (and possibly error) logs. |
| falco.log_syslog | bool | `true` | Send information logs to stderr. Note these are *not* security notification logs! These are just Falco lifecycle (and possibly error) logs. |
| falco.metadata_download.chunk_wait_us | int | `1000` | Sleep time (in μs) for each download chunck when fetching metadata from Kubernetes. |
| falco.metadata_download.max_mb | int | `100` | Max allowed response size (in Mb) when fetching metadata from Kubernetes. |
| falco.metadata_download.watch_freq_sec | int | `1` | Watch frequency (in seconds) when fetching metadata from Kubernetes. |
| falco.output_timeout | int | `2000` |  |
| falco.outputs.max_burst | int | `1000` | Maximum number of tokens outstanding. |
| falco.outputs.rate | int | `1` | Number of tokens gained per second. |
| falco.plugins[0].init_config | string | `""` |  |
| falco.plugins[0].library_path | string | `"libk8saudit.so"` |  |
| falco.plugins[0].name | string | `"k8saudit"` |  |
| falco.plugins[0].open_params | string | `"http://:9765/k8s-audit"` |  |
| falco.plugins[1].init_config | string | `""` |  |
| falco.plugins[1].library_path | string | `"libcloudtrail.so"` |  |
| falco.plugins[1].name | string | `"cloudtrail"` |  |
| falco.plugins[1].open_params | string | `""` |  |
| falco.plugins[2].init_config | string | `""` |  |
| falco.plugins[2].library_path | string | `"libjson.so"` |  |
| falco.plugins[2].name | string | `"json"` |  |
| falco.priority | string | `"debug"` | Minimum rule priority level to load and run. All rules having a priority more severe than this level will be loaded/run.  Can be one of "emergency", "alert", "critical", "error", "warning", "notice", "informational", "debug". |
| falco.program_output.enabled | bool | `false` | Enable program output for security notifications. |
| falco.program_output.keep_alive | bool | `false` | Start the program once or re-spawn when a notification arrives. |
| falco.program_output.program | string | `"jq '{text: .output}' | curl -d @- -X POST https://hooks.slack.com/services/XXX"` | Command to execute for program output. |
| falco.rules_file[0] | string | `"/etc/falco/falco_rules.yaml"` |  |
| falco.rules_file[1] | string | `"/etc/falco/falco_rules.local.yaml"` |  |
| falco.rules_file[2] | string | `"/etc/falco/rules.d"` |  |
| falco.stdout_output.enabled | bool | `true` | Enable stdout output for security notifications. |
| falco.syscall_event_drops.actions | list | `["log","alert"]` | Actions to be taken when system calls were dropped from the circular buffer. |
| falco.syscall_event_drops.max_burst | int | `1` | Max burst of messages emitted. |
| falco.syscall_event_drops.rate | float | `0.03333` | Rate at which log/alert messages are emitted. |
| falco.syscall_event_drops.threshold | float | `0.1` | The messages are emitted when the percentage of dropped system calls with respect the number of events in the last second is greater than the given threshold (a double in the range [0, 1]). |
| falco.syscall_event_timeouts.max_consecutives | int | `1000` | Maximum number of consecutive timeouts without an event after which you want Falco to alert. |
| falco.syslog_output.enabled | bool | `true` | Enable syslog output for security notifications. |
| falco.time_format_iso_8601 | bool | `false` | If true, the times displayed in log messages and output messages will be in ISO 8601. By default, times are displayed in the local time zone, as governed by /etc/localtime. |
| falco.watch_config_files | bool | `true` | Watch config file and rules files for modification. When a file is modified, Falco will propagate new config, by reloading itself. |
| falco.webserver.enabled | bool | `true` | Enable Falco embedded webserver. |
| falco.webserver.k8s_healthz_endpoint | string | `"/healthz"` | Endpoint where Falco exposes the health status. |
| falco.webserver.listen_port | int | `8765` | Port where Falco embedded webserver listen to connections. |
| falco.webserver.ssl_certificate | string | `"/etc/falco/falco.pem"` | Certificate bundle path for the Falco embedded webserver. |
| falco.webserver.ssl_enabled | bool | `false` | Enable SSL on Falco embedded webserver. |
| falcosidekick.enabled | bool | `false` | Enable falcosidekick deployment. |
| falcosidekick.fullfqdn | bool | `false` | Enable usage of full FQDN of falcosidekick service (useful when a Proxy is used). |
| falcosidekick.listenPort | string | `""` | Listen port. Default value: 2801 |
| fullnameOverride | string | `""` | Same as nameOverride but for the fullname. |
| healthChecks | object | `{"livenessProbe":{"initialDelaySeconds":60,"periodSeconds":15,"timeoutSeconds":5},"readinessProbe":{"initialDelaySeconds":30,"periodSeconds":15,"timeoutSeconds":5}}` | Parameters used |
| healthChecks.livenessProbe.initialDelaySeconds | int | `60` | Tells the kubelet that it should wait X seconds before performing the first probe. |
| healthChecks.livenessProbe.periodSeconds | int | `15` | Specifies that the kubelet should perform the check every x seconds. |
| healthChecks.livenessProbe.timeoutSeconds | int | `5` | Number of seconds after which the probe times out. |
| healthChecks.readinessProbe.initialDelaySeconds | int | `30` | Tells the kubelet that it should wait X seconds before performing the first probe. |
| healthChecks.readinessProbe.periodSeconds | int | `15` | Specifies that the kubelet should perform the check every x seconds. |
| healthChecks.readinessProbe.timeoutSeconds | int | `5` | Number of seconds after which the probe times out. |
| image.pullPolicy | string | `"IfNotPresent"` | The image pull policy. |
| image.registry | string | `"docker.io"` | The image registry to pull from. |
| image.repository | string | `"falcosecurity/falco-no-driver"` | The image repository to pull from |
| image.tag | string | `"0.32.0"` | The image tag to pull. Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Secrets containing credentials when pulling from private/secure registries. |
| mounts.volumeMounts | list | `[]` | A list of volumes you want to add to the Falco pods. |
| mounts.volumes | list | `[]` | A list of volumes you want to add to the Falco pods. |
| nameOverride | string | `""` | Put here the new name if you want to override the release name used for Falco components. |
| nodeSelector | object | `{}` | Selectors used to deploy Falco on a given node/nodes. |
| podAnnotations | object | `{}` | Add additional pod annotations |
| podLabels | object | `{}` | Add additional pod labels |
| podPriorityClassName | string | `nil` | Set pod priorityClassName |
| podSecurityContext | object | `{}` | Set securityContext for the pods These security settings are overriden by the ones specified for the specific containers when there is overlap. |
| rbac.create | bool | `true` |  |
| resources.limits | object | `{"cpu":"1000m","memory":"1024Mi"}` | Maximum amount of resources that Falco container could get. |
| resources.requests | object | `{"cpu":"100m","memory":"512Mi"}` | Although resources needed are subjective on the actual workload we provide a sane defaults ones. If you have more questions or concerns, please refer to #falco slack channel for more info about it. |
| scc.create | bool | `true` | Create OpenShift's Security Context Constraint. |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| services | string | `nil` | Network services configuration (scenario requirement) Add here your services to be deployed together with Falco. |
| tolerations | list | `[{"effect":"NoSchedule","key":"node-role.kubernetes.io/master"}]` | Tolerations to allow Falco to run on Kubernetes 1.6 masters. |
