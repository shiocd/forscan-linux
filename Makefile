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

all:
	@echo "Use one of the targets: clean build init winecfg config run update"
	@echo

build:
	docker build -t forscan .

winecfg:
	@docker run -e DISPLAY -v $(shell pwd)/winecfg.sh:/home/forscan/exec.sh --net=host forscan
	make commit

fetch:
	@docker run -e DISPLAY --device $(DEV) -v $(shell pwd)/fetch.sh:/home/forscan/exec.sh --net=host forscan
	make commit

init:
	make fetch
ifneq ("$(wildcard $(DEV))","")
	@docker run -e DISPLAY --device $(DEV) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/init.sh:/home/forscan/exec.sh --net=host forscan
else
	@echo $(MSG)
	@docker run -e DISPLAY --device $(NO_DEV) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/init.sh:/home/forscan/exec.sh --net=host forscan
endif
	make commit

config:
ifneq ("$(wildcard $(DEV))","")
	@docker run --device $(DEV) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/run.sh:/home/forscan/exec.sh --net=host forscan
else
	@echo $(MSG)
	@docker run --device $(NO_DEV) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/run.sh:/home/forscan/exec.sh --net=host forscan
endif
	make commit

run:
ifneq ("$(wildcard $(DEV))","")
	@docker run --rm --device $(DEV) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/run.sh:/home/forscan/exec.sh --net=host forscan
else
	@echo $(MSG)
	@docker run --rm --device $(NO_DEV) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/run.sh:/home/forscan/exec.sh --net=host forscan
endif

update:
	make fetch
	@docker run --device $(NO_DEV) -v $(shell pwd)/install.sh:/home/forscan/exec.sh --net=host forscan
	make commit

commit:
	docker commit $(CID) forscan
	docker rm $(CID)

clean:
	docker rmi -f forscan
