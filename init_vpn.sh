#!/bin/bash

set -e

mkdir -p .certs
cat > .certs/script <<EOF
#!/bin/bash
set -e
ovpn init ca
ovpn init server
EOF

chmod +x .certs/script

sudo docker-compose run --rm manage_cert /mnt/certs/script

echo "*** initialized completed ***"

rm .certs/script
