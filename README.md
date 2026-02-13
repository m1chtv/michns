# michns

### Script Description:

This combined Dnsmasq + SNIproxy solution is designed to circumvent regional censorship and geo-blocking restrictions effectively:

- [Dnsmasq](http://thekelleys.org.uk/dnsmasq/doc.html) acts as a DNS hijacker, redirecting selected domain queries to the proxy. This allows intercepting and controlling domain resolution transparently.

- [SNIproxy](https://github.com/dlundquist/sniproxy) then acts as a lightweight reverse proxy for HTTP and TLS traffic, forwarding requests to the actual streaming or blocked services without revealing the final destination to intermediate networks.

- Together, they enable users behind strict firewalls or geo-filters (like government-imposed sanctions) to access otherwise blocked streaming media or web services.

- The system works by selectively routing specific domains (configured via `/etc/dnsmasq.d/custom_mich.conf` and `/etc/sniproxy.conf`) through the proxy, leaving other traffic unaffected, which optimizes performance and reduces overhead.

- This approach avoids the heavy resource use of VPNs or full HTTP proxies while maintaining high compatibility with streaming protocols.

- It’s suitable for VPS environments where direct streaming is restricted, leveraging at least one VPS with unrestricted internet access to proxy traffic securely.

- Security recommendations include restricting access via firewall rules and avoiding exposing the proxy IP publicly to prevent abuse.

### Script usage:

```Bash
bash dnsmasq_sniproxy.sh [-h] [-i] [-f] [-id] [-fd] [-is] [-fs] [-u] [-ud] [-us]

-h , --help Show help information
-i , --install Install Dnsmasq + SNI Proxy
-f , --fastinstall Fast install Dnsmasq + SNI Proxy
-id, --installdnsmasq Install only Dnsmasq
-fd, --installdnsmasq Fast install Dnsmasq
-is, --installsniproxy Install only SNI Proxy
-fs, --fastinstallsniproxy Fast install SNI Proxy
-u , --uninstall Uninstall Dnsmasq + SNI Proxy
-ud, --undnsmasq Uninstall Dnsmasq
-us, --unsniproxy Uninstall SNI Proxy
```

### Fast installation (recommended):

```Bash
wget --no-check-certificate -O dnsmasq_sniproxy.sh https://raw.githubusercontent.com/m1chtv/michns/master/dnsmasq_sniproxy.sh && bash dnsmasq_sniproxy.sh -f
```

### Normal installation:

```Bash
wget --no-check-certificate -O dnsmasq_sniproxy.sh https://raw.githubusercontent.com/m1chtv/michns/master/dnsmasq_sniproxy.sh && bash dnsmasq_sniproxy.sh -i
```

### Uninstallation method:

```Bash
wget --no-check-certificate -O dnsmasq_sniproxy.sh https://raw.githubusercontent.com/m1chtv/michns/master/dnsmasq_sniproxy.sh && bash dnsmasq_sniproxy.sh -u
```

### How to use:

Change the DNS address of the proxy host to the host IP where dnsmasq is installed. If it is not available, try to keep only one DNS address in the configuration file.

To prevent abuse, it is recommended not to disclose the IP address. You can use a firewall to restrict it.

### Debugging and troubleshooting:

- Confirm that sniproxy is running effectively

Check the status of sniproxy: `systemctl status sniproxy`

If sniproxy is not running, check whether there are other services occupying port 80,443, causing port conflicts, and check the port listening command: `netstat -tlunp | grep 443`

- Confirm that the firewall allows 53,80,443

You can directly turn off the firewall for debugging `systemctl stop firewalld.service`

The security group ports of operators such as Alibaba Cloud/Google Cloud/AWS also need to be allowed
You can test it through other servers `telnet 1.2.3.4 53`

- Domain name resolution test

After trying to configure dns with other servers, resolve the domain name: nslookup xbox.com to determine whether the IP is the xbox proxy machine IP
If the nslookup command does not exist, centos installation: `yum install -y bind-utils` ubuntu & debian installation: `apt-get -y install dnsutils`

- Solution to systemd-resolve service occupying port 53
  Use `netstat -tlunp|grep 53` to find that port 53 is occupied by systemd-resolved
  Modify `sudo nano /etc/systemd/resolved.conf`

```
[Resolve]
DNS=8.8.8.8 1.1.1.1 #Uncomment and add dns
#FallbackDNS=
#Domains=
#LLMNR=no
#MulticastDNS=no
#DNSSEC=no
#Cache=yes
DNSStubListener=no #Uncomment and change yes to no
```

Then execute the following command and restart systemd-resolved

```
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
systemctl restart systemd-resolved.service
```

# Small Security tip for public DNS

```
git clone https://github.com/m1chtv/michns.git
cd michns
chmod +x setup-nftables.sh
sudo ./setup-nftables.sh

sudo apt install nftables -y
sudo systemctl enable nftables
sudo nft list ruleset > /etc/nftables.conf
```


---

**_This script is only for Sanctions Bypass_**
