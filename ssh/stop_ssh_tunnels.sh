#!/bin/bash

# Find all running SSH processes with port forwarding
tunnels=$(ps aux | grep "[s]sh -L" | awk '{print $2, $0}')

if [ -z "$tunnels" ]; then
    echo "No SSH tunnels are currently running."
    exit 0
fi

# Display the running SSH tunnels
echo "The following SSH tunnels are running:"
echo "-----------------------------------------"
ps aux | grep "[s]sh -L" | awk '{print $2, $0}'
echo "-----------------------------------------"

# Ask user if they want to stop all or select specific ones
read -p "Do you want to stop all SSH tunnels? (y/n): " stop_all

if [[ "$stop_all" == "y" || "$stop_all" == "Y" ]]; then
    # Kill all running SSH tunnels
    echo "Stopping all SSH tunnels..."
    ps aux | grep "[s]sh -L" | awk '{print $2}' | xargs kill
    echo "All SSH tunnels have been stopped."
else
    # Allow the user to select which tunnels to stop
    echo "Select the PID(s) of the SSH tunnels to stop (separate with space):"
    read -a pids_to_kill

    for pid in "${pids_to_kill[@]}"; do
        if kill "$pid" >/dev/null 2>&1; then
            echo "SSH tunnel with PID $pid stopped."
        else
            echo "Failed to stop SSH tunnel with PID $pid."
        fi
    done
fi