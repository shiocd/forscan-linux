#!/bin/bash

XAUTH=/tmp/.docker.xauth

# set up safe xauth for docker
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
