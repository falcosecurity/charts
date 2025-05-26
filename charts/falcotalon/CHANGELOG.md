# Change Log

This file documents all notable changes to Falco Talon Helm Chart. The release
numbering uses [semantic versioning](http://semver.org).

## 0.3.0 - 2024-02-07

- bump up version to `v0.3.0`
- fix missing usage of the `imagePullSecrets`

## 0.2.3 - 2024-12-18

- add a Grafana dashboard for the Prometheus metrics 

## 0.2.1 - 2024-12-09

- bump up version to `v0.2.1` for bug fixes

## 0.2.0 - 2024-11-26
- configure pod to not rollout on configmap change
- configure pod to rollout on secret change
- add config.rulesOverride allowing users to override config rules

## 0.1.3 - 2024-11-08

- change the key for the range over the rules files

## 0.1.2 - 2024-10-14

- remove all refs to the previous org

## 0.1.1 - 2024-10-01

- Use version `0.1.1`
- Fix wrong port for the `serviceMonitor`

## 0.1.0 - 2024-09-05

- First release