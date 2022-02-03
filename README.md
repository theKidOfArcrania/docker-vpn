# docker-vpn

This fits an openvpn server configuration into a docker container.

## Setting up VPN

Run the command to initialize the VPN server configs and related CA:
```
./init_vpn.sh
```

This will build the docker container and create the certificates for the CA
server and VPN server under the `.certs/ca` and `.certs/server` directories.

## Running the VPN
Once initialized, you can modify VPN configurations under the
`.certs/server/vpnconf` directory to customize your VPN.
