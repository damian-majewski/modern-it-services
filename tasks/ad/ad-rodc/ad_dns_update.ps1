# Define the primary and secondary DNS server IP addresses
$PrimaryDNSServer = "192.168.1.10"   # Replace with the IP address of your primary DNS server
$SecondaryDNSServer = "192.168.2.31" # Replace with the IP address of your secondary DNS server

# Get the network adapter(s) for which you want to configure DNS servers
$NetworkAdapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }

foreach ($Adapter in $NetworkAdapters) {
    # Display the current DNS configuration for the adapter
    $CurrentDNSSettings = Get-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex
    Write-Host "Current DNS settings for $($Adapter.Name):"
    $CurrentDNSSettings.ServerAddresses
    
    # Set the DNS server addresses for the adapter
    Set-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex -ServerAddresses ($PrimaryDNSServer, $SecondaryDNSServer)

    # Display the updated DNS configuration for the adapter
    $UpdatedDNSSettings = Get-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex
    Write-Host "Updated DNS settings for $($Adapter.Name):"
    $UpdatedDNSSettings.ServerAddresses
}
