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
  --set falco.grpc_utput.enabled=true \
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
