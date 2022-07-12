# Event-generator

[event-generator](https://github.com/falcosecurity/event-generator) is a tool designed to generate events for both syscalls and k8s audit. The tool can be used to check if Falco is working properly. It does so by performing a variety of suspects actions which trigger security events. The event-event generator implements a [minimalistic framework](https://github.com/falcosecurity/event-generator/tree/master/events) which makes easy to implement new actions.

## Introduction

This chart helps to deploy the event-generator in a kubernetes cluster in order to test an already deployed Falco instance.

## Adding `falcosecurity` repository

Before installing the chart, add the `falcosecurity` charts repository:

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
```

## Installing the Chart

To install the chart with default values and release name `event-generator` run:

```bash
helm install event-generator falcosecurity/event-generator
```

After a few seconds, event-generator should be running in the `default` namespace.

In order to install the event-generator in a custom namespace run:

```bash
# change the name of the namespace to fit your requirements.
kubectl create ns "ns-event-generator"
helm install event-generator falcosecurity/event-generator --namespace "ns-event-generator"
```
When the event-generator is installed using the default values in `values.yaml` file it is deployed using a k8s job, running the `run` command and, generates activity only for the k8s audit. 
For more info check the next section.

> **Tip**: List all releases using `helm list`, a release is a name used to track a specific deployment

### Commands, actions and options

The event-generator tool accepts two commands: `run` and `test`. The first just generates activity, the later one, which is more sophisticated, also checks that for each generated activity Falco triggers the expected rule. Both of them accepts an argument that determines the actions to be performed:

```bash
event-generator run/test [regexp]
```

Without arguments, all actions are performed; otherwise, only those actions matching the given regular expression. If we want to `test` just the actions related to k8s the following command does the trick:

```bash
event-generator test ^k8saudit
```
The list of the supported actions can be found [here](https://github.com/falcosecurity/event-generator#list-actions)

Before diving in how this helm chart deploys and manages instances of the event-generator in kubernetes there are two more options that we need to talk about:
+ `--loop` to run actions in a loop
+ `--sleep` to set the length of time to wait before running an action (default to 1s)

### Deployment modes in k8s
Based on commands, actions and options configured the event-generator could be deployed as a k8s `job` or `deployment`. If the `config.loop` value is set a `deployment` is used since it is long running process, otherwise a `job`.
A configuration like the one below, set in the `values.yaml` file, will deploy the even-generator using a `deployment` with the `run` command passed to it and will will generate activity only for the syscalls:
```yaml
config:
  # -- The event-generator accepts two commands (run, test): 
  # run: runs actions.
  # test: runs and tests actions.
  # For more info see: https://github.com/falcosecurity/event-generator
  command: run
  # -- Regular expression used to select the actions to be run.
  actions: "^syscall"
  # -- Runs in a loop the actions.
  # If set to "true" the event-generator is deployed using a k8s deployment otherwise a k8s job.
  loop: true
  # -- The length of time to wait before running an action. Non-zero values should contain 
  # a corresponding time unit (e.g. 1s, 2m, 3h). A value of zero means no sleep. (default 100ms)
  sleep: ""
  
  grpc:
    # -- Set it to true if you are deploying in "test" mode.
    enabled: false
    # -- Path to the Falco grpc socket.
    bindAddress: "unix:///var/run/falco/falco.sock"
```

The following configuration will use a k8s `job` since we want to perform the k8s activity once and check that Falco reacts properly to those actions:
```yaml
config:
  # -- The event-generator accepts two commands (run, test): 
  # run: runs actions.
  # test: runs and tests actions.
  # For more info see: https://github.com/falcosecurity/event-generator
  command: test
  # -- Regular expression used to select the actions to be run.
  actions: "^k8saudit"
  # -- Runs in a loop the actions.
  # If set to "true" the event-generator is deployed using a k8s deployment otherwise a k8s job.
  loop: false
  # -- The length of time to wait before running an action. Non-zero values should contain 
  # a corresponding time unit (e.g. 1s, 2m, 3h). A value of zero means no sleep. (default 100ms)
  sleep: ""
  
  grpc:
    # -- Set it to true if you are deploying in "test" mode.
    enabled: true
    # -- Path to the Falco grpc socket.
    bindAddress: "unix:///var/run/falco/falco.sock"
  ```

Note that **grpc.enabled is set to true when running with the test command. Be sure that Falco exposes the grpc socket and emits output to it**.


## Uninstalling the Chart
To uninstall the `event-generator` release:
```bash
helm uninstall event-generator
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

All the configurable parameters of the event-generator chart and their default values can be found [here](./generated/helm-values.md).
