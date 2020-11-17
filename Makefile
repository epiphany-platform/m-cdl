ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

VERSION ?= latest
USER := epiphanyplatform
IMAGE := cdldp
IMAGE_NAME := $(USER)/$(IMAGE):$(VERSION)

#used for correctly setting shared folder permissions
HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)

.PHONY: build release metadata

warning:
	$(error Usage: make (build/release/metadata) )

build: guard-VERSION guard-IMAGE guard-USER
	echo $(IMAGE_NAME)
	docker build --rm \
		--build-arg ARG_M_VERSION=$(VERSION) \
		--build-arg ARG_HOST_UID=$(HOST_UID) \
		--build-arg ARG_HOST_GID=$(HOST_GID) \
		-t $(IMAGE_NAME) \
		.

run: guard-VERSION guard-IMAGE guard-USER
	echo $(IMAGE_NAME)
	mkdir -p /tmp/shared
	docker run --rm -v /tmp/shared:/shared -it $(IMAGE_NAME) $(STEP)

release: guard-VERSION guard-IMAGE guard-USER
	docker build \
		--build-arg ARG_M_VERSION=$(VERSION) \
		-t $(IMAGE_NAME) \
		.

guard-%:
	@if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

metadata: guard-IMAGE
	docker run --rm \
		-t $(IMAGE_NAME) \
		metadata
