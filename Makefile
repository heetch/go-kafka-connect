MOCKERY_PATH :=  $(shell [ -z "$${GOBIN}" ] && echo $${GOPATH}/bin/mockery || echo $${GOBIN}/mockery; )
GO_TEST = go test -race -cover

.PHONY: build
build:
	CGO_ENABLED=0 go build -o ./bin/kc-cli -ldflags '-s' ./cmd/kc-cli

.PHONY: build-all
build-all:
	GOOS=linux CGO_ENABLED=0 go build -o ./bin/kc-cli -ldflags '-s' ./cmd/kc-cli
	GOOS=darwin CGO_ENABLED=0 go build -o ./bin/kc-cli_mac -ldflags '-s' ./cmd/kc-cli
	GOOS=windows CGO_ENABLED=0 go build -o ./bin/kc-cli.exe -ldflags '-s' ./cmd/kc-cli

.PHONY: test
test:
	$(GO_TEST) ./...

.PHONY: test-integration
test-integration: up
	$(GO_TEST) -tags=integration -count=1 ./...

.PHONY: up
up:
	docker-compose up -d
	@until $$(curl --output /dev/null --silent --head --fail http://localhost:8083); do \
		printf '.'; \
		sleep 2; \
	done
	@echo "up and running"

.PHONY: down
down:
	docker-compose down

.PHONY: update-mocks
update-mocks:
	go install github.com/vektra/mockery/v2@latest
	$(MOCKERY_PATH) --inpackage --case "underscore" --recursive --all --note "NOTE: run 'make update-mocks' from this project top folder to update this file and generate new ones."