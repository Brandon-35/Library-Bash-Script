# Configuration variables
current_dir="$(pwd)"  # Current directory
LOG_FILE="$current_dir/script_log.txt"  # Log file path
DEFAULT_DIR="$current_dir/my_directory"  # Default directory to create
WEBHOOK_URL="YOUR_DISCORD_WEBHOOK_URL"  # Discord webhook URL

# Function to check if a command exists
# Usage: command_exists <command_name>
function command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create a directory if it doesn't exist
# Usage: create_directory [<directory_path>]
function create_directory() {
    local dir="${1:-$DEFAULT_DIR}"  # Use default directory if none provided
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        __color green "Directory created: $dir"
    else
        __color yellow "Directory already exists: $dir"
    fi
}

# Function to read a file line by line
# Usage: read_file_line_by_line <file_path>
function read_file_line_by_line() {
    local file="$1"
    if [ -f "$file" ]; then
        while IFS= read -r line; do
            echo "$line"
        done < "$file"
    else
        __color red "File not found: $file"
    fi
}

# Function to log messages with a timestamp
# Usage: log_message <message> [<log_file_path>]
function log_message() {
    local message="$1"
    local log_file="${2:-$LOG_FILE}"  # Use default log file if none provided
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $message" >> "$log_file"
}

# Function to check if a string is empty
# Usage: is_empty <string>
function is_empty() {
    [ -z "$1" ]
}

# Function to count the number of lines in a file
# Usage: count_lines_in_file <file_path>
function count_lines_in_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local line_count=$(wc -l < "$file")
        __color green "Number of lines in $file: $line_count"
    else
        __color red "File not found: $file"
    fi
}

# Function to copy a file to a specified directory
# Usage: copy_file_to_directory <file_path> <directory_path>
function copy_file_to_directory() {
    local file="$1"
    local dir="$2"
    if [ -f "$file" ]; then
        cp "$file" "$dir"
        __color green "Copied $file to $dir"
    else
        __color red "File not found: $file"
    fi
}

# Function to move a file to a specified directory
# Usage: move_file_to_directory <file_path> <directory_path>
function move_file_to_directory() {
    local file="$1"
    local dir="$2"
    if [ -f "$file" ]; then
        mv "$file" "$dir"
        __color green "Moved $file to $dir"
    else
        __color red "File not found: $file"
    fi
}

# Function to delete a file
# Usage: delete_file <file_path>
function delete_file() {
    local file="$1"
    if [ -f "$file" ]; then
        rm "$file"
        __color green "Deleted file: $file"
    else
        __color red "File not found: $file"
    fi
}

# Function to create a file with specified content
# Usage: create_file_with_content <file_path> <content>
function create_file_with_content() {
    local file="$1"
    local content="$2"
    echo "$content" > "$file"
    __color green "Created file: $file with specified content"
}

# Function to check if a file is readable
# Usage: is_file_readable <file_path>
function is_file_readable() {
    local file="$1"
    if [ -r "$file" ]; then
        __color green "File $file is readable."
    else
        __color red "File $file is not readable."
    fi
}

# Function to render JSON using jq
# Usage: render_json <json_string>
function render_json() {
    local json="$1"
    if command_exists jq; then
        echo "$json" | jq . | sed 's/^/    /'  # Pretty print JSON with indentation
    else
        __color red "jq is not installed."
    fi
}

# Function to make a GET request using curl
# Usage: curl_get <url>
function curl_get() {
    local url="$1"
    if command_exists curl; then
        curl -s "$url"
    else
        __color red "curl is not installed."
    fi
}

# Function to check public IP address
# Usage: check_ip
function check_ip() {
    local ip=$(curl -s https://api.ipify.org)
    __color green "Your public IP address is: $ip"
}

# Function to check if an endpoint is reachable
# Usage: check_endpoint <url>
function check_endpoint() {
    local url="$1"
    if curl --output /dev/null --silent --head --fail "$url"; then
        __color green "Endpoint $url is reachable."
    else
        __color red "Endpoint $url is not reachable."
    fi
}

# Function to send a notification to Discord
# Usage: send_discord_notification <message> <embed_title> <embed_description>
function send_discord_notification() {
    local message="$1"
    local embed_title="$2"
    local embed_description="$3"
    local url="${4:-https://example.com}"  # Default URL if not provided
    local color="${5:-15258703}"  # Default color if not provided
    local footer_text="${6:-Chân trang nhúng}"  # Default footer text if not provided
    local image_url="${7:-https://link.to/image.jpg}"  # Default image URL if not provided
    local thumbnail_url="${8:-https://link.to/thumbnail.jpg}"  # Default thumbnail URL if not provided
    local author_name="${9:-Tên tác giả}"  # Default author name if not provided
    local author_url="${10:-https://author.url}"  # Default author URL if not provided
    local author_icon_url="${11:-https://link.to/author/icon.jpg}"  # Default author icon URL if not provided

    curl -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d '{
            "content": "'"$message"'",
            "embeds": [
                {
                    "title": "'"$embed_title"'",
                    "description": "'"$embed_description"'",
                    "url": "'"$url"'",
                    "color": '"$color"',
                    "footer": {
                        "text": "'"$footer_text"'"
                    },
                    "image": {
                        "url": "'"$image_url"'"
                    },
                    "thumbnail": {
                        "url": "'"$thumbnail_url"'"
                    },
                    "author": {
                        "name": "'"$author_name"'",
                        "url": "'"$author_url"'",
                        "icon_url": "'"$author_icon_url"'"
                    }
                }
            ]
        }'
}
