#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Active SSH Tunnels${NC}"
echo "=================="

# Function to parse SSH tunnel details
parse_tunnel_details() {
    local ssh_cmd="$1"
    
    # Extract local and remote port from -L option
    if [[ $ssh_cmd =~ -L[[:space:]]*([0-9]+):localhost:([0-9]+) ]]; then
        local_port="${BASH_REMATCH[1]}"
        remote_port="${BASH_REMATCH[2]}"
    elif [[ $ssh_cmd =~ -L[[:space:]]*([0-9]+):([^:]+):([0-9]+) ]]; then
        local_port="${BASH_REMATCH[1]}"
        remote_host="${BASH_REMATCH[2]}"
        remote_port="${BASH_REMATCH[3]}"
    fi
    
    # Extract remote host from the last part of SSH command
    if [ -z "$remote_host" ]; then
        remote_host=$(echo "$ssh_cmd" | awk '{print $NF}')
    fi
    
    echo "$local_port|$remote_host|$remote_port"
}

# Get all SSH processes with -L flag (tunnels)
tunnel_processes=$(ps aux | grep "ssh -L" | grep -v grep)

if [ -z "$tunnel_processes" ]; then
    echo -e "${YELLOW}No active SSH tunnels found${NC}"
    exit 0
fi

# Print header
printf "${BLUE}%-10s %-15s %-25s %-15s %-15s %-30s${NC}\n" \
    "PID" "Local Port" "Remote Host" "Remote Port" "Status" "Started"
echo "------------------------------------------------------------------------------------------------"

# Process each tunnel
while read -r line; do
    pid=$(echo "$line" | awk '{print $2}')
    command=$(echo "$line" | awk '{for(i=11;i<=NF;i++) printf "%s ", $i}')
    start_time=$(ps -p $pid -o lstart= 2>/dev/null)
    
    # Parse tunnel details
    tunnel_info=$(parse_tunnel_details "$command")
    local_port=$(echo "$tunnel_info" | cut -d'|' -f1)
    remote_host=$(echo "$tunnel_info" | cut -d'|' -f2)
    remote_port=$(echo "$tunnel_info" | cut -d'|' -f3)
    
    # Add default values if empty
    local_port=${local_port:-"N/A"}
    remote_host=${remote_host:-"N/A"}
    remote_port=${remote_port:-"N/A"}
    
    # Check if process is still running
    if kill -0 $pid 2>/dev/null; then
        status="ACTIVE"
    else
        status="DEAD"
    fi
    
    # Print tunnel information
    printf "%-10s %-15s %-25s %-15s %-15s %-30s\n" \
        "$pid" \
        "$local_port" \
        "$remote_host" \
        "$remote_port" \
        "$status" \
        "$start_time"
    
done <<< "$tunnel_processes"

echo -e "\n${YELLOW}Total tunnels: $(echo "$tunnel_processes" | wc -l)${NC}"

# Check for tunnel PIDs from auto_docker_tunnel script
if [ -f ~/.docker_tunnels_pid ]; then
    echo -e "\n${GREEN}Docker Auto-Tunnels${NC}"
    echo "==================="
    echo -e "${YELLOW}PIDs from auto_docker_tunnel:${NC}"
    while read -r pid; do
        if kill -0 $pid 2>/dev/null; then
            status="ACTIVE"
        else
            status="DEAD"
        fi
        echo "PID: $pid - Status: $status"
    done < ~/.docker_tunnels_pid
fi

# Show how to kill tunnels
echo -e "\n${YELLOW}To kill a specific tunnel:${NC} kill <PID>"
echo -e "${YELLOW}To kill all tunnels:${NC} killall ssh"