DOCS_IMAGE_VERSION="v1.11.0"

LINT_IMAGE_VERSION="v3.8.0"

# Charts's path relative to the current directory.
CHARTS := $(wildcard ./charts/*)

CHARTS_NAMES := $(notdir $(CHARTS))

.PHONY: lint
lint: helm-repo-update $(addprefix lint-, $(CHARTS_NAMES))

lint-%:
	@docker run \
	-it \
	--workdir=/data \
	--volume $$(pwd):/data \
	quay.io/helmpack/chart-testing:$(LINT_IMAGE_VERSION) \
	ct lint --config ./ct.yaml --charts ./charts/$*
	
.PHONY: docs
docs: $(addprefix docs-, $(filter-out falco-exporter,$(CHARTS_NAMES)))

docs-%:
	@docker run \
	--rm \
	--workdir=/helm-docs \
	--volume "$$(pwd):/helm-docs" \
	-u $$(id -u) \
	jnorwood/helm-docs:$(DOCS_IMAGE_VERSION) \
	helm-docs -c ./charts/$* -t ./README.gotmpl -o ./README.md

helm-repo-update:
	helm repo update
