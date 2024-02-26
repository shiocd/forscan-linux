# handle xauth between host<->container
XSOCK = /tmp/.X11-unix
$(shell ./xauth.sh)

# get exited container id for commit
CID=$(shell docker ps -a -f ancestor=forscan -f status=exited -q | head -1)

# OBD device unless defined by ENV
ifndef DEVICE
DEVICE=/dev/ttyUSB0
endif

all:
	@echo "Use one of the targets: clean build init config run"
	@echo

build:
	docker build -t forscan .

init:
	@mkdir shared
	@docker run -e DISPLAY --device $(DEVICE) -v $(shell pwd)/init.sh:/home/forscan/exec.sh --net=host forscan
	make commit

config:
	@docker run --device $(DEVICE) -v $(shell pwd)/run.sh:/home/forscan/exec.sh --net=host forscan
	make commit

commit:
	docker commit $(CID) forscan
	docker rm $(CID)

run:
	@docker run --rm --device $(DEVICE) -v $(shell pwd)/shared:/home/forscan/FORScan -v $(shell pwd)/run.sh:/home/forscan/exec.sh --net=host forscan

clean:
	docker rmi -f forscan
