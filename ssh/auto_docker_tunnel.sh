#!/bin/bash

# Path to your SSH config file
SSH_CONFIG="$HOME/.ssh/config"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Allowed image types
ALLOWED_IMAGES=("php" "node" "mysql")

# Check if the SSH config file exists
if [ ! -f "$SSH_CONFIG" ]; then
    echo -e "${RED}Error: SSH config file not found at $SSH_CONFIG${NC}"
    exit 1
fi

# Parse the SSH config file to get the list of hosts
hosts=($(grep "^Host " "$SSH_CONFIG" | awk '{print $2}'))

# If there are no hosts, exit
if [ ${#hosts[@]} -eq 0 ]; then
    echo -e "${RED}Error: No hosts found in SSH config file.${NC}"
    exit 1
fi

# Function to display hosts and let user select
select_host() {
    echo -e "${GREEN}Please select a host from the list:${NC}"
    PS3="Enter the number corresponding to the host: "
    select host in "${hosts[@]}"; do
        if [[ -n "$host" ]]; then
            echo -e "${GREEN}You selected: $host${NC}"
            break
        else
            echo -e "${RED}Invalid selection, please try again.${NC}"
        fi
    done
}

# Function to get the HostName for the selected host
get_hostname() {
    grep -A 3 "^Host $1$" "$SSH_CONFIG" | grep "HostName" | awk '{print $2}'
}

# Function to check if image is allowed
is_allowed_image() {
    local image="$1"
    local image_lower=$(echo "$image" | tr '[:upper:]' '[:lower:]')
    
    for allowed in "${ALLOWED_IMAGES[@]}"; do
        if [[ "$image_lower" == *"$allowed"* ]]; then
            return 0
        fi
    done
    return 1
}

# Function to setup tunnels for Docker containers
setup_docker_tunnels() {
    echo -e "${GREEN}Fetching Docker container information...${NC}"
    
    # Get Docker container information with image name
    containers=$(ssh "$host" "docker ps --format '{{.Image}} {{.Names}} {{.Ports}}'")
    
    if [ -z "$containers" ]; then
        echo -e "${RED}No Docker containers found or unable to execute docker ps${NC}"
        exit 1
    fi
    
    # Array to store tunnel PIDs
    declare -a tunnel_pids
    
    echo -e "${YELLOW}Setting up tunnels for exposed ports...${NC}"
    
    echo "$containers" | while read -r image name ports; do
        # Check if image is in allowed list
        if is_allowed_image "$image"; then
            if [[ "$ports" == *"0.0.0.0:"* ]]; then
                # Extract all port numbers after 0.0.0.0:
                port_list=$(echo "$ports" | grep -o '0.0.0.0:[0-9]*' | cut -d':' -f2)
                
                for port in $port_list; do
                    echo -e "${GREEN}Setting up tunnel for $name ($image): localhost:$port${NC}"
                    
                    # Setup SSH tunnel
                    ssh -L "$port:localhost:$port" "$host" -N &
                    tunnel_pid=$!
                    tunnel_pids+=($tunnel_pid)
                    
                    echo "Tunnel created (PID: $tunnel_pid)"
                done
            else
                echo -e "${YELLOW}Skipping $name ($image): No exposed ports${NC}"
            fi
        else
            echo -e "${YELLOW}Skipping $name ($image): Not in allowed image list${NC}"
        fi
    done
    
    # Save tunnel PIDs to a file for later cleanup
    if [ ${#tunnel_pids[@]} -gt 0 ]; then
        printf "%s\n" "${tunnel_pids[@]}" > ~/.docker_tunnels_pid
        echo -e "${GREEN}All tunnels established!${NC}"
        echo -e "${YELLOW}Active tunnels:${NC}"
        ps -f -p "${tunnel_pids[@]}" 2>/dev/null
    else
        echo -e "${YELLOW}No ports to tunnel found${NC}"
    fi
}

# Main script
echo -e "${GREEN}Docker SSH Tunnel Manager${NC}"
echo "===================="

# Select the host interactively
select_host

# Get hostname
selected_host=$(get_hostname "$host")
if [ -z "$selected_host" ]; then
    echo -e "${RED}Error: Could not find HostName for '$host'${NC}"
    exit 1
fi

# Setup tunnels for Docker containers
setup_docker_tunnels

# Keep script running and handle cleanup on exit
cleanup() {
    echo -e "${YELLOW}Cleaning up tunnels...${NC}"
    if [ -f ~/.docker_tunnels_pid ]; then
        kill $(cat ~/.docker_tunnels_pid) 2>/dev/null
        rm ~/.docker_tunnels_pid
    fi
    echo -e "${GREEN}Tunnels closed. Goodbye!${NC}"
}

trap cleanup EXIT

echo -e "${GREEN}Tunnels are running. Press Ctrl+C to stop all tunnels.${NC}"
wait