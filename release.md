# Release Process

Our release process is automated using [CircleCI](https://app.circleci.com/pipelines/github/falcosecurity/charts), [helm](https://github.com/helm/helm), and [chart-releaser](https://github.com/helm/chart-releaser). You can find the full script [here](.circleci/release.sh) and more details under the [Automation explained](#Automation-explained) section. Finally, the GitHub pages feature is used to host our Helm repo.

The following process describes how to release just one chart. Since this repository can host multiple charts, the same instructions apply for any of them. 

## Release a chart

The automated process starts when the `version` field of any of `*/Chart.yaml` file is modified and merged into the `master` branch.

Thus, to trigger it, the following actions need to happen:

1. A user creates a PR that increases the `version` field of the `Chart.yaml` (and possibly introduces other useful changes)
2. An approver approves the PR
3. @poiana (our beloved bot) merges the PR into the `master` branch, then the CI starts

> The approvers may differ depending on the chart. Please, refer to the `OWNERS` file under the specific chart directory.

Once the CI has done its job, a new tag is live on [GitHub](https://github.com/falcosecurity/falco-exporter/releases), and the site [https://falcosecurity.github.io/charts](https://falcosecurity.github.io/charts) indexes the new chart version. 

## Automation explained

By convention, we assume that each top-level directory of the [falcosecury/charts](https://github.com/falcosecurity/charts) repository that contains a `Chart.yaml` is a Helm chart source directory. We may extend it also to support those charts that have source files in a different repository.

The automated release process starts when any modification added to `master` triggers CircleCI. It ends with a GitHub Pages job that publishes the updated index of our Helm repo.

### CircleCI workflow

The CI is configured to [install the required tools](.circleci/install_tools.sh) then to runs [.circleci/release.sh](.circleci/release.sh) script.

The script performs the following actions:

- for each `*/Chart.yaml` file found:
  - extract the `version` and the `name` attributes
  - check if a git tag in the form `<name>-<version>` (e.g. `falco-1.1.10`) is already present
    - if yes, skip the chart
    - otherwise, add the chart to the list of charts to be released 
- if the list is empty, the process stops
- for each chart in the resulting list:
    - create the chart package (using `helm package`)
- run ([chart-releaser](https://github.com/helm/chart-releaser)) to create a GitHub release and to upload the package for each packaged created by the previous step
- run ([chart-releaser](https://github.com/helm/chart-releaser)) to update the `index.yaml`, then commit and push it to the `gh-pages` branch

**N.B.**
- The name and the version of the chart are extracted from `Chart.yaml`, thus the directory name is not relevant in this process.
- The above process can release multiple charts simultaneously.

### GitHub Pages job

Eventually, the GitHub pages job will publish the updated index to [https://falcosecurity.github.io/charts/index.yaml](https://falcosecurity.github.io/charts/index.yaml), and the process completes.