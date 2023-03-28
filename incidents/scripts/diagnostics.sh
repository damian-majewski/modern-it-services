#!/bin/bash

# Define functions
hardware_info() {
  if command -v lshw > /dev/null 2>&1; then
    echo "=== Hardware Information ==="
    lshw -short -quiet
  else
    echo "lshw command not found. Skipping hardware information."
  fi
}

journal_errors() {
  if command -v journalctl > /dev/null 2>&1; then
    echo "=== Journal Errors ==="
    journalctl -p err -a -n 100
  else
    echo "journalctl command not found. Skipping journal errors."
  fi
}

installed_packages_conflicts() {
  if command -v dpkg-query > /dev/null 2>&1; then
    echo "=== Installed Packages Conflicts (Debian-based systems) ==="
    dpkg-query -f '${binary:Package}\t${Version}\n' -W
  elif command -v rpm > /dev/null 2>&1; then
    echo "=== Installed Packages Conflicts (Red Hat-based systems) ==="
    rpm -Va --queryformat '%{NAME}\t%{VERSION}\n'
  else
    echo "No package query command found. Skipping installed packages conflicts."
  fi
}

# Call the function
installed_packages_conflicts


system_info() {
  echo "=== System Information ==="
  uname -a
  cat /etc/issue
  cat /etc/os-release
  lsb_release -d
  cat /proc/version
  echo "=== System Load ==="
  uptime
  echo "=== System Interrupts ==="
  cat /proc/interrupts
}

resource_usage() {
  echo "---- vmstat ----"
  vmstat 2 5

  echo "---- mpstat ----"
  mpstat -P ALL 2 5

  echo "---- pidstat ----"
  pidstat 2 5

  echo "---- iostat ----"
  iostat -xz 2 5
  iostat -dwxy 2 10
  iostat -dx 2 10

  echo "---- free ----"
  free -mh

  echo "---- sar ----"
  sar -n DEV 2 10
  sar -n TCP,ETCP 2 5
}

disk_usage() {
  echo "=== Disk Usage ==="
  df -h | egrep -i -e "7.%|8.%|9.%|100%"
  for i in `df -h | egrep -i -e "7.%|8.%|9.%|100%" | awk '{print $6}'`
  do 
    find $i -xdev -type f -exec du -sh {} + | sort -n -r | head -n50
  done
}

memory_usage() {
  echo "=== Memory Usage ==="
  free -h
  ps -eo pmem,pid,user,args --sort=-pmem | head
}

cpu_usage() {
  echo "=== CPU Usage ==="
  top -b -n 1 | head -n 12
  ps -eo pcpu,pid,user,args --sort=-pcpu | head
}

network_info() {
  echo "=== Network Interfaces ==="
  ip addr
  echo "=== Active Connections ==="
  netstat -naplet
  echo "=== Network Traffic ==="
  sar -n DEV 2 10
  echo "=== Network Bandwidth and Usage ==="
  iftop -t -s 5
}

swap_usage() {
  echo "=== Swap Usage ==="
  swapon -s
}

top_memory_processes() {
  echo "=== Top Memory Consuming Process ==="
  ps aux | awk '{print $2, $4, $11}' | sort -k2rn | head -n 10 | awk '{print $1, $3, $4}'
}

open_files() {
  echo "=== Open Files ==="
  lsof | wc -l
}

check_nfs_mounts() {
  echo "----- Current mountpoints -----"
  cat /proc/mounts | egrep -e "cifs|nfs"| wc -l
  echo "----- /etc/fstab -----"
  cat /etc/fstab | egrep -e "cifs|nfs" | grep -v ^# | wc -l 
}

# Call functions
system_info
resource_usage
disk_usage
memory_usage
cpu_usage
network_info
swap_usage
top_memory_processes
open_files
hardware_info
journal_errors
installed_packages_conflicts
check_nfs_mounts