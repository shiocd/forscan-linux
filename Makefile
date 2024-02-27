# handle xauth between host<->container
XSOCK = /tmp/.X11-unix
$(shell ./xauth.sh)

# get exited container id for commit
CID=$(shell docker ps -a -f ancestor=forscan -f status=exited -q | head -1)

# OBD device unless defined by ENV
ifndef DEVICE
DEVICE=/dev/ttyUSB0
endif

# fallback OBD dummy device
NO_DEVICE=/dev/null

MSG="WARN: device $(DEVICE) does not exist, using $(NO_DEVICE) as dummy device"

all:
	@echo "Use one of the targets: clean build init config run"
	@echo

build:
	docker build -t forscan .

init:
ifneq ("$(wildcard $(DEVICE))","")
	@docker run -e DISPLAY --device $(DEVICE) -v $(shell pwd)/init.sh:/home/forscan/exec.sh --net=host forscan
	make commit
else
	@echo $(MSG)
	@docker run -e DISPLAY --device $(NO_DEVICE) -v $(shell pwd)/init.sh:/home/forscan/exec.sh --net=host forscan
	make commit
endif

config:
ifneq ("$(wildcard $(DEVICE))","")
	@docker run --device $(DEVICE) -v $(shell pwd)/run.sh:/home/forscan/exec.sh --net=host forscan
	make commit
else
	@echo $(MSG)
	@docker run --device $(NO_DEVICE) -v $(shell pwd)/run.sh:/home/forscan/exec.sh --net=host forscan
endif

run:
ifneq ("$(wildcard $(DEVICE))","")
	@docker run --rm --device $(DEVICE) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/run.sh:/home/forscan/exec.sh --net=host forscan
else
	@echo $(MSG)
	@docker run --rm --device $(NO_DEVICE) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/run.sh:/home/forscan/exec.sh --net=host forscan
endif

commit:
	docker commit $(CID) forscan
	docker rm $(CID)

clean:
	docker rmi -f forscan
