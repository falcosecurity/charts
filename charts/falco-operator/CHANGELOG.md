# Change Log

This file documents all notable changes to the `falco-operator` Helm Chart. The
release numbering uses [semantic versioning](http://semver.org).

## Unreleased

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
