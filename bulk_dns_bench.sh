#!/bin/bash
# Bulk DNS Lookup: Generates a CSV of DNS lookups from a list of domains.
# All output is sent to results.csv

# File name/path of domain list:
domain_list='domains.txt' # One FQDN per line in file.

# IP address of the nameserver used for lookups:
ns1_ip='1.1.1.1'     # Cloudflare
ns2_ip='9.9.9.9'     # Quad9
ns3_ip='1.1.1.2'     # Cloudflare Malware
ns4_ip='76.76.2.2'   # ControlD Free
ns5_ip='192.168.0.1' # local

# Seconds to wait between lookups:
loop_wait='0.5' # Pause duration between lookups

# Define CSV output file:
csv_file="./results.csv"
rm --force "$csv_file"

# Write CSV header to file
echo "domain_name,$ns1_ip,$ns2_ip,$ns3_ip,$ns4_ip,$ns5_ip" >"$csv_file"

for domain in $(cat $domain_list); do
    ip1=$(dig @$ns1_ip +short +tls $domain | tail -n1)
    ip2=$(dig @$ns2_ip +short +tls $domain | tail -n1)
    ip3=$(dig @$ns3_ip +short +tls $domain | tail -n1)
    ip4=$(dig @$ns4_ip +short +tls $domain | tail -n1)
    ip5=$(dig @$ns5_ip +short +tls $domain | tail -n1)
    echo -en "$domain,$ip1,$ip2,$ip3,$ip4,$ip5\n" >>"$csv_file"
    sleep $loop_wait
done

# Generate a summary of lookups; printed to the terminal (stdout)
echo -e "Summary of DNS lookups:"
total_domains=$(wc -l <$domain_list)
echo -e "Total domains: $total_domains"
total_lookups=$(($(wc -l <"$csv_file") - 2))
echo -e "Total lookups: $total_lookups"

resolved_by_ns1=0
resolved_by_ns2=0
resolved_by_ns3=0
resolved_by_ns4=0
resolved_by_ns5=0

while IFS=, read -r col1 col2 col3 col4 col5 col6; do
    if [ "$col2" != "0.0.0.0" -a "$col2" != "" ]; then
        resolved_by_ns1=$((resolved_by_ns1 + 1))
    fi
    if [ "$col3" != "0.0.0.0" -a "$col3" != "" ]; then
        resolved_by_ns2=$((resolved_by_ns2 + 1))
    fi
    if [ "$col4" != "0.0.0.0" -a "$col4" != "" ]; then
        resolved_by_ns3=$((resolved_by_ns3 + 1))
    fi
    if [ "$col5" != "0.0.0.0" -a "$col5" != "" ]; then
        resolved_by_ns4=$((resolved_by_ns4 + 1))
    fi
    if [ "$col6" != "0.0.0.0" -a "$col6" != "" ]; then
        resolved_by_ns5=$((resolved_by_ns5 + 1))
    fi
done < <(tail -n +2 "$csv_file") # skip header

echo "resolved_domains_ns1 ($ns1_ip): $resolved_by_ns1"
echo "resolved_domains_ns2 ($ns2_ip): $resolved_by_ns2"
echo "resolved_domains_ns3 ($ns3_ip): $resolved_by_ns3"
echo "resolved_domains_ns4 ($ns4_ip): $resolved_by_ns4"
echo "resolved_domains_ns5 ($ns5_ip): $resolved_by_ns5"
