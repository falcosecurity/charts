
# Change Log

This file documents all notable changes to `event-generator` Helm Chart. The release
numbering uses [semantic versioning](http://semver.org).

## v0.4.0

### Major Changes

* Bump `event-generator` to `0.13.0`.
* Replace the legacy gRPC alert retriever with the HTTP one introduced in `event-generator` `0.13.0`. The `config.grpc` section has been removed and replaced by `config.http`, exposing `address`, `securityMode` (`insecure`/`tls`/`mtls`), `certFile`/`keyFile`/`caRootFile`, `existingSecret` (required for TLS/mTLS) and a `service` sub-section. The chart now renders a Service for Falco to post alerts to.
* Add support for the new `suite-run` and `suite-test` commands. The chart provisions a ConfigMap holding YAML test descriptions (either inline via `config.suite.descriptions` or via `config.suite.existingConfigMap`) and mounts it at `config.suite.descriptionDir`, passing the path to the binary as `--description-dir`. Suite commands always render as a Kubernetes Job.

## v0.3.4

* Pass `--all` flag to event-generator binary to allow disabled rules to run, e.g. the k8saudit ruleset.

## v0.3.3

* Update README.md.

## v0.3.2

* no change to the chart itself. Updated README.md and makefile.

## v0.3.1

* noop change just to test the ci

## v0.3.0

## Major Changes

* Support configuration of revisionHistoryLimit of the deployment

## v0.2.0

## Major Changes

* Changing the grpc socket path from `unix:///var/run/falco/falco.soc` to `unix:///run/falco/falco.sock`. Please note that this change is potentially a breaking change if deploying the event generator alongside Falco < 0.33.0.

### Minor Changes

* Bump event-generator to 0.10.0

## v0.1.1

### Minor Changes

* Adding `-sleep` flag to the `pod-template.yaml` 

## v0.1.0

### Major Changes

* Initial release of event-generator Helm Chart