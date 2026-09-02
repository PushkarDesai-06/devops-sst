#!/bin/bash

# 1. Use variables to store data
CURRENT_DATE=$(date)
SYS_HOSTNAME=$(hostnamectl)
SYS_USER=$(whoami)

# 2. Print system information (Date, Hostname, Username)
echo "========================================"
echo "          SYSTEM INFORMATION            "
echo "========================================"
echo "Current Date : $CURRENT_DATE"
echo "Hostname     : $SYS_HOSTNAME"
echo "Username     : $SYS_USER"
echo ""

# 3. Print the disk usage
echo "--- Disk Usage ---"
df -h
echo ""

# 4. Take user input using read -p
read -p "Enter a name for the new directory to store process logs: " DIR_NAME

# 5. Create a directory using mkdir
mkdir -p "$DIR_NAME"
echo "✅ Directory '$DIR_NAME' created successfully."

# Define the file path using variables
FILE_PATH="$DIR_NAME/processes.txt"

# 6. Create a file using touch
touch "$FILE_PATH"
echo "✅ File '$FILE_PATH' created successfully."

# 7. Print the running processes AND store them in the file using > output redirection
echo ""
echo "--- Running Processes ---"
echo "Fetching processes and saving to $FILE_PATH..."

# Save all processes to the file using >
ps aux > "$FILE_PATH"

# Print a preview to the screen (first 10 lines) to avoid flooding the terminal
head -n 10 "$FILE_PATH"
echo "... (Remaining output saved to $FILE_PATH)"
echo ""
echo "Script execution complete!"