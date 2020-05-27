# Falco Helm Charts

This repo contains [helm](https://helm.sh/) charts for installing falco and related utilities.

## Usage

From git:

```bash
git clone https://github.com/falcosecurity/charts
cd charts/falco
# optional
vim values.yaml
helm install falco .
```

From helm repository:

```
helm repo add falcosecurity https://falcosecurity.github.io/charts
help repo update
helm install falco falcosecurity/falco
```

# Releases

The [helm hub](https://falcosecurity.github.io/charts) repository for falco is stored in the `gh-pages` branch of this repository. 

The repo and releases (`.tgz` files) are managed by the `release.sh` script. Once you run it:

```bash
./release.sh
```

A new `release/falco-x.y.z` branch is created, then you have to open a PR to the `gh-pages` branch as indicated by the script output.