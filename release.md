# Release Process

Our release process is automated using [GitHub Actions](.github/workflows/release.yml), [helm](https://github.com/helm/helm), and [chart-releaser](https://github.com/helm/chart-releaser). More details under the [Automation explained](#Automation-explained) section. Finally, the GitHub pages feature is used to host our Helm repo.

The following process describes how to release just one chart. Since this repository can host multiple charts, the same instructions apply for any of them.

## Release a chart

The automated process starts when the `version` field of any of `*/Chart.yaml` file is modified and merged into the `master` branch.

Thus, to trigger it, the following actions need to happen:

1. A user creates a PR that increases the `version` field of the `Chart.yaml` (and possibly introduces other useful changes)
2. An approver approves the PR
3. @poiana (our beloved bot) merges the PR into the `master` branch, then the CI starts

> The approvers may differ depending on the chart. Please, refer to the `OWNERS` file under the specific chart directory.

Once the CI has done its job, a new tag is live on [GitHub](https://github.com/falcosecurity/charts/releases), and the site [https://falcosecurity.github.io/charts](https://falcosecurity.github.io/charts) indexes the new chart version.

## Automation explained

By convention, we assume that each top-level directory of the [falcosecury/charts/charts](https://github.com/falcosecurity/charts/tree/master/charts) repository that contains a `Chart.yaml` is a Helm chart source directory. We may extend it also to support those charts that have source files in a different repository.

The automated release process starts when any modification added to `master` triggers CircleCI. It ends with a GitHub Pages job that publishes the updated index of our Helm repo.

### GitHub Actions workflow

We have two main workflows:

- [test](.github/workflows/test.yml): This will run whenever a PR is created; it checks the chart lint and runs tests to validate if the chart can be installed; if the chart has tests, those will run as well.
- [release](.github/workflows/release.yml): This will run whenever one or more commits, referring to a chart, is/are merged into `master` (e.g.: a PR is merged); it updates the index, generates the package and publishes it.

### GitHub Pages job

Eventually, the GitHub pages job will publish the updated index to [https://falcosecurity.github.io/charts/index.yaml](https://falcosecurity.github.io/charts/index.yaml), and the process completes.
