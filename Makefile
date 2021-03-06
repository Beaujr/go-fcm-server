PACKAGE_NAME := github.com/beaujr/go-fcm-server
REGISTRY := docker.io
REPO_NAME ?= go-fcm-server
APP_NAME := beaujr/$(REPO_NAME)
IMAGE_TAG ?= 0.1
GOPATH ?= $HOME/go
BUILD_TAG := build
BINPATH := ./bin
NAMESPACE := default
PORT := 1234
PLATFORM := linux/amd64,linux/arm/v7,linux/arm/v6,linux/arm64

# Path to dockerfiles directory
DOCKERFILES := build

# Go build flags
GOOS := linux
GOARCH := amd64
GIT_COMMIT := $(shell git rev-parse --short HEAD)
GOLDFLAGS := -ldflags "-X $(PACKAGE_NAME)/pkg/util.AppGitCommit=${GIT_COMMIT} -X $(PACKAGE_NAME)/pkg/util.AppVersion=${IMAGE_TAG}"

.PHONY: verify build docker_build push generate generate_verify \
	go_fcm_server go_test go_fmt e2e_test go_verify   \
	docker_build docker_push

# Alias targets
###############

build: go_mod go_test go_fcm_server # docker_build
verify: generate_verify go_verify
#push: build docker_push

# Go targets
#################
go_verify: go_fmt go_test

go_mod:
	go mod tidy
	go mod vendor

go_fcm_server:
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) go build \
		-a -tags netgo \
		-o $(BINPATH)/${APP_NAME}-$(GOOS)_$(GOARCH) \
		./

go_test:
ifeq ($(GOARCH),amd64)
	CGO_ENABLED=0 go test -v \
		-cover \
		-coverprofile=coverage.out \
		$$(go list ./... | \
			grep -v '/vendor/' | \
			grep -v '/pkg/client' \
		)
endif

coverage: go_test
	go tool cover -html=coverage.out

go_fmt:
	@set -e; \
	GO_FMT=$$(git ls-files *.go | grep -v 'vendor/' | xargs gofmt -d); \
	if [ -n "$${GO_FMT}" ] ; then \
		echo "Please run go fmt"; \
		echo "$$GO_FMT"; \
		exit 1; \
	fi


# Docker targets
################
#docker_build:
#	docker build \
#		--build-arg VCS_REF=$(GIT_COMMIT) \
#		--build-arg GOARCH=$(GOARCH) \
#		--build-arg GOOS=$(GOOS) \
#		--build-arg APP_NAME=$(REPO_NAME) \
#		-t $(REGISTRY)/$(APP_NAME):$(BUILD_TAG) \
#		-f $(DOCKERFILES)/Dockerfile \
#		./

docker_run:
	@docker run -p $(PORT):$(PORT) -v $(shell pwd)/config:/config $(REGISTRY)/$(APP_NAME):$(BUILD_TAG) -port=$(PORT)

docker_push: docker-login
	set -e; \
	docker tag $(REGISTRY)/$(APP_NAME):$(BUILD_TAG) $(APP_NAME):$(IMAGE_TAG)-$(GOARCH)-$(GIT_COMMIT) ; \
	docker push $(APP_NAME):$(IMAGE_TAG)-$(GOARCH)-$(GIT_COMMIT);
ifeq ($(GITHUB_HEAD_REF),master)
	docker tag $(APP_NAME):$(IMAGE_TAG)-$(GOARCH)-$(GIT_COMMIT) $(APP_NAME):latest_$(GOARCH)
	docker push $(APP_NAME):latest_$(GOARCH)
endif

check-docker-credentials:
ifndef DOCKER_USER
	$(error DOCKER_USER is undefined)
else
  ifndef DOCKER_PASS
	$(error DOCKER_PASS is undefined)
  endif
endif

docker_build: DOCKERFILE=Dockerfile
docker_build: PUSH=true
docker_build: TYPE=image
docker_build:
	docker buildx build \
		--build-arg VCS_REF=$(GIT_COMMIT) \
		--build-arg APP_NAME=$(REPO_NAME) \
		--tag $(REGISTRY)/$(APP_NAME):$(BUILD_TAG) \
		--platform $(PLATFORM) \
		--output "type=$(TYPE),push=$(PUSH)" \
		--file $(DOCKERFILES)/$(DOCKERFILE) \
		./


docker-login: check-docker-credentials
	@docker login -u $(DOCKER_USER) -p $(DOCKER_PASS) $(REGISTRY)