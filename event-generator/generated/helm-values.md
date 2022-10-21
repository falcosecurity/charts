# event-generator

A Helm chart used to deploy the event-generator in Kubernetes cluster.
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity, like the nodeSelector but with more expressive syntax. |
| config.actions | string | `"^syscall"` | Regular expression used to select the actions to be run. |
| config.command | string | `"run"` | The event-generator accepts two commands (run, test): run: runs actions. test: runs and tests actions. For more info see: https://github.com/falcosecurity/event-generator. |
| config.grpc.bindAddress | string | `"unix:///run/falco/falco.sock"` | Path to the Falco grpc socket. |
| config.grpc.enabled | bool | `false` | Set it to true if you are deploying in "test" mode. |
| config.loop | bool | `true` | Runs in a loop the actions. If set to "true" the event-generator is deployed using a k8s deployment otherwise a k8s job. |
| config.sleep | string | `""` | The length of time to wait before running an action. Non-zero values should contain a corresponding time unit (e.g. 1s, 2m, 3h). A value of zero means no sleep. (default 100ms) |
| fullnameOverride | string | `""` | Used to override the chart full name. |
| image.pullPolicy | string | `"IfNotPresent"` | Pull policy for the event-generator image |
| image.repository | string | `"falcosecurity/event-generator"` | Repository from where the image is pulled. |
| image.tag | string | `"latest"` | Images' tag to select a development/custom version of event-generator instead of a release. Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Secrets used to pull the image from a private repository. |
| nameOverride | string | `""` | Used to override the chart name. |
| nodeSelector | object | `{}` | Selectors to choose a given node where to run the pods. |
| podAnnotations | object | `{}` | Annotations to be added to the pod. |
| podSecurityContext | object | `{}` | Security context for the pod. |
| replicasCount | int | `1` | Number of replicas of the event-generator (meaningful when installed as a deployment). |
| securityContext | object | `{}` | Security context for the containers. |
| tolerations | list | `[]` | Tolerations to allow the pods to be scheduled on nodes whose taints the pod tolerates. |

