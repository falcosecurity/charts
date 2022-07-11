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
