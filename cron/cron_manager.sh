#!/bin/bash

CRON_FILE="/tmp/my_cron_jobs"

function show_help() {
    echo "Usage: $0 <command> [args]"
    echo "Commands:"
    echo "  create '<cron_syntax> <command>' - Add a new cron job"
    echo "  list                            - Show all cron jobs"
    echo "  update '<old_cron>' '<new_cron>' - Update an existing cron job"
    echo "  delete '<cron_syntax> <command>' - Delete a specific cron job"
    echo "  help                            - Show this help message"
    exit 1
}

function create_cron() {
    local cron_job="$1"
    if [[ -z "$cron_job" ]]; then
        echo "Error: No cron job provided."
        show_help
    fi

    (crontab -l 2>/dev/null; echo "$cron_job") | sort -u > "$CRON_FILE"
    crontab "$CRON_FILE"
    rm -f "$CRON_FILE"
    echo "Cron job added: $cron_job"
}

function list_cron() {
    echo "Current Cron Jobs:"
    crontab -l
}

function update_cron() {
    local old_cron="$1"
    local new_cron="$2"
    if [[ -z "$old_cron" || -z "$new_cron" ]]; then
        echo "Error: Both old and new cron jobs must be provided."
        show_help
    fi

    crontab -l | grep -v "$old_cron" > "$CRON_FILE"
    echo "$new_cron" >> "$CRON_FILE"
    crontab "$CRON_FILE"
    rm -f "$CRON_FILE"
    echo "Updated cron job: '$old_cron' -> '$new_cron'"
}

function delete_cron() {
    local delete_cron="$1"
    if [[ -z "$delete_cron" ]]; then
        echo "Error: No cron job specified for deletion."
        show_help
    fi

    crontab -l | grep -v "$delete_cron" > "$CRON_FILE"
    crontab "$CRON_FILE"
    rm -f "$CRON_FILE"
    echo "Deleted cron job: $delete_cron"
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
