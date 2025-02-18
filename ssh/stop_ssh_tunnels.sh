#!/bin/bash

# Find all running SSH processes with port forwarding
tunnels=$(ps aux | grep "[s]sh -L" | awk '{print $2, $0}')

if [ -z "$tunnels" ]; then
    __color yellow "No SSH tunnels are currently running."
    exit 0
fi

# Display the running SSH tunnels
__color green "The following SSH tunnels are running:"
__color green "-----------------------------------------"
ps aux | grep "[s]sh -L" | awk '{print $2, $0}'
__color green "-----------------------------------------"

# Ask user if they want to stop all or select specific ones
read -p "Do you want to stop all SSH tunnels? (y/n): " stop_all

if [[ "$stop_all" == "y" || "$stop_all" == "Y" ]]; then
    # Kill all running SSH tunnels
    __color yellow "Stopping all SSH tunnels..."
    ps aux | grep "[s]sh -L" | awk '{print $2}' | xargs kill
    __color green "All SSH tunnels have been stopped."
else
    # Allow the user to select which tunnels to stop
    __color green "Select the PID(s) of the SSH tunnels to stop (separate with space):"
    read -a pids_to_kill

    for pid in "${pids_to_kill[@]}"; do
        if kill "$pid" >/dev/null 2>&1; then
            __color green "SSH tunnel with PID $pid stopped."
        else
            __color red "Failed to stop SSH tunnel with PID $pid."
        fi
    done
fi