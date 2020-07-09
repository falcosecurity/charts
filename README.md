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
helm repo update
helm install falco falcosecurity/falco
```