#!/bin/bash

SOURCE_DIR="/home/ambikac/Public"
REMOTE_USER=ubuntu
REMOTE_HOST=43.204.115.80
REMOTE_DIR="/home/ubuntu/backup"


# $HOME is a variable that automatically points to your home directory (e.g., /home/ambikac).
LOG_DIR="$HOME/backup_logs"




# 1. Create a timestamp for the log file and backup report.
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
LOG_FILE="$LOG_DIR/backup_$(date +%Y-%m-%d_%H-%M-%S).log"

# 2. Function to write messages to both console and log file.
log_message() {
    
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

# 3. Pre-backup checks.
log_message "Starting backup process..."

# Check if the source directory exists.
if [ ! -d "$SOURCE_DIR" ]; then
    log_message "ERROR: Source directory '$SOURCE_DIR' does not exist."
    log_message "Backup failed."
    exit 1
fi

# Check if the log directory exists, if not, create it.
if [ ! -d "$LOG_DIR" ]; then
    # The -p flag ensures that parent directories are created if they don't exist.
    mkdir -p "$LOG_DIR"
    if [ $? -ne 0 ]; then
        echo "ERROR: Could not create log directory '$LOG_DIR'. Please check permissions."
        exit 1
    fi
fi

# Add a connection test before attempting the backup.
log_message "Testing connection to $REMOTE_USER@$REMOTE_HOST..."
ssh -o BatchMode=yes -o ConnectTimeout=5 "$REMOTE_USER@$REMOTE_HOST" 'echo "Connection successful"' >> "$LOG_FILE" 2>&1
if [ $? -ne 0 ]; then
    log_message "----------------------------------------------------"
    log_message "ERROR: Could not connect to the remote server."
    log_message "Please check the following:"
    log_message "1. REMOTE_USER ('$REMOTE_USER') and REMOTE_HOST ('$REMOTE_HOST') are correct (check for typos)."
    log_message "2. Passwordless SSH is set up for the user running this script."
    log_message "3. The remote server is online and accessible."
    log_message "----------------------------------------------------"
    exit 1
else
    log_message "Connection test successful."
fi


# Starting the backup using rsync.
log_message "Backing up '$SOURCE_DIR' to '$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR'"

rsync -avz --delete "$SOURCE_DIR" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR" >> "$LOG_FILE" 2>&1

EXIT_CODE=$?

# A zero exit code means success, any other number indicates an error.
if [ $EXIT_CODE -eq 0 ]; then
    log_message "----------------------------------------------------"
    log_message "SUCCESS: Backup completed successfully."
    log_message "Log file available at: $LOG_FILE"
    log_message "----------------------------------------------------"
else
    log_message "----------------------------------------------------"
    log_message "ERROR: Backup failed with exit code $EXIT_CODE."
    log_message "Please check the log file for details: $LOG_FILE"
    log_message "----------------------------------------------------"
fi

exit $EXIT_CODE

