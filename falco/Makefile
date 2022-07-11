# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

#generate helm documentation
docs: helm-docs
	$(HELM_DOCS) -t README.gotmpl -o ./generated/helm-values.md
	cat ./generated/helm-values.md >> README.md

helm-docs:
ifeq (, $(shell which helm-docs))
	@{ \
	set -e ;\
	HELM_DOCS_TMP_DIR=$$(mktemp -d) ;\
	cd $$HELM_DOCS_TMP_DIR ;\
	version=1.5.0 ;\
    arch=x86_64 ;\
    echo  $$HELM_DOCS_PATH ;\
    echo https://github.com/norwoodj/helm-docs/releases/download/v$${version}/helm-docs_$${version}_linux_$${arch}.tar.gz ;\
    curl -LO https://github.com/norwoodj/helm-docs/releases/download/v$${version}/helm-docs_$${version}_linux_$${arch}.tar.gz ;\
    tar -zxvf helm-docs_$${version}_linux_$${arch}.tar.gz ;\
    mv helm-docs $(GOBIN)/helm-docs ;\
	rm -rf $$HELM_DOCS_TMP_DIR ;\
	}
HELM_DOCS=$(GOBIN)/helm-docs
else
HELM_DOCS=$(shell which helm-docs)
endif
