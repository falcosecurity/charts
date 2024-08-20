# k8s-metacollector

[k8s-metacollector](https://github.com/falcosecurity/k8s-metacollector) is a self-contained module that can be deployed within a Kubernetes cluster to perform the task of gathering metadata from various Kubernetes resources and subsequently transmitting this collected metadata to designated subscribers.

## Introduction

This chart installs the [k8s-metacollector](https://github.com/falcosecurity/k8s-metacollector) in a kubernetes cluster. The main application will be deployed as Kubernetes deployment with replica count equal to 1. In order for the application to work correctly the following resources will be created:
* ServiceAccount;
* ClusterRole;
* ClusterRoleBinding;
* Service;
* ServiceMonitor (optional);

*Note*: Incrementing the number of replicas is not recommended. The [k8s-metacollector](https://github.com/falcosecurity/k8s-metacollector) does not implement memory sharding techniques. Furthermore, events are distributed over `gRPC` using `streams` which does not work well with load balancing mechanisms implemented by Kubernetes.

## Adding `falcosecurity` repository

Before installing the chart, add the `falcosecurity` charts repository:

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
```

## Installing the Chart

To install the chart with default values and release name `k8s-metacollector` run:

```bash
helm install k8s-metacollector falcosecurity/k8s-metacollector --namespace metacollector --create-namespace
```

After a few seconds, k8s-metacollector should be running in the `metacollector` namespace.

### Enabling ServiceMonitor
Assuming that Prometheus scrapes only the ServiceMonitors that present a `release label` the following command will install and label the ServiceMonitor:

```bash
helm install k8s-metacollector falcosecurity/k8s-metacollector \
    --create-namespace \
    --namespace metacollector \
    --set serviceMonitor.create=true \
    --set serviceMonitor.labels.release="kube-prometheus-stack"
```

### Deploying the Grafana Dashboard
By setting `grafana.dashboards.enabled=true` the k8s-metacollector's grafana dashboard is deployed in the cluster using a configmap.
Based in Grafana's configuration, the configmap could be scraped by Grafana dashboard sidecar.
The following command will deploy the k8s-metacollector + serviceMonitor + grafana dashboard:

```bash
helm install k8s-metacollector falcosecurity/k8s-metacollector \
    --create-namespace \
    --namespace metacollector \
    --set serviceMonitor.create=true \
    --set serviceMonitor.labels.release="kube-prometheus-stack" \
    --set grafana.dashboards.enabled=true
```

## Uninstalling the Chart
To uninstall the `k8s-metacollector` release in namespace `metacollector`:
```bash
helm uninstall k8s-metacollector --namespace metacollector
```
The command removes all the Kubernetes resources associated with the chart and deletes the release.

## Configuration

The following table lists the main configurable parameters of the k8s-metacollector chart v0.1.10 and their default values. See `values.yaml` for full list.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | affinity allows pod placement based on node characteristics, or any other custom labels assigned to nodes. |
| containerSecurityContext | object | `{"capabilities":{"drop":["ALL"]}}` | containerSecurityContext holds the security settings for the container. |
| containerSecurityContext.capabilities | object | `{"drop":["ALL"]}` | capabilities fine-grained privileges that can be assigned to processes. |
| containerSecurityContext.capabilities.drop | list | `["ALL"]` | drop drops the given set of privileges. |
| fullnameOverride | string | `""` | fullNameOverride same as nameOverride but for the full name. |
| grafana | object | `{"dashboards":{"configMaps":{"collector":{"folder":"","name":"k8s-metacollector-grafana-dashboard","namespace":""}},"enabled":false}}` | grafana contains the configuration related to grafana. |
| grafana.dashboards | object | `{"configMaps":{"collector":{"folder":"","name":"k8s-metacollector-grafana-dashboard","namespace":""}},"enabled":false}` | dashboards contains configuration for grafana dashboards. |
| grafana.dashboards.configMaps | object | `{"collector":{"folder":"","name":"k8s-metacollector-grafana-dashboard","namespace":""}}` | configmaps to be deployed that contain a grafana dashboard. |
| grafana.dashboards.configMaps.collector | object | `{"folder":"","name":"k8s-metacollector-grafana-dashboard","namespace":""}` | collector contains the configuration for collector's dashboard. |
| grafana.dashboards.configMaps.collector.folder | string | `""` | folder where the dashboard is stored by grafana. |
| grafana.dashboards.configMaps.collector.name | string | `"k8s-metacollector-grafana-dashboard"` | name specifies the name for the configmap. |
| grafana.dashboards.configMaps.collector.namespace | string | `""` | namespace specifies the namespace for the configmap. |
| grafana.dashboards.enabled | bool | `false` | enabled specifies whether the dashboards should be deployed. |
| healthChecks | object | `{"livenessProbe":{"httpGet":{"path":"/healthz","port":8081},"initialDelaySeconds":45,"periodSeconds":15,"timeoutSeconds":5},"readinessProbe":{"httpGet":{"path":"/readyz","port":8081},"initialDelaySeconds":30,"periodSeconds":15,"timeoutSeconds":5}}` | healthChecks contains the configuration for liveness and readiness probes. |
| healthChecks.livenessProbe | object | `{"httpGet":{"path":"/healthz","port":8081},"initialDelaySeconds":45,"periodSeconds":15,"timeoutSeconds":5}` | livenessProbe is a diagnostic mechanism used to determine wether a container within a Pod is still running and healthy. |
| healthChecks.livenessProbe.httpGet | object | `{"path":"/healthz","port":8081}` | httpGet specifies that the liveness probe will make an HTTP GET request to check the health of the container. |
| healthChecks.livenessProbe.httpGet.path | string | `"/healthz"` | path is the specific endpoint on which the HTTP GET request will be made. |
| healthChecks.livenessProbe.httpGet.port | int | `8081` | port is the port on which the container exposes the "/healthz" endpoint. |
| healthChecks.livenessProbe.initialDelaySeconds | int | `45` | initialDelaySeconds tells the kubelet that it should wait X seconds before performing the first probe. |
| healthChecks.livenessProbe.periodSeconds | int | `15` | periodSeconds specifies the interval at which the liveness probe will be repeated. |
| healthChecks.livenessProbe.timeoutSeconds | int | `5` | timeoutSeconds is the number of seconds after which the probe times out. |
| healthChecks.readinessProbe | object | `{"httpGet":{"path":"/readyz","port":8081},"initialDelaySeconds":30,"periodSeconds":15,"timeoutSeconds":5}` | readinessProbe is a mechanism used to determine whether a container within a Pod is ready to serve traffic. |
| healthChecks.readinessProbe.httpGet | object | `{"path":"/readyz","port":8081}` | httpGet specifies that the readiness probe will make an HTTP GET request to check whether the container is ready. |
| healthChecks.readinessProbe.httpGet.path | string | `"/readyz"` | path is the specific endpoint on which the HTTP GET request will be made. |
| healthChecks.readinessProbe.httpGet.port | int | `8081` | port is the port on which the container exposes the "/readyz" endpoint. |
| healthChecks.readinessProbe.initialDelaySeconds | int | `30` | initialDelaySeconds tells the kubelet that it should wait X seconds before performing the first probe. |
| healthChecks.readinessProbe.periodSeconds | int | `15` | periodSeconds specifies the interval at which the readiness probe will be repeated. |
| healthChecks.readinessProbe.timeoutSeconds | int | `5` | timeoutSeconds is the number of seconds after which the probe times out. |
| image | object | `{"pullPolicy":"IfNotPresent","pullSecrets":[],"registry":"docker.io","repository":"falcosecurity/k8s-metacollector","tag":""}` | image is the configuration for the k8s-metacollector image. |
| image.pullPolicy | string | `"IfNotPresent"` | pullPolicy is the policy used to determine when a node should attempt to pull the container image. |
| image.pullSecrets | list | `[]` | pullSecects a list of secrets containing credentials used when pulling from private/secure registries. |
| image.registry | string | `"docker.io"` | registry is the image registry to pull from. |
| image.repository | string | `"falcosecurity/k8s-metacollector"` | repository is the image repository to pull from |
| image.tag | string | `""` | tag is image tag to pull. Overrides the image tag whose default is the chart appVersion. |
| nameOverride | string | `""` | nameOverride is the new name used to override the release name used for k8s-metacollector components. |
| namespaceOverride | string | `""` | namespaceOverride overrides the deployment namespace. It's useful for multi-namespace deployments in combined charts. |
| nodeSelector | object | `{}` | nodeSelector specifies a set of key-value pairs that must match labels assigned to nodes for the Pod to be eligible for scheduling on that node. |
| podAnnotations | object | `{}` | podAnnotations are custom annotations to be added to the pod. |
| podLabels | object | `{}` | podLabels are labels to be added to the pod. |
| podSecurityContext | object | `{"fsGroup":1000,"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` | These settings are override by the ones specified for the container when there is overlap. |
| podSecurityContext.fsGroup | int | `1000` | fsGroup specifies the group ID (GID) that should be used for the volume mounted within a Pod. |
| podSecurityContext.runAsGroup | int | `1000` | runAsGroup specifies the group ID (GID) that the containers inside the pod should run as. |
| podSecurityContext.runAsNonRoot | bool | `true` | runAsNonRoot when set to true enforces that the specified container runs as a non-root user. |
| podSecurityContext.runAsUser | int | `1000` | runAsUser specifies the user ID (UID) that the containers inside the pod should run as. |
| replicaCount | int | `1` | replicaCount is the number of identical copies of the k8s-metacollector. |
| resources | object | `{}` | resources defines the computing resources (CPU and memory) that are allocated to the containers running within the Pod. |
| service | object | `{"create":true,"ports":{"broker-grpc":{"port":45000,"protocol":"TCP","targetPort":"broker-grpc"},"health-probe":{"port":8081,"protocol":"TCP","targetPort":"health-probe"},"metrics":{"port":8080,"protocol":"TCP","targetPort":"metrics"}},"type":"ClusterIP"}` | service exposes the k8s-metacollector services to be accessed from within the cluster. ref: https://kubernetes.io/docs/concepts/services-networking/service/ |
| service.create | bool | `true` | enabled specifies whether a service should be created. |
| service.ports | object | `{"broker-grpc":{"port":45000,"protocol":"TCP","targetPort":"broker-grpc"},"health-probe":{"port":8081,"protocol":"TCP","targetPort":"health-probe"},"metrics":{"port":8080,"protocol":"TCP","targetPort":"metrics"}}` | ports denotes all the ports on which the Service will listen. |
| service.ports.broker-grpc | object | `{"port":45000,"protocol":"TCP","targetPort":"broker-grpc"}` | broker-grpc denotes a listening service named "grpc-broker" |
| service.ports.broker-grpc.port | int | `45000` | port is the port on which the Service will listen. |
| service.ports.broker-grpc.protocol | string | `"TCP"` | protocol specifies the network protocol that the Service should use for the associated port. |
| service.ports.broker-grpc.targetPort | string | `"broker-grpc"` | targetPort is the port on which the Pod is listening. |
| service.ports.health-probe | object | `{"port":8081,"protocol":"TCP","targetPort":"health-probe"}` | health-probe denotes a listening service named "health-probe" |
| service.ports.health-probe.port | int | `8081` | port is the port on which the Service will listen. |
| service.ports.health-probe.protocol | string | `"TCP"` | protocol specifies the network protocol that the Service should use for the associated port. |
| service.ports.health-probe.targetPort | string | `"health-probe"` | targetPort is the port on which the Pod is listening. |
| service.ports.metrics | object | `{"port":8080,"protocol":"TCP","targetPort":"metrics"}` | metrics denotes a listening service named "metrics". |
| service.ports.metrics.port | int | `8080` | port is the port on which the Service will listen. |
| service.ports.metrics.protocol | string | `"TCP"` | protocol specifies the network protocol that the Service should use for the associated port. |
| service.ports.metrics.targetPort | string | `"metrics"` | targetPort is the port on which the Pod is listening. |
| service.type | string | `"ClusterIP"` | type denotes the service type. Setting it to "ClusterIP" we ensure that are accessible from within the cluster. |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | serviceAccount is the configuration for the service account. |
| serviceAccount.annotations | object | `{}` | annotations to add to the service account. |
| serviceAccount.create | bool | `true` | create specifies whether a service account should be created. |
| serviceAccount.name | string | `""` | If not set and create is true, a name is generated using the full name template. |
| serviceMonitor | object | `{"create":false,"interval":"15s","labels":{},"path":"/metrics","relabelings":[],"scheme":"http","scrapeTimeout":"10s","targetLabels":[],"tlsConfig":{}}` | serviceMonitor holds the configuration for the ServiceMonitor CRD. A ServiceMonitor is a custom resource definition (CRD) used to configure how Prometheus should discover and scrape metrics from the k8s-metacollector service. |
| serviceMonitor.create | bool | `false` | create specifies whether a ServiceMonitor CRD should be created for a prometheus operator. https://github.com/coreos/prometheus-operator Enable it only if the ServiceMonitor CRD is installed in your cluster. |
| serviceMonitor.interval | string | `"15s"` | interval specifies the time interval at which Prometheus should scrape metrics from the service. |
| serviceMonitor.labels | object | `{}` | labels set of labels to be applied to the ServiceMonitor resource. If your Prometheus deployment is configured to use serviceMonitorSelector, then add the right label here in order for the ServiceMonitor to be selected for target discovery. |
| serviceMonitor.path | string | `"/metrics"` | path at which the metrics are expose by the k8s-metacollector. |
| serviceMonitor.relabelings | list | `[]` | relabelings configures the relabeling rules to apply the target’s metadata labels. |
| serviceMonitor.scheme | string | `"http"` | scheme specifies network protocol used by the metrics endpoint. In this case HTTP. |
| serviceMonitor.scrapeTimeout | string | `"10s"` | scrapeTimeout determines the maximum time Prometheus should wait for a target to respond to a scrape request. If the target does not respond within the specified timeout, Prometheus considers the scrape as failed for that target. |
| serviceMonitor.targetLabels | list | `[]` | targetLabels defines the labels which are transferred from the associated Kubernetes service object onto the ingested metrics. |
| serviceMonitor.tlsConfig | object | `{}` | tlsConfig specifies TLS (Transport Layer Security) configuration for secure communication when scraping metrics from a service. It allows you to define the details of the TLS connection, such as CA certificate, client certificate, and client key. Currently, the k8s-metacollector does not support TLS configuration for the metrics endpoint. |
| tolerations | list | `[]` | tolerations are applied to pods and allow them to be scheduled on nodes with matching taints. |
