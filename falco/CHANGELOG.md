# Change Log

This file documents all notable changes to Falco Helm Chart. The release
numbering uses [semantic versioning](http://semver.org).

## v1.16.0

* Upgrade to Falco 0.30.0 (see the [Falco changelog](https://github.com/falcosecurity/falco/blob/0.30.0/CHANGELOG.md))
* Update rulesets from Falco 0.30.0
* Add `kubernetesSupport.enableNodeFilter` configuration to enable node filtering when requesting pods metadata from Kubernetes
* Add `falco.metadataDownload` configuration for fine-tuning container orchestrator metadata fetching params
* Add `falco.jsonIncludeTagsProperty` configuration to include tags in the JSON output

## v1.15.7

* Removed `maxSurge` reference from comment in Falco's `values.yaml` file.

## v1.15.6

* Update `Falcosidekick` chart to 0.3.13

## v1.15.4

* Update `Falcosidekick` chart to 0.3.12

## v1.15.3

* Upgrade to Falco 0.29.1 (see the [Falco changelog](https://github.com/falcosecurity/falco/blob/0.29.1/CHANGELOG.md))
* Update rulesets from Falco 0.29.1

## v1.15.2

* Add ability to use an existing secret of key, cert, ca as well as pem bundle instead of creating it from files

## v1.15.1

* Fixed liveness and readiness probes schema when ssl is enabled

## v1.14.1

* Update `Falcosidekick` chart to 0.3.8

## v1.14.1

* Update image tag to 0.29.0 in values.yaml

## v1.14.0

* Upgrade to Falco 0.29.0 (see the [Falco changelog](https://github.com/falcosecurity/falco/blob/0.29.0/CHANGELOG.md))
* Update rulesets from Falco 0.29.0

## v1.13.2

* Fixed incorrect spelling of `fullfqdn`

## v1.13.1

* Fix port for readinessProbe and livenessProbe

## v1.13.0

* Add liveness and readiness probes to Falco

## v1.12.0

* Add `kubernetesSupport` configuration to make Kubernetes Falco support optional in the daemonset (enabled by default)

## v1.11.1

* Upgrade to Falco 0.28.1 (see the [Falco changelog](https://github.com/falcosecurity/falco/blob/0.28.1/CHANGELOG.md))

## v1.11.0

* Bump up version of chart for `Falcosidekick` dependency to `v3.5.0`

## v1.10.0

* Add `falcosidekick.fullfqdn` option to connect `falco` to `falcosidekick` with full FQDN
* Bump up version of chart for `Falcosidekick` dependency

## v1.9.0

* Upgrade to Falco 0.28.0 (see the [Falco changelog](https://github.com/falcosecurity/falco/blob/0.28.0/CHANGELOG.md))
* Update rulesets from Falco 0.28.0

## v1.8.1

* Bump up version of chart for `Falcosidekick` dependency

## v1.8.0

* Bump up version of chart for `Falcosidekick` dependency

## v1.7.10

* Update rule `Write below monitored dir` description

## v1.7.9

* Add a documentation section about the driver

## v1.7.8

* Increase CPU limit default value

## v1.7.7

* Add a documentation section about using init containers

## v1.7.6

* Correct icon URL
## v1.7.5

* Update downstream sidekick chart

## v1.7.4

* Add `ebpf.probe.path` configuration option

## v1.7.3

* Bump up version of chart for `Falcosidekick` dependency

## v1.7.2

* Fix `falco` configmap when `Falcosidekick` is enabled, wrong service name was used

## v1.7.1

* Correct image tag for Falco 0.27.0

## v1.7.0

* Upgrade to Falco 0.27.0 (see the [Falco changelog](https://github.com/falcosecurity/falco/blob/0.27.0/CHANGELOG.md))
* Add `falco.output_timeout` configuration setting

## v1.6.1

### Minor Changes

* Add `falcosidekick` as an optional dependency

## v1.6.0

### Minor Changes

* Remove deprecated integrations (see [#123](https://github.com/falcosecurity/charts/issues/123))

## v1.5.8

### Minor Changes

* Add value `extraVolumes`, allow adding extra volumes to falco daemonset
* Add value `extraVolumeMounts`, allow adding extra volumeMounts to falco container in falco daemonset

## v1.5.6

### Minor Changes

* Add `falco.webserver.sslEnabled` config, enabling SSL support
* Add `falco.webserver.nodePort` configuration as an alternative way for exposing the AuditLog webhook (disabled by default)

## v1.5.5

### Minor Changes

* Support release namespace configuration

## v1.5.4

### Minor Changes

* Upgrade to Falco 0.26.2, `DRIVERS_REPO` now defaults to https://download.falco.org/driver (see the [Falco changelog](https://github.com/falcosecurity/falco/blob/0.26.2/CHANGELOG.md))

## v1.5.3

### Minor Changes

* Deprecation notice for gcscc, natsOutput, snsOutput, pubsubOutput integrations
* Clean up old references from documentation

## v1.5.2

### Minor Changes

* Add Pod Security Policy Support for the fake event generator

## v1.5.1

### Minor Changes

* Replace extensions apiGroup/apiVersion because of deprecation

## v1.5.0

### Minor Changes

* Upgrade to Falco 0.26.1
* Update ruleset from Falco 0.26.1
* Automatically set the appropriate apiVersion for rbac

## v1.4.0

### Minor Changes

* Allow adding InitContainers to Falco pod with `extraInitContainers` configuration
   
## v1.3.0

### Minor Changes

* Upgrade to Falco 0.25.0
* Update ruleset from Falco 0.25.0

## v1.2.3

### Minor Changes

* Fix duplicate mount point problem when both gRPC and NATS integrations are enabled

## v1.2.2

### Minor Changes

* Allow configuration using values for `imagePullSecrets` setting 
* Add `docker.io/falcosecurity/falco` image to `falco_privileged_images` macro

## v1.2.1

### Minor Changes

* Add SecurityContextConstraint to allow deploying in Openshift

## v1.2.0

### Minor Changes

* Upgrade to Falco 0.24.0
* Update ruleset from Falco 0.24.0
* gRPC Unix Socket support
* Set default threadiness to 0 ("auto" behavior) for the gRPC server

## v1.1.10

### Minor Changes

* Switch to `falcosecurity/event-generator`
* Allow configuration using values for `fakeEventGenerator.args` setting
* Update ruleset
* New releasing mechanism

## v1.1.9

### Minor Changes

* Add missing privileges for the apps Kubernetes API group
* Allow client config url for Audit Sink with `auditLog.dynamicBackend.url`

## v1.1.8

### Minor Changes

* Upgrade to Falco 0.23.0
* Correct socket path for `--cri` flag 
* Always mount `/etc` (required by `falco-driver-loader`)

## v1.1.7

### Minor Changes

* Add pod annotation support for daemonset

## v1.1.6

### Minor Changes

* Upgrade to Falco 0.21.0
* Upgrade rules to Falco 0.21.0

## v1.1.5

### Minor Changes

* Add headless service for gRPC server
* Allow gRPC certificates configuration by using `--set-file`

## v1.1.4

### Minor Changes

* Make `/lib/modules` writable from the container

## v1.1.3

### Minor Changes

* Allow configuration using values for `grpc` setting
* Allow configuration using values for `grpc_output` setting

## v1.1.2

### Minor Changes

* Upgrade to Falco 0.20.0
* Upgrade rules to Falco 0.20.0

## v1.1.1

### Minor Changes

* Upgrade to Falco 0.19.0
* Upgrade rules to Falco 0.19.0
* Remove Sysdig references, Falco is a project by its own name

## v1.1.0

### Minor Changes

* Revamp auditLog feature
* Upgrade to latest version (0.18.0)
* Replace CRI references with containerD

## v1.0.12

### Minor Changes

* Support multiple lines for `falco.programOutput.program`

## v1.0.11

### Minor Changes

* Add affinity

## v1.0.10

### Minor Changes

* Migrate API versions from deprecated, removed versions to support Kubernetes v1.16

## v1.0.9

### Minor Changes

* Restrict the access to `/dev` on underlying host to read only

## v1.0.8

### Minor Changes

* Upgrade to Falco 0.17.1
* Upgrade rules to Falco 0.17.1

## v1.0.7

### Minor Changes

* Allow configuration using values for `nodeSelector` setting

## v1.0.6

### Minor Changes

* Falco does a rollingUpgrade when the falco or falco-rules configMap changes
  with a helm upgrade

## v1.0.5

### Minor Changes

* Add 3 resources (`daemonsets`, `deployments`, `replicasets`) to the ClusterRole resource list
  Ref: [PR#514](https://github.com/falcosecurity/falco/pull/514) from Falco repository

## v1.0.4

### Minor Changes

* Upgrade to Falco 0.17.0
* Upgrade rules to Falco 0.17.0

## v1.0.3

### Minor Changes

* Support [`priorityClassName`](https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/)

## v1.0.2

### Minor Changes

* Upgrade to Falco 0.16.0
* Upgrade rules to Falco 0.16.0

## v1.0.1

### Minor Changes

* Extra environment variables passed to daemonset pods

## v1.0.0

### Major Changes

* Add support for K8s audit logging

## v0.9.1

### Minor Changes

* Allow configuration using values for `time_format_iso8601` setting
* Allow configuration using values for `syscall_event_drops` setting
* Allow configuration using values for `http_output` setting
* Add CHANGELOG entry for v0.8.0, [not present on its PR](https://github.com/helm/charts/pull/14813#issuecomment-506821432)

## v0.9.0

### Major Changes

* Add nestorsalceda as an approver

## v0.8.0

### Major Changes

* Allow configuration of Pod Security Policy. This is needed to get Falco
  running when the Admission Controller is enabled.

## v0.7.10

### Minor Changes

* Fix bug with Google Cloud Security Command Center and Falco integration

## v0.7.9

### Minor Changes

* Upgrade to Falco 0.15.3
* Upgrade rules to Falco 0.15.3

## v0.7.8

### Minor Changes

* Add TZ parameter for time correlation in Falco logs

## v0.7.7

### Minor Changes

* Upgrade to Falco 0.15.1
* Upgrade rules to Falco 0.15.1

## v0.7.6

### Major Changes

* Allow to enable/disable usage of the docker socket
* Configurable docker socket path
* CRI support, configurable CRI socket
* Allow to enable/disable usage of the CRI socket

## v0.7.5

### Minor Changes

* Upgrade to Falco 0.15.0
* Upgrade rules to Falco 0.15.0

## v0.7.4

### Minor Changes

* Use the KUBERNETES_SERVICE_HOST environment variable to connect to Kubernetes
  API instead of using a fixed name

## v0.7.3

### Minor Changes

* Remove the toJson pipeline when storing Google Credentials. It makes strange
  stuff with double quotes and does not allow to use base64 encoded credentials

## v0.7.2

### Minor Changes

* Fix typos in README.md

## v0.7.1

### Minor Changes

* Add Google Pub/Sub Output integration

## v0.7.0

### Major Changes

* Disable eBPF by default on Falco. We activated eBPF by default to make the
  CI pass, but now we found a better method to make the CI pass without
  bothering our users.

## v0.6.0

### Major Changes

* Upgrade to Falco 0.14.0
* Upgrade rules to Falco 0.14.0
* Enable eBPF by default on Falco
* Allow to download Falco images from different registries than `docker.io`
* Use rollingUpdate strategy by default
* Provide sane defauls for falco resource management

## v0.5.6

### Minor Changes

* Allow extra container args

## v0.5.5

### Minor Changes

* Update correct slack example

## v0.5.4

### Minor Changes

* Using Falco version 0.13.0 instead of latest.

## v0.5.3

### Minor Changes

* Update falco_rules.yaml file to use the same rules that Falco 0.13.0

## v0.5.2

### Minor Changes

* Falco was accepted as a CNCF project. Fix references and download image from
  falcosecurity organization.

## v0.5.1

### Minor Changes

* Allow falco to resolve cluster hostnames when running with ebpf.hostNetwork: true

## v0.5.0

### Major Changes

* Add Amazon SNS Output integration

## v0.4.0

### Major Changes

* Allow Falco to be run with a HTTP proxy server

## v0.3.1

### Minor Changes

* Mount in memory volume for shm. It was used in volumes but was not mounted.

## v0.3.0

### Major Changes

* Add eBPF support for Falco. Falco can now read events via an eBPF program
  loaded into the kernel instead of the `falco-probe` kernel module.

## v0.2.1

### Minor Changes

* Update falco_rules.yaml file to use the same rules that Falco 0.11.1

## v0.2.0

### Major Changes

* Add NATS Output integration

### Minor Changes

* Fix value mismatch between code and documentation

## v0.1.1

### Minor Changes

* Fix several typos

## v0.1.0

### Major Changes

* Initial release of Sysdig Falco Helm Chart
