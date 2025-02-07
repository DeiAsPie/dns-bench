#!/bin/bash
# Bulk DNS Lookup: Generates a CSV of DNS lookups from a list of domains.

# File name/path of domain list:
domain_list='domains.txt' # One FQDN per line in file.

# IP address of the nameserver used for lookups:
ns1_ip='1.1.1.1'     # Cloudflare
ns2_ip='9.9.9.9'     # Quad9
ns3_ip='1.1.1.2'     # Cloudflare Malware
ns4_ip='76.76.2.2'   # ControlD Free
ns5_ip='192.168.0.1' # local

# Seconds to wait between lookups:
loop_wait='0.5' # Is set to 0.5 second.

echo "Domain name, $ns1_ip,$ns2_ip,$ns3_ip,$ns4_ip,$ns5_ip " # Start CSV

for domain in $( # Start looping through domains
    cat $domain_list
); do
    ip1=$(dig @$ns1_ip +short +tls $domain | tail -n1) # IP address lookup DNS Server1
    ip2=$(dig @$ns2_ip +short +tls $domain | tail -n1) # IP address lookup DNS server2
    ip3=$(dig @$ns3_ip +short +tls $domain | tail -n1) # IP address lookup DNS server3
    ip4=$(dig @$ns4_ip +short +tls $domain | tail -n1) # IP address lookup DNS server4
    ip5=$(dig @$ns5_ip +short +tls $domain | tail -n1) # IP address lookup DNS server5
    echo -en "$domain,$ip1,$ip2,$ip3,$ip4,$ip5\n"
    sleep $loop_wait # Pause before the next lookup to avoid flooding NS
done
