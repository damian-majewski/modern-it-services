#!/bin/bash

# Input file with DNS records
input="input/dns_export.csv"

# Add your DNS servers
dns_server1="192.168.1.1"
dns_server2="192.168.1.2"

# Log file
logfile="logs/dns_check_resolution_$(date +%Y%m%d_%H%M%S).log"

# Function to print and log output
print_and_log() {
    echo "$@"
    echo "$@" >> "$logfile"
}

# Loop through each line in the file, skipping the header
tail -n +2 "$input" | while IFS=, read -r domain zoneType recordName recordType recordData extra
do
    # Remove quotes from domain and recordName
    domain=$(echo "$domain" | tr -d '"')
    recordName=$(echo "$recordName" | tr -d '"')

    # Create a fully-qualified domain name (FQDN) for each record
    if [ "$recordName" = "@" ]; then
        fqdn="$domain"
    else
        fqdn="$recordName.$domain"
    fi

    # Check if FQDN is an IP address, skip if true
    if [[ $fqdn =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        continue
    fi

    print_and_log "Checking $fqdn on DNS servers $dns_server1 and $dns_server2"
    print_and_log "----------"

    # Query each DNS server using dig
    for dns_server in $dns_server1 $dns_server2; do
        print_and_log "Querying $fqdn:"
        print_and_log "Dig output:"
        dig_output=$(dig "@$dns_server" "$fqdn" +short)
        print_and_log "$dig_output"

        # Perform reverse DNS lookup if the dig_output is an IP address
        if [[ $dig_output =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            print_and_log "Reverse DNS lookup for $dig_output:"
            reverse_dns_output=$(dig -x "$dig_output" +short)
            print_and_log "$reverse_dns_output"
        fi

        # Trace the DNS query
        dig_trace=$(dig @$dns_server $fqdn A +trace)
        print_and_log "Dig trace:"
        print_and_log "$dig_trace"

        print_and_log "----------"
    done

    # Use traceroute to check the network path to the DNS server
    print_and_log "Traceroute to $fqdn server:"
    traceroute_output=$(traceroute -w 3 -m 15 "$fqdn")
    print_and_log "$traceroute_output"
    
  print_and_log "----------"
done