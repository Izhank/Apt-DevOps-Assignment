#!/bin/bash
# API Endpoint Validation Script

ALB_DNS=""

# Function to display usage
usage() {
    echo "Usage: $0 --dns <alb_dns_name>"
    echo "Example: $0 --dns my-alb-1234.us-east-1.elb.amazonaws.com"
    exit 1
}

# Process command-line arguments
while (( "$#" )); do
  case "$1" in
    --dns)
      ALB_DNS=$2
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z "$ALB_DNS" ]; then
    usage
fi

echo "--- Testing API Endpoints on ${ALB_DNS} ---"
SUCCESS_COUNT=0
TOTAL_TESTS=2

# Helper function for curl test
run_test() {
    local ENDPOINT=$1
    local EXPECTED_CONTENT=$2
    local TEST_NAME=$3
    local URL="http://${ALB_DNS}${ENDPOINT}"

    echo -n "Testing ${TEST_NAME} (${URL})... "
    
    # Wait for ALB/ASG to become fully healthy (up to 30s)
    for i in {1..10}; do
        RESPONSE=$(curl -s --max-time 3 -w "%{http_code}" -o /dev/null "$URL")
        if [ "$RESPONSE" == "200" ]; then
            break
        fi
        sleep 3
    done
    
    CONTENT=$(curl -s "$URL")

    if [ "$RESPONSE" == "200" ] && [[ "$CONTENT" == *"$EXPECTED_CONTENT"* ]]; then
        echo "PASS (Status: ${RESPONSE})"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "FAIL (Status: ${RESPONSE}, Expected Content: '${EXPECTED_CONTENT}' in '${CONTENT}')"
    fi
}

# Test 1: /health endpoint [cite: 30, 39]
run_test "/health" "ok" "Health Check"

# Test 2: / root endpoint [cite: 45]
run_test "/" "Welcome to the Apt DevOps API!" "Root Endpoint"

echo "--- Test Summary ---"
if [ "$SUCCESS_COUNT" -eq "$TOTAL_TESTS" ]; then
    echo " All ${TOTAL_TESTS} tests passed successfully!"
else
    echo " ${SUCCESS_COUNT} of ${TOTAL_TESTS} tests passed. Check logs and infrastructure."
fi
