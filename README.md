# michns

### Script Description:

* Principle: Use [Dnsmasq](http://thekelleys.org.uk/dnsmasq/doc.html) DNS to hijack website resolution to the [SNIproxy](https://github.com/dlundquist/sniproxy) reverse proxy page.

* Purpose: Allow VPS that cannot watch streaming media to watch (prerequisite: one of the VPS must be able to watch streaming media).

* Features: The script unlocks `xbox openai spotify`[etc.](https://github.com/m1chtv/michns/blob/master/proxy-domains.txt) by default. If you need to add or delete domains, please edit the files `/etc/dnsmasq.d/custom_mich.conf` and `/etc/sniproxy.conf`

* Script supported systems: CentOS6+, Debian8+, Ubuntu16+

* Theoretically supports the above systems and does not limit the virtualization type. If you have any questions, please feedback

* If the IP displayed at the end of the script does not match the actual public IP, please modify the IP address in the file `/etc/sniproxy.conf`

### Script usage:

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

### Fast installation (recommended):
``` Bash
wget --no-check-certificate -O dnsmasq_sniproxy.sh https://raw.githubusercontent.com/m1chtv/michns/master/dnsmasq_sniproxy.sh && bash dnsmasq_sniproxy.sh -f
```

### Normal installation:
``` Bash
wget --no-check-certificate -O dnsmasq_sniproxy.sh https://raw.githubusercontent.com/m1chtv/michns/master/dnsmasq_sniproxy.sh && bash dnsmasq_sniproxy.sh -i
```

### Uninstallation method:
``` Bash
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
Modify `/etc/systemd/resolved.conf`
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

---

___This script is only for bypass boycott___
