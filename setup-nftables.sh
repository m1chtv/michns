#!/bin/bash
nft flush ruleset
nft add table inet filter

# SSH/SFTP (22/tcp)
nft add rule inet filter input tcp dport 22 ct state new accept

nft add chain inet filter input { type filter hook input priority 0 \; policy drop \; }
nft add chain inet filter forward { type filter hook forward priority 0 \; policy drop \; }
nft add chain inet filter output { type filter hook output priority 0 \; policy accept \; }

nft add rule inet filter input iif "lo" accept
nft add rule inet filter input ct state established,related accept

# ICMP (ping)
nft add rule inet filter input ip protocol icmp icmp type echo-request accept

# DNS (53/udp) - rate-limit
nft add rule inet filter input udp dport 53 ct state new limit rate 50/second burst 10 packets accept

# DNS (53/tcp)
nft add rule inet filter input tcp dport 53 ct state new limit rate 10/second burst 5 packets accept

# SNI Proxy (443/tcp) - connlimit , rate-limit
nft add rule inet filter input tcp dport 443 ct state new meter sni_limit { ip saddr limit rate 100/second burst 20 packets } accept
nft add rule inet filter input tcp dport 443 ct state new ct count over 50 drop

# spoof, bad flags
nft add rule inet filter input ip saddr 127.0.0.0/8 iif != "lo" drop
nft add rule inet filter input tcp flags & (fin|syn|rst|psh|ack|urg) == 0x0 drop
nft add rule inet filter input tcp flags & (fin|syn|rst|psh|ack|urg) == (fin|urg|psh) drop

nft add rule inet filter input tcp dport { 23, 80, 8080 } drop
nft add rule inet filter input udp dport 123 drop

echo "✅ nftables ruleset loaded successfully."
