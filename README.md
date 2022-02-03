# docker-vpn

This fits an openvpn server within a docker container set up.

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

Then to start up the VPN, run:
```
./run_vpn.sh
```

## Creating client configurations
To create client configurations, run the command:
```
./create_client.sh -i <IP of your host machine> -n <client name>
```
