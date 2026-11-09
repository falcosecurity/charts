# Change Log

This file documents all notable changes to the `falco-operator` Helm Chart. The
release numbering uses [semantic versioning](http://semver.org).

## v0.4.0

This section lists every change since 0.3.1. Upgrading from chart 0.3.x or earlier changes how
artifacts are delivered and requires updating the CRDs first; follow the
[migration guide](../../docs/migrations/v0.4.x-to-v0.5.0.md). Upgrading from 0.4.0-rc1 to 0.4.0-rc3
requires removing any `--artifact-operator-image` flag first; see
[upgrading from a release candidate](../../docs/migrations/v0.4.x-to-v0.5.0.md#upgrading-from-a-release-candidate).

### Breaking changes

* Update the default Falco Operator image tag to `0.5.0`. The instance operator now fetches every artifact and serves it from a central artifact Service on TCP 8082; Falco pods download artifacts from it through an `artifact-operator` sidecar, assigned per node by the new `ArtifactNode` CRD.
* Run the `artifact-operator` as a regular sidecar container instead of a restartable init container; overrides in a Falco `podTemplateSpec` must move from `initContainers` to `containers`.
* Reload Falco with SIGHUP from the sidecar: the Falco pod shares its process namespace, the sidecar runs as UID 0, and Falco mounts the host's `/sys/kernel` read-only.
* Add `enforceRequirements`, enabled by default: rules files and plugins whose declared requirements are missing or not met by the target Falco are not installed. Set it to `false` to install them anyway.
* Require `spec` on Component resources so missing component configuration is rejected at admission.
* Change the default versions of managed workloads: Falco 0.44.1 to 0.45.2, Falcosidekick 2.32.0 to 2.35.1, Falcosidekick UI 2.2.0 to 2.3.1, k8s-metacollector 0.1.2 to 0.1.5.

### Other changes

* Add optional mTLS support (`mtls.*` values) for the central artifact server and per-Falco-instance client certificates, including a bundled cert-manager Issuer/CA and trust-manager Bundle. Requires cert-manager (and trust-manager, if `mtls.createIssuer` is true) in the cluster; disabled by default.
* Add `imageRegistry` for both operators and generated workload images, preserving their versions and explicit image overrides.
* Add `clusterDomain` to configure the artifact server hostname and its TLS certificate for non-default cluster DNS domains.
* Add `artifactOperatorAppArmorUnconfined` to run the artifact-operator sidecar with the Unconfined AppArmor profile on nodes where the default profile blocks SIGHUP to Falco; disabled by default.
* Add `apiPriorityAndFairness.*` to put the artifact-operator sidecars' API requests in a bounded priority level; disabled by default, requires Kubernetes 1.29+.
* Add `artifactNodeAdmissionPolicy.enabled` to restrict each sidecar to the `ArtifactNode` of its own node; disabled by default, requires Kubernetes 1.30+.
* Grant the operator access to `ArtifactNode` resources, Leases for leader election, and cert-manager Certificates when mTLS is enabled; drop unused pod write permissions.
* Raise default `resources` to `512Mi`/`128Mi` (limits/requests memory).

### Changes since 0.4.0-rc3

* Replace the per-artifact `ArtifactNode` objects of 0.4.0-rc1 to 0.4.0-rc3 with one `ArtifactNode` per namespace and node; the operator deletes the old objects on its own.
* Remove the `--artifact-operator-image` flag; the sidecar image follows the instance operator release.
* Keep the bootstrap CA private key during certificate renewal so existing mTLS certificates remain trusted.

## v0.4.0-rc3

* Update the default Falco Operator image tag to `0.5.0-rc3`.
* Fix the artifact Service selector to target only the active leader when leader election is enabled.

## v0.4.0-rc2

* Update the default Falco Operator image tag to `0.5.0-rc2`.
* Add `enforceRequirements`, enabled by default: rules files and plugins whose declared requirements are missing or not met by the target Falco are not installed. Set it to `false` to install them anyway.

## v0.4.0-rc1

* Update the default Falco Operator image tag to `0.5.0-rc1`.
* Add optional mTLS support (`mtls.*` values) for the central artifact server and per-Falco-instance client certificates, including a bundled cert-manager Issuer/CA and trust-manager Bundle. Requires cert-manager (and trust-manager, if `mtls.createIssuer` is true) in the cluster; disabled by default.
* Add the `ArtifactNode` CRD, used to track per-node artifact state.
* Raise default `resources` to `512Mi`/`128Mi` (limits/requests memory).

## v0.3.1

* Update the default Falco Operator image tag to `0.4.1`.

## v0.3.0

* Update the default Falco Operator image tag to `0.4.0`.
* Add `excludedLabels` to stop propagating tracking labels used by external tools onto operator-generated resources, preventing repeated removal/recreation of cluster-scoped resources.
* Add `dnsPolicy` and `dnsConfig` support for the operator pod.

## v0.2.0

* Update the default Falco Operator image tag to `0.3.0`.

## v0.1.0

### Major Changes

* Initial chart source for the Falco Operator Helm Chart.
