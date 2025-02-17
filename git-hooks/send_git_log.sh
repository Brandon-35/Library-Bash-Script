#!/bin/bash

LOG_FILE="$HOME/git_commit_log.txt"
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1341087748966191238/3yxajS6t2t8_lBHsvlwX0d0d8EFqp5p5eQ6fXox5amPDn5AHCg2aa8mkDHRafAbHfsuz"

if [ -s "$LOG_FILE" ]; then
    MESSAGE="📢 *Báo cáo commit hôm nay:* \n$(cat $LOG_FILE)"

    # Gửi báo cáo lên Discord
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" "$DISCORD_WEBHOOK_URL"

    # Xóa log sau khi gửi
    > "$LOG_FILE"
else
    echo "❌ Không có commit nào hôm nay."
fi
