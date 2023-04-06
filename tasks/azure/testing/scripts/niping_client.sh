#!/bin/bash

niping_bin="niping"
sap_hana_server_ip="192.168.114.26"
report_file="niping_report.txt"

# Measuring RTT on client on SAP App server
echo "Measuring RTT on client on SAP App server" | tee -a ${report_file}
${niping_bin} -c -H ${sap_hana_server_ip} -B 50000 -L 1000 | tee -a ${report_file}
echo | tee -a ${report_file}

# Measuring throughput on client on SAP App server up to 8000000
echo "Measuring throughput on client on SAP App server up to 8000000" | tee -a ${report_file}
${niping_bin} -c -H ${sap_hana_server_ip} -B 100000 | tee -a ${report_file}
echo | tee -a ${report_file}

# Long LAN stability test
echo "Long LAN stability test" | tee -a ${report_file}
${niping_bin} -c -H ${sap_hana_server_ip} -B 10000 -D 100 -L 60 | tee -a ${report_file}
echo | tee -a ${report_file}

# Long WAN stability test
echo "Long WAN stability test" | tee -a ${report_file}
${niping_bin} -c -H ${sap_hana_server_ip} -P -D 60 | tee -a ${report_file}
echo | tee -a ${report_file}

# Short throughput on client on SAP App server
echo "Short throughput on client on SAP App server" | tee -a ${report_file}
${niping_bin} -c -H ${sap_hana_server_ip} -B 1000000 -L 100 | tee -a ${report_file}
echo | tee -a ${report_file}

echo "Report saved to ${report_file}"
