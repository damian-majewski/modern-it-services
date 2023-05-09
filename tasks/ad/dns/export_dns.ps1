# Define the output file
$OutputFile = "DNSExport.csv"

# Get the DNS server zones
$Zones = Get-DnsServerZone

# Initialize the data collection
$DnsData = @()

# Define the resource record types
$RecordTypes = "A","AAAA","CNAME","MX","NS","PTR","SOA","SRV","TXT"

# Loop through each zone and collect records
foreach ($Zone in $Zones) {
    $ZoneName = $Zone.ZoneName
    $ZoneType = $Zone.ZoneType

    foreach ($RecordType in $RecordTypes) {
        $ZoneRecords = Get-DnsServerResourceRecord -ZoneName $ZoneName -RRType $RecordType

        foreach ($Record in $ZoneRecords) {
            switch ($RecordType) {
                "A" { $RecordData = $Record.RecordData.IPv4Address }
                "AAAA" { $RecordData = $Record.RecordData.IPv6Address }
                "CNAME" { $RecordData = $Record.RecordData.HostNameAlias }
                "MX" { $RecordData = "{0} {1}" -f $Record.RecordData.MailExchange, $Record.RecordData.Preference }
                "NS" { $RecordData = $Record.RecordData.NameServer }
                "PTR" { $RecordData = $Record.RecordData.PtrDomainName }
                "SOA" { $RecordData = "{0} {1}" -f $Record.RecordData.PrimaryServer, $Record.RecordData.ResponsiblePerson }
                "SRV" { $RecordData = "{0} {1} {2}" -f $Record.RecordData.DomainName, $Record.RecordData.Port, $Record.RecordData.Priority }
                "TXT" { $RecordData = ($Record.RecordData.DescriptiveText -join " ") }
                default { $RecordData = $Record.RecordData }
            }

            $DnsData += [PSCustomObject]@{
                ZoneName = $ZoneName
                ZoneType = $ZoneType
                RecordName = $Record.HostName
                RecordType = $Record.RecordType
                RecordData = $RecordData
                Timestamp = $Record.Timestamp
            }
        }
    }
}

# Export collected data to a CSV file
$DnsData | Export-Csv -Path $OutputFile -NoTypeInformation

# Optional: Print a message to indicate completion
Write-Host "DNS data exported to $OutputFile"
