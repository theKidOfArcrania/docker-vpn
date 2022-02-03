#!/bin/bash
set -e

PORT=1194
if [ $# -ge 1 ]; then
  PORT="$1"
  shift
fi

sudo docker run -it -p $PORT:1194/udp \
  --cap-add=net_admin --rm \
  --name vpndocker \
  vpndocker run "$@"
