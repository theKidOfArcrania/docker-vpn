FROM ubuntu:20.04
RUN apt-get update

# Ensures that examples are installed
RUN /bin/echo -e "\npath-include=/usr/share/doc/*/examples/*" >> /etc/dpkg/dpkg.cfg.d/excludes
RUN apt-get install -y openvpn easy-rsa iptables ufw
COPY client/vars /usr/share/easy-rsa/vars
COPY client/scripts/ /usr/local/bin/

RUN mkdir -p /mnt/certs /mnt/vpnconfig

CMD ["/usr/local/bin/ovpn", "run"]
