#!/bin/bash

CRON_FILE="/tmp/my_cron_jobs"

function show_help() {
    __color green "Usage: $0 <command> [args]"
    __color green "Commands:"
    __color green "  create '<cron_syntax> <command>' - Add a new cron job"
    __color green "  list                            - Show all cron jobs"
    __color green "  update '<old_cron>' '<new_cron>' - Update an existing cron job"
    __color green "  delete '<cron_syntax> <command>' - Delete a specific cron job"
    __color green "  help                            - Show this help message"
    exit 1
}

function create_cron() {
    # Adds a new cron job to the crontab.
    # Takes a single argument: the cron job syntax and command to be scheduled.
    local cron_job="$1"
    if [[ -z "$cron_job" ]]; then
        __color red "Error: No cron job provided."
        show_help
    fi

    (crontab -l 2>/dev/null; echo "$cron_job") | sort -u > "$CRON_FILE"
    crontab "$CRON_FILE"
    rm -f "$CRON_FILE"
    __color green "Cron job added: $cron_job"
}

function list_cron() {
    # Displays the current cron jobs in the crontab.
    __color green "Current Cron Jobs:"
    crontab -l
}

function update_cron() {
    # Updates an existing cron job in the crontab.
    # Takes two arguments: the old cron job syntax and the new cron job syntax.
    local old_cron="$1"
    local new_cron="$2"
    if [[ -z "$old_cron" || -z "$new_cron" ]]; then
        __color red "Error: Both old and new cron jobs must be provided."
        show_help
    fi

    crontab -l | grep -v "$old_cron" > "$CRON_FILE"
    echo "$new_cron" >> "$CRON_FILE"
    crontab "$CRON_FILE"
    rm -f "$CRON_FILE"
    __color green "Updated cron job: '$old_cron' -> '$new_cron'"
}

function delete_cron() {
    # Deletes a specific cron job from the crontab.
    # Takes a single argument: the cron job syntax to be deleted.
    local delete_cron="$1"
    if [[ -z "$delete_cron" ]]; then
        __color red "Error: No cron job specified for deletion."
        show_help
    fi

    crontab -l | grep -v "$delete_cron" > "$CRON_FILE"
    crontab "$CRON_FILE"
    rm -f "$CRON_FILE"
    __color green "Deleted cron job: $delete_cron"
}

case "$1" in
    create)
        create_cron "$2"
        ;;
    list)
        list_cron
        ;;
    update)
        update_cron "$2" "$3"
        ;;
    delete)
        delete_cron "$2"
        ;;
    help | *)
        show_help
        ;;
esac
