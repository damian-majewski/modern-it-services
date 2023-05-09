#!/bin/bash

# Input file with DNS records
input="input/dns_export.csv"

# Log file
logfile="logs/dns_check_domain_$(date +%Y%m%d_%H%M%S).log"

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

    # Check if the domain is resolvable
    if host "$fqdn" > /dev/null 2>&1; then
        print_and_log "$fqdn is resolvable"
        print_and_log "DNS Record Type: $recordType"
        print_and_log "DNS Record Data: $recordData"

        # Check if the domain is reachable using ping with a timeout of 3 seconds
        if ping -c 1 -W 3 "$fqdn" > /dev/null 2>&1; then
            print_and_log "$fqdn is reachable"
        else
            print_and_log "$fqdn is not reachable"
        fi
        
        # Get DNS information using dig
        print_and_log "Dig output:"
        dig_output=$(dig "$fqdn" +short)
        print_and_log "$dig_output"

        # Use curl to fetch HTTP headers (use -k flag to ignore SSL errors)
        print_and_log "HTTP headers using curl:"
        curl_output=$(curl -Iks "$fqdn")
        print_and_log "$curl_output"

        # Use traceroute to check the network path (use -w flag to set the wait time)
        print_and_log "Traceroute output:"
        traceroute_output=$(traceroute -w 3 -m 15 "$fqdn")
        print_and_log "$traceroute_output"
        
    else
        print_and_log "$fqdn is not resolvable"
    fi
    print_and_log "----------"
done
