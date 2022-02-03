### Set up CA
# https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-a-certificate-authority-ca-on-ubuntu-20-04

# Step 1: Install easy-rsa
FROM ubuntu:20.04
RUN apt-get update
# Ensures that examples are installed
RUN /bin/echo -e "\npath-include=/usr/share/doc/*/examples/*" >> /etc/dpkg/dpkg.cfg.d/excludes
RUN apt-get install -y openvpn easy-rsa iptables ufw
COPY vars /usr/share/easy-rsa/vars
COPY scripts/ /usr/local/bin/

# Step 2: Preparing a Public Key Infrastructure Directory
RUN mkdir -p /certs/ca; ln -s /usr/share/easy-rsa/* /certs/ca
WORKDIR /certs/ca
RUN ./easyrsa init-pki

# Step 3: Creating a Certificate Authority
RUN echo | ./easyrsa build-ca nopass

### Set up VPN server
# https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-an-openvpn-server-on-ubuntu-20-04
# Step 1: Install openVPN and easy-rsa
# Step 2: Create a PKI for openVPN
RUN mkdir -p /certs/server; ln -s /usr/share/easy-rsa/* /certs/server
WORKDIR /certs/server
RUN ./easyrsa init-pki

# Step 3/4: Create an openVPN server certificate request and sign it
RUN ovpn mkcert server server /etc/openvpn/server/
RUN cp /certs/ca/pki/ca.crt /etc/openvpn/server/

# Step 5: Configuring OpenVPN Cryptographic Material
WORKDIR /certs/server
RUN openvpn --genkey --secret ta.key
RUN cp ta.key /etc/openvpn/server/

# Step 6: Configuring client configs

# Step 7: Configuring openVPN
RUN cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz \
  /etc/openvpn/server/ && \
  gunzip /etc/openvpn/server/server.conf.gz && \
  cp /etc/openvpn/server/server.conf /etc/openvpn/server/server.conf.old && \
  sed -i -e '/tls-auth/ {' \
    -e   's/^/;/ ' \
    -e   'atls-crypt ta.key' \
    -e '}' \
    -e '/cipher AES-256-CBC/ {' \
    -e   'icipher AES-256-GCM' \
    -e   'aauth SHA256' \
    -e   'd' \
    -e '}' \
    -e '/dh dh2048/ {' \
    -e   's/^/;/ ' \
    -e   'adh none' \
    -e '}' \
    -e 's/;\(user nobody\|group nogroup\)/\1/' \
    /etc/openvpn/server/server.conf

# Step 8: Adjusting the OpenVPN Server Networking Configuration
# Step 9: Firewall configuration
ADD before.rules.insert .
RUN sed -i -e '/IPV6=/s/yes/no/' /etc/default/ufw && \
  sed -i -e '10r before.rules.insert' /etc/ufw/before.rules && \
  ufw route allow in on tun0 out on eth0 && \
  ufw route allow in on tun0 out on tun0 && \
  ufw allow 1194/udp && \
  ufw allow 53/udp

WORKDIR /
ENTRYPOINT ["/usr/local/bin/ovpn"]
