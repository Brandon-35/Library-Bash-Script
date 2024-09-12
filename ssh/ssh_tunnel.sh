#!/bin/bash

# Path to your SSH config file
SSH_CONFIG="$HOME/.ssh/config"

# Check if the SSH config file exists
if [ ! -f "$SSH_CONFIG" ]; then
    echo "Error: SSH config file not found at $SSH_CONFIG"
    exit 1
fi

# Parse the SSH config file to get the list of hosts
hosts=($(grep "^Host " "$SSH_CONFIG" | awk '{print $2}'))

# If there are no hosts, exit
if [ ${#hosts[@]} -eq 0 ]; then
    echo "Error: No hosts found in SSH config file."
    exit 1
fi

# Function to display hosts and let user select
select_host() {
    echo "Please select a host from the list:"
    PS3="Enter the number corresponding to the host: "
    select host in "${hosts[@]}"; do
        if [[ -n "$host" ]]; then
            echo "You selected: $host"
            break
        else
            echo "Invalid selection, please try again."
        fi
    done
}

# Function to get the HostName for the selected host
get_hostname() {
    grep -A 3 "^Host $1$" "$SSH_CONFIG" | grep "HostName" | awk '{print $2}'
}

# Function to handle SSH tunnel setup and running in background
setup_tunnel() {
    selected_host=$(get_hostname "$host")

    if [ -z "$selected_host" ]; then
        echo "Error: Could not find HostName for '$host'"
        exit 1
    fi

    # Prompt user for port numbers
    read -p "Enter the local port you want to forward: " local_port
    read -p "Enter the remote port to forward to: " remote_port

    # Confirm the tunnel setup details
    echo
    echo "Setting up SSH tunnel with the following details:"
    echo "Host: $selected_host"
    echo "Local Port: $local_port"
    echo "Remote Port: $remote_port"
    echo "-----------------------------------------"

    # Run the SSH tunnel in the background
    ssh -L "$local_port":localhost:"$remote_port" "$host" -N &
    ssh_pid=$!

    echo "SSH tunnel created for $host (PID: $ssh_pid)"
    echo "-----------------------------------------"
    echo
}

# Main script loop
while true; do
    echo "SSH Tunnel Manager"
    echo "=================="
    
    # Select the host interactively
    select_host

    # Setup the SSH tunnel
    setup_tunnel

    # Ask user if they want to create another tunnel
    read -p "Do you want to create another SSH tunnel? (y/n): " answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
        echo "Exiting SSH Tunnel Manager. Goodbye!"
        break
    fi
done