# Change Log

This file documents all notable changes to the `falco-operator` Helm Chart. The
release numbering uses [semantic versioning](http://semver.org).

## Unreleased

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
