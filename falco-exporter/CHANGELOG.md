# Change Log

This file documents all notable changes to `falco-exporter` Helm Chart. The release
numbering uses [semantic versioning](http://semver.org).

## v0.4.1

### Minor Changes

* Support release namespace configuration

## v0.4.0

### Mayor Changes

* Add Mutual TLS for falco-exporter enable/disabled feature

## v0.3.8

### Minor Changes

* Replace extensions apiGroup/apiVersion because of deprecation

## v0.3.7

### Minor Changes

* Fixed falco-exporter PSP by allowing secret volumes

## v0.3.6

### Minor Changes

* Add SecurityContextConstraint to allow deploying in Openshift

## v0.3.5

### Minor Changes

* Added the possibility to automatically add a PSP (in combination with a Role and a RoleBindung) via the podSecurityPolicy values
* Namespaced the falco-exporter ServiceAccount and Service

## v0.3.4

### Minor Changes

* Add priorityClassName to values

## v0.3.3

### Minor Changes

* Add grafana dashboard to helm chart

## v0.3.2

### Minor Changes

* Fix for additional labels for falco-exporter servicemonitor

## v0.3.1

### Minor Changes

* Added the support to deploy a Prometheus Service Monitor. Is disables by default.

## v0.3.0

### Major Changes

* Chart moved to [falcosecurity/charts](https://github.com/falcosecurity/charts) repository
* gRPC over unix socket support (by default)
* Updated falco-exporter version to `0.3.0`

### Minor Changes

* README.md and CHANGELOG.md added