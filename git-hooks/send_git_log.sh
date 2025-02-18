#!/bin/bash

LOG_FILE="$HOME/git_commit_log.txt"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1341087748966191238/3yxajS6t2t8_lBHsvlwX0d0d8EFqp5p5eQ6fXox5amPDn5AHCg2aa8mkDHRafAbHfsuz"
if [ -s "$LOG_FILE" ]; then
    # Send log file to Discord
    curl -X POST "$DISCORD_WEBHOOK_URL" \
         -H "Content-Type: multipart/form-data" \
         -F "file=@$LOG_FILE"
    
    # Create a new file with the date format
    TIMESTAMP=$(date "+%Y-%m-%d")
    NEW_LOG_FILE="$HOME/git_commit_log_$TIMESTAMP.txt"
    cp "$LOG_FILE" "$NEW_LOG_FILE"
    
    # Clear the contents of the original file
    > "$LOG_FILE"
else
    echo "❌ No commits today."
fi
