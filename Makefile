# handle xauth between host<->container
XSOCK = /tmp/.X11-unix
$(shell ./xauth.sh)

# get exited container id for commit
CID=$(shell docker ps -a -f ancestor=forscan -f status=exited -q | head -1)

# OBD device unless defined by ENV
ifndef DEV
DEV=/dev/ttyUSB0
endif

# fallback OBD dummy device
NO_DEV=/dev/null

MSG="WARN: device $(DEV) does not exist, using $(NO_DEV) as dummy device"

# Can pass as env var or as make arg to use podman/other compatible CLI instead.
CONTAINER_CLI ?= docker

all:
	@echo "Use one of the targets: clean build init winecfg config run update"
	@echo

build:
	$(CONTAINER_CLI) build -t forscan .

winecfg:
	@$(CONTAINER_CLI) run -e DISPLAY -v $(shell pwd)/winecfg.sh:/home/forscan/exec.sh --net=host forscan
	make commit

fetch:
	@$(CONTAINER_CLI) run -e DISPLAY --device $(NO_DEV) -v $(shell pwd)/fetch.sh:/home/forscan/exec.sh --net=host forscan
	make commit

init:
	make fetch
ifneq ("$(wildcard $(DEV))","")
	@$(CONTAINER_CLI) run -e DISPLAY --device $(DEV) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/init.sh:/home/forscan/exec.sh --net=host forscan
else
	@echo $(MSG)
	@$(CONTAINER_CLI) run -e DISPLAY --device $(NO_DEV) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/init.sh:/home/forscan/exec.sh --net=host forscan
endif
	make commit

config:
ifneq ("$(wildcard $(DEV))","")
	@$(CONTAINER_CLI) run --device $(DEV) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/run.sh:/home/forscan/exec.sh --net=host forscan
else
	@echo $(MSG)
	@$(CONTAINER_CLI) run --device $(NO_DEV) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/run.sh:/home/forscan/exec.sh --net=host forscan
endif
	make commit

run:
ifneq ("$(wildcard $(DEV))","")
	@$(CONTAINER_CLI) run --rm --device $(DEV) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/run.sh:/home/forscan/exec.sh --net=host forscan
else
	@echo $(MSG)
	@$(CONTAINER_CLI) run --rm --device $(NO_DEV) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/run.sh:/home/forscan/exec.sh --net=host forscan
endif

update:
	make fetch
	@$(CONTAINER_CLI) run --device $(NO_DEV) -v $(shell pwd)/install.sh:/home/forscan/exec.sh --net=host forscan
	make commit

commit:
	$(CONTAINER_CLI) commit $(CID) forscan
	$(CONTAINER_CLI) rm $(CID)

clean:
	$(CONTAINER_CLI) rmi -f forscan
