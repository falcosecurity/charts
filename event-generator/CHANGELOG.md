
# Change Log

This file documents all notable changes to `event-generator` Helm Chart. The release
numbering uses [semantic versioning](http://semver.org).

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