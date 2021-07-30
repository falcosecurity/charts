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

## Contributing

We are glad to receive your contributions. To help you in the process, we have prepared a [CONTRIBUTING.md](https://github.com/falcosecurity/.github/blob/master/CONTRIBUTING.md), which includes detailed information on contributing to `falcosecurity` projects. Furthermore, we implemented a mechanism to automatically release and publish our charts whenever a PR is merged (if you are curious how this process works, you can find more details in our [release.md](release.md)).

So, we ask you to follow these simple steps when making your PR:

- The [DCO](https://github.com/falcosecurity/.github/blob/master/CONTRIBUTING.md#developer-certificate-of-origin) is required to contribute to a `falcosecurity` project. So ensure that all your commits have been signed off. We will not be able to merge the PR if a commit is not signed off.
- Bump the version number of the chart by modifying the `version` value in the chart's `Chart.yaml` file. This is particularly important, as it allows our CI to release a new chart version. If the version has not been increased, we will not be able to merge the PR.
- Add a new section in the chart's `CHANGELOG.md` file with the new version number of the chart.
- If your changes affect any chart variables, please update the chart's `README.md` file accordingly.

Finally, when opening your PR, please fill in the provided PR template, including the final checklist of items to indicate that all the steps above have been performed. 


If you have any questions, please feel free to contact us via [GitHub issues](https://github.com/falcosecurity/charts/issues).