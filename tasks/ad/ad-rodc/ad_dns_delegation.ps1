# On the current Domain Controller
Add-DnsServerZoneDelegation `
   -ZoneName "solveler.com" `
   -ChildZoneName "rodc1.solveler.com" `
   -NameServer "rodc1.solveler.com" `
   -IPAddress "192.168.2.31"