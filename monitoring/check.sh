#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "==================================================="
echo "   App Server Health Check - $(date)"
echo "==================================================="

echo
echo "-- Container Status --"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo
echo "-- Application Health --"
HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health)
if [ "$HEALTH" -eq 200 ]; then
    echo -e "${GREEN}Application is healthy! (HTTP ${HEALTH})${NC}"
else
    echo -e "${RED}Application is unhealthy! (HTTP ${HEALTH})${NC}"
fi

echo
echo "-- Recent App Logs --"
docker logs devops-app --tail 20 --since 1h

echo
echo "-- Resource Usage --"
docker stats devops-app --no-stream \
    --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

echo
echo "-- System Resources --"
echo "Disk:"
df -h / | tail -1
echo "Memory:"
free -h | grep Mem

echo
echo "==================================================="