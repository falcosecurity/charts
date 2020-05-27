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
helm search repo | grep falco
helm install falco falcosecurity/falco
```

# Releases

The [helm hub]() repository for falco is stored in the `gh-pages` branch of this repository. The repo and releases (`.tgz` files) are managed by the `release.sh` script in the main repository.
