# Falco Helm Charts

This GitHub project is the source for our [Helm chart repository](https://v3.helm.sh/docs/topics/chart_repository/).

The purpose of this repository is to provide a place for maintaining and contributing Charts related to the Falco project, with CI processes in place for managing the releasing of Charts into [our Helm Chart Repository]((https://falcosecurity.github.io/charts)).

For more information about installing and using Helm, see the
[Helm Docs](https://helm.sh/docs/).

## Repository Structure

This GitHub repository contains the source for the packaged and versioned charts released to [https://falcosecurity.github.io/charts](https://falcosecurity.github.io/charts) (our Helm Chart Repository).

The Charts in this repository are organized into folders: each directory that contains a `Chart.yaml` is a chart.

The Charts in the `master` branch (with a corresponding [GitHub release](https://github.com/falcosecurity/charts/releases)) match the latest packaged Charts in [our Helm Chart Repository]((https://falcosecurity.github.io/charts)), though there may be previous versions of a Chart available in that Chart Repository.

## Charts

Charts currently available are listed below.

- [falco](falco)
- [falco-exporter](falco-exporter)
- [falcosidekick](falcosidekick)

## Usage

### Adding `falcosecurity` repository

Before installing any chart provided by this repository, add the `falcosecurity` Charts Repository:

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
```

### Installing a chart

Please refer to the instruction provided by the Chart you want to install. For installing Falco via Helm, the documentation is [here](https://github.com/falcosecurity/charts/tree/master/falco#adding-falcosecurity-repository).