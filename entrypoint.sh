#!/bin/bash

#start config generation and tunnels afterwards
/restart-tunnels.sh

#now call shell so that the container keeps running in background (and can be attached to).
#without this the container will exit as soon as this script is over...
/bin/sh