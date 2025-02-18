#!/bin/bash

# Path to your SSH config file
SSH_CONFIG="$HOME/.ssh/config"

# Colors for output
source "$(dirname "$0")/../base/colors.sh"  # Include the colors script

# Allowed image types
ALLOWED_IMAGES=("php" "node" "mysql")

# Check if the SSH config file exists
if [ ! -f "$SSH_CONFIG" ]; then
    _color red "Error: SSH config file not found at $SSH_CONFIG"
    exit 1
fi

# Parse the SSH config file to get the list of hosts
hosts=($(grep "^Host " "$SSH_CONFIG" | awk '{print $2}'))

# If there are no hosts, exit
if [ ${#hosts[@]} -eq 0 ]; then
    _color red "Error: No hosts found in SSH config file."
    exit 1
fi

# Function to display hosts and let user select
select_host() {
    _color green "Please select a host from the list:"
    PS3="Enter the number corresponding to the host: "
    select host in "${hosts[@]}"; do
        if [[ -n "$host" ]]; then
            _color green "You selected: $host"
            break
        else
            _color red "Invalid selection, please try again."
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
    _color green "Fetching Docker container information..."
    
    # Get Docker container information with image name
    containers=$(ssh "$host" "docker ps --format '{{.Image}} {{.Names}} {{.Ports}}'")
    
    if [ -z "$containers" ]; then
        _color red "No Docker containers found or unable to execute docker ps"
        exit 1
    fi
    
    # Array to store tunnel PIDs
    declare -a tunnel_pids
    
    _color yellow "Setting up tunnels for exposed ports..."
    
    echo "$containers" | while read -r image name ports; do
        # Check if image is in allowed list
        if is_allowed_image "$image"; then
            if [[ "$ports" == *"0.0.0.0:"* ]]; then
                # Extract all port numbers after 0.0.0.0:
                port_list=$(echo "$ports" | grep -o '0.0.0.0:[0-9]*' | cut -d':' -f2)
                
                for port in $port_list; do
                    _color green "Setting up tunnel for $name ($image): localhost:$port"
                    
                    # Setup SSH tunnel
                    ssh -L "$port:localhost:$port" "$host" -N &
                    tunnel_pid=$!
                    tunnel_pids+=($tunnel_pid)
                    
                    echo "Tunnel created (PID: $tunnel_pid)"
                done
            else
                _color yellow "Skipping $name ($image): No exposed ports"
            fi
        else
            _color yellow "Skipping $name ($image): Not in allowed image list"
        fi
    done
    
    # Save tunnel PIDs to a file for later cleanup
    if [ ${#tunnel_pids[@]} -gt 0 ]; then
        printf "%s\n" "${tunnel_pids[@]}" > ~/.docker_tunnels_pid
        _color green "All tunnels established!"
        _color yellow "Active tunnels:"
        ps -f -p "${tunnel_pids[@]}" 2>/dev/null
    else
        _color yellow "No ports to tunnel found"
    fi
}

# Main script
_color green "Docker SSH Tunnel Manager"
echo "===================="

# Select the host interactively
select_host

# Get hostname
selected_host=$(get_hostname "$host")
if [ -z "$selected_host" ]; then
    _color red "Error: Could not find HostName for '$host'"
    exit 1
fi

# Setup tunnels for Docker containers
setup_docker_tunnels

# Keep script running and handle cleanup on exit
cleanup() {
    _color yellow "Cleaning up tunnels..."
    if [ -f ~/.docker_tunnels_pid ]; then
        kill $(cat ~/.docker_tunnels_pid) 2>/dev/null
        rm ~/.docker_tunnels_pid
    fi
    _color green "Tunnels closed. Goodbye!"
}

trap cleanup EXIT

_color green "Tunnels are running. Press Ctrl+C to stop all tunnels."
wait