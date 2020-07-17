VERSION?=202004022106
SHA256?=fe0288357f0876b71c392a5c1a4ab1ea2d4236d9c27730715ce1aa6671305bb2
DOCKER_HUB_NAME?='henderiw/tacacs-plus-alpine'
ALPINE_VERSION?=1.0.0

.PHONY: alpine ubuntu tag

all: alpine

alpine:
	docker build -t tacacs-plus-alpine \
		--build-arg SRC_VERSION=$(VERSION) \
		--build-arg SRC_HASH=$(SHA256) \
		-f Dockerfile .

tag:
	docker tag tacacs-plus-alpine:latest $(DOCKER_HUB_NAME):$(ALPINE_VERSION)