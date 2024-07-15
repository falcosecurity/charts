
# Change Log

This file documents all notable changes to `k8s-metacollector` Helm Chart. The release
numbering uses [semantic versioning](http://semver.org).

## v0.1.10

* Fix Grafana dashboards datasources

## v0.1.9

* Add podLabels

## v0.1.8

* Bump application version to 0.1.1. For more info see release notes: https://github.com/falcosecurity/k8s-metacollector/releases/tag/v0.1.1

## v0.1.7

* Lower initial delay seconds for readiness and liveness probes;

## v0.1.6

* Add grafana dashboard;

## v0.1.5

*  Fix service monitor indentation;

## v0.1.4

*  Lower `interval` and `scrape_timeout` values for service monitor;

## v0.1.3

* Bump application version to 0.1.3

## v0.1.2

### Major Changes

* Update unit tests;

## v0.1.1

### Major Changes

* Add `work in progress` disclaimer;
* Update chart info.

## v0.1.0

### Major Changes

* Initial release of k8s-metacollector Helm Chart. **Note:** the chart uses the `main` tag, since we don't have released the k8s-metacollector yet.
