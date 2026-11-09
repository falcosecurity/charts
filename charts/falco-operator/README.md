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

The following table lists the configurable parameters of the falco-operator chart v0.4.0 and their default values. See [values.yaml](values.yaml) for the full list.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules |
| apiPriorityAndFairness.artifactOperators.handSize | int | `6` | Queues each Falco instance's requests are spread over (shuffle sharding). |
| apiPriorityAndFairness.artifactOperators.lendablePercent | int | `50` | Part of that share other levels may borrow while the sidecars do not use it. |
| apiPriorityAndFairness.artifactOperators.matchingPrecedence | int | `1000` | FlowSchema precedence: lower matches first. Above the cluster's catch-all, below system schemas. |
| apiPriorityAndFairness.artifactOperators.namespaces | list | `[]` | Namespaces of the Falco instances, whose ServiceAccounts are the sidecars'. Empty matches the ServiceAccounts of every namespace, so any other workload using the artifact API shares the sidecars' level. |
| apiPriorityAndFairness.artifactOperators.nominalConcurrencyShares | int | `20` | Share of the API server's concurrency the sidecars are entitled to. |
| apiPriorityAndFairness.artifactOperators.queueLengthLimit | int | `50` | Requests a queue holds before further ones are rejected with 429. |
| apiPriorityAndFairness.artifactOperators.queues | int | `64` | Queues requests wait in once the level is busy; more queues isolate Falco instances better. |
| apiPriorityAndFairness.enabled | bool | `false` | Create the PriorityLevelConfiguration and FlowSchemas. |
| apiPriorityAndFairness.operator.matchingPrecedence | int | `900` | Precedence of the operator's own schema; it must match before the sidecars' one. |
| apiPriorityAndFairness.operator.priorityLevel | string | `"workload-high"` | Priority level for the operator's own artifact API requests. |
| artifactNodeAdmissionPolicy.enabled | bool | `false` | Create the ValidatingAdmissionPolicy and its binding. |
| artifactOperatorAppArmorUnconfined | bool | `false` | When true, the artifact-operator sidecar runs with the Unconfined AppArmor profile. Enable on nodes where the container runtime's default AppArmor profile blocks SIGHUP to Falco with permission denied. Requires Kubernetes 1.30 or later. Enabling it rolls the Falco pods. |
| clusterDomain | string | `"cluster.local"` | Cluster DNS domain, used for the artifact server URL and its TLS certificate. |
| dnsConfig | object | `{}` | Pod DNS config. Requires dnsPolicy to be set to None to take full effect. |
| dnsPolicy | string | `""` | Pod DNS policy. One of ClusterFirst, ClusterFirstWithHostNet, Default or None. |
| enforceRequirements | bool | `true` | When false, the artifact-operator sidecar installs artifacts regardless of Falco version or plugin dependency constraints. Useful when compatibility metadata is unavailable or incorrect. |
| excludedLabels | list | `[]` | Label keys that must NOT be propagated onto operator-generated resources. Supports the '*' wildcard (e.g. `kustomize.toolkit.fluxcd.io/*`). |
| extraArgs | list | `[]` | Additional CLI arguments passed to the operator binary. mTLS's own flags are added natively when mtls.enabled is true; no need to list them here. |
| extraEnv | list | `[]` | Extra environment variables |
| extraObjects | list | `[]` | Array of extra Kubernetes manifests to deploy alongside the operator. Each entry is rendered with `tpl`, so Helm templating (e.g. `{{ .Release.Name }}`) is supported within values. mTLS's own cert-manager/trust-manager resources are templated natively (see mtls.* above and templates/mtls.yaml); this is for anything else. |
| fullnameOverride | string | `""` | Full name override for the chart |
| image.digest | string | `""` | Optional image digest (e.g. sha256:abc...). When set, takes precedence over tag and renders repository@digest. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"falcosecurity/falco-operator"` | Repository for the Falco Operator image |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | Image pull secrets |
| imageRegistry | string | `""` | Registry host[:port][/path] for the default Docker Hub images of the operator and generated workloads. Preserves tags/digests; custom repositories and explicit images take precedence. |
| livenessProbe | object | `{"httpGet":{"path":"/healthz","port":"health"},"initialDelaySeconds":15,"periodSeconds":20}` | Liveness probe configuration |
| mtls | object | `{"caBundleConfigMapName":"","caCertDuration":"8760h","client":{"certDuration":"720h","certRenewBefore":"168h"},"createIssuer":true,"enabled":false,"issuerName":"","server":{"certDuration":"720h","certRenewBefore":"168h"},"trustLabel":"artifact.falcosecurity.dev/trust"}` | mTLS for the central artifact server and per-Falco-instance client certificates. Requires cert-manager installed in the cluster (and trust-manager too, if mtls.createIssuer is true). See internal/pkg/artifactserver and controllers/instance/falco for the Go side. |
| mtls.caBundleConfigMapName | string | `""` | Name of the ConfigMap (synced by trust-manager into every trust-labeled namespace) that both the operator's Deployment and every Falco instance's sidecar read to verify their peer's certificate through a CA rotation. Deliberately not each side's own per-instance Secret, since a Secret's bundled ca.crt only ever reflects one CA at a time, but this ConfigMap can hold two at once during a coordinated rotation. Defaults to "<fullname>-artifact-ca-bundle", the Bundle this chart creates when createIssuer is true. Set this explicitly when createIssuer is false, to reference your own trust-distribution mechanism's ConfigMap. |
| mtls.caCertDuration | string | `"8760h"` | Duration for the bootstrap CA certificate (only used when createIssuer is true). cert-manager renews it automatically, reusing its private key (rotationPolicy: Never) so existing leaf certificates remain trusted. CA key rotation requires coordinated trust-bundle and leaf-certificate updates, which this chart does not automate. |
| mtls.client.certDuration | string | `"720h"` | Duration/renewBefore for each Falco instance's per-instance client certificate. |
| mtls.createIssuer | bool | `true` | If true, this chart bootstraps its own private CA (a self-signed Issuer, a CA Certificate, and a ClusterIssuer) and a trust-manager Bundle that distributes that CA to any namespace labeled trustLabel below. The CA Secret lives in the release namespace, which must match cert-manager's --cluster-resource-namespace and trust-manager's app.trust.namespace. These are shared controller settings: do not change them blindly on an existing PKI. If false, set issuerName to an existing ClusterIssuer you manage yourself, and distribute trust to BOTH the operator and Falco namespaces (this chart creates no Bundle in that mode). See docs/installation.md for onboarding and issuance-policy requirements. |
| mtls.enabled | bool | `false` | Enable mTLS. When true: cert-manager issues this Deployment's own server certificate, the Falco controller creates a unique per-instance client certificate (with a SPIFFE URI SAN identifying the instance) for every Falco instance's artifact-operator sidecar, and the operator's ClusterRole gains permission to create cert-manager Certificate objects. When false (the default), the artifact server runs over plain HTTP without application-level authentication or namespace authorization, and has no cert-manager dependency. Mesh mTLS alone does not enable these checks; restrict access with network/mesh authorization policies. |
| mtls.issuerName | string | `""` | Name of the ClusterIssuer used to sign the server and per-instance client certificates. Defaults to "<fullname>-artifact-ca-issuer", the one this chart creates when createIssuer is true. Set this explicitly when createIssuer is false, to reference your own ClusterIssuer. |
| mtls.server.certDuration | string | `"720h"` | Duration/renewBefore for the artifact server's own leaf certificate. |
| mtls.trustLabel | string | `"artifact.falcosecurity.dev/trust"` | Label applied to namespaces that should receive the CA trust bundle via trust-manager (only relevant when createIssuer is true). A cluster admin must label BOTH the operator's namespace and every Falco namespace with this key=true before mTLS setup; this chart never labels namespaces on its own (a deliberate, explicit, admin-approves-trust step). Without it, the operator or a Falco sidecar has no CA bundle ConfigMap to mount and its pod will sit stuck in ContainerCreating. |
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
| resources | object | `{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"10m","memory":"128Mi"}}` | Resource limits and requests |
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
| volumeMounts | list | `[]` | Additional volume mounts. See the volumes note above. |
| volumes | list | `[]` | Additional volumes. mTLS's own volumes (server cert Secret + CA trust bundle ConfigMap) are added natively when mtls.enabled is true; no need to list them here. |
