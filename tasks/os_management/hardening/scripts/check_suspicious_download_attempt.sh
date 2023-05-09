#!/bin/bash

# Remote IP address to test from
REMOTE_IP="10.0.0.2"

# Local IP address to test against
LOCAL_IP="10.0.0.1"

# URL to test
TEST_URL="https://example.com/testfile"

# Log file location
LOG_FILE="/var/log/firewalld_test.log"

# Test command
TEST_CMD="curl --silent --output /dev/null --head --fail $TEST_URL"

# Test the firewall rule
echo "Testing firewall rule from $REMOTE_IP to $LOCAL_IP for $TEST_URL..." | tee -a $LOG_FILE
if ssh $LOCAL_IP "$TEST_CMD"; then
    echo "Test succeeded. Traffic was not blocked." | tee -a $LOG_FILE
else
    echo "Test failed. Traffic was blocked." | tee -a $LOG_FILE
fi
