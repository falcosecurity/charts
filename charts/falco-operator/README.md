# falco-operator

[Falco Operator](https://github.com/falcosecurity/falco-operator) manages Falco deployments and Falco artifacts on Kubernetes.

## Introduction

This chart installs the Falco Operator controllers and their CRDs. The chart deploys the instance operator and configures the RBAC needed to manage Falco, Component, Rulesfile, Plugin, and Config custom resources.

## Adding `falcosecurity` repository

Before installing the published chart, add the `falcosecurity` charts repository:

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
```

## Installing the Chart

To install the chart with default values and release name `falco-operator` run:

```bash
helm install falco-operator falcosecurity/falco-operator --namespace falco-operator --create-namespace
```

After a few seconds, the Falco Operator should be running in the `falco-operator` namespace.

To install from a local checkout of the Falco Operator source repository before the chart is published:

```bash
helm install falco-operator ./chart/falco-operator --namespace falco-operator --create-namespace
```

## Uninstalling the Chart

To uninstall the `falco-operator` release:

```bash
helm uninstall falco-operator --namespace falco-operator
```

## Configuration

The following table lists the configurable parameters of the falco-operator chart v0.3.0 and their default values. See [values.yaml](values.yaml) for the full list.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules |
| dnsConfig | object | `{}` | Pod DNS config. Requires dnsPolicy to be set to None to take full effect. |
| dnsPolicy | string | `""` | Pod DNS policy. One of ClusterFirst, ClusterFirstWithHostNet, Default or None. |
| excludedLabels | list | `[]` | Label keys that must NOT be propagated onto operator-generated resources. Supports the '*' wildcard (e.g. `kustomize.toolkit.fluxcd.io/*`). |
| extraArgs | list | `[]` | Additional CLI arguments passed to the operator binary |
| extraEnv | list | `[]` | Extra environment variables |
| extraObjects | list | `[]` | Array of extra Kubernetes manifests to deploy alongside the operator. Each entry is rendered with `tpl`, so Helm templating (e.g. `{{ .Release.Name }}`) is supported within values. |
| fullnameOverride | string | `""` | Full name override for the chart |
| image.digest | string | `""` | Optional image digest (e.g. sha256:abc...). When set, takes precedence over tag and renders repository@digest. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"falcosecurity/falco-operator"` | Repository for the Falco Operator image |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | Image pull secrets |
| livenessProbe | object | `{"httpGet":{"path":"/healthz","port":"health"},"initialDelaySeconds":15,"periodSeconds":20}` | Liveness probe configuration |
| nameOverride | string | `""` | Name override for the chart |
| nodeSelector | object | `{}` | Node selector |
| podAnnotations | object | `{}` | Pod annotations |
| podLabels | object | `{}` | Pod labels |
| podSecurityContext | object | `{"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod security context |
| priorityClassName | string | `""` | Priority class name |
| rbac | object | `{"create":true}` | RBAC configuration |
| rbac.create | bool | `true` | Specifies whether RBAC resources should be created |
| readinessProbe | object | `{"httpGet":{"path":"/readyz","port":"health"},"initialDelaySeconds":5,"periodSeconds":10}` | Readiness probe configuration |
| replicaCount | int | `1` | Number of replicas for the operator. Leader election is OFF by default; to run more than 1 replica, also set `extraArgs: ["--leader-elect=true"]`. |
| resizePolicy | list | `[]` | In-place pod resize policy for the manager container |
| resources | object | `{"limits":{"cpu":"500m","memory":"128Mi"},"requests":{"cpu":"10m","memory":"64Mi"}}` | Resource limits and requests |
| revisionHistoryLimit | int | `10` | The number of old ReplicaSets to retain to allow rollback |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}` | Container security context |
| serviceAccount | object | `{"annotations":{},"automountServiceAccountToken":true,"create":true,"imagePullSecrets":[],"name":""}` | Service account configuration |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automountServiceAccountToken | bool | `true` | Automatically mount the ServiceAccount API token into pods using this ServiceAccount |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.imagePullSecrets | list | `[]` | Image pull secrets attached to the service account |
| serviceAccount.name | string | `""` | The name of the service account to use |
| tolerations | list | `[]` | Tolerations |
| topologySpreadConstraints | list | `[]` | Topology spread constraints |
| volumeMounts | list | `[]` | Additional volume mounts |
| volumes | list | `[]` | Additional volumes |
