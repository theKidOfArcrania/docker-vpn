#!/bin/bash
set -e

PORT=1194
if [ $# -ge 1 ]; then
  PORT="$1"
  shift
fi

echo "VPN is now running at 0.0.0.0:1194"
sudo docker-compose run --rm -p $PORT:1194/udp vpn_run
