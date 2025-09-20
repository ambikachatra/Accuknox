#!/bin/bash

# ========================================================================================
# Set the thresholds for alerts (as percentages, except for processes).
CPU_THRESHOLD=70
MEMORY_THRESHOLD=90
DISK_THRESHOLD=15
PROCESS_THRESHOLD=500

# Set the log file path.
LOG_FILE="/var/log/system_health.log"

# --- Functions ---

# Arguments: $1: Alert message string
log_alert() {
  local message="$1"
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "${timestamp} [ALERT] - ${message}" | tee -a "${LOG_FILE}"
}

# Function to check CPU usage.
check_cpu_usage() {
  # Calculate current CPU usage.
  # It subtracts the idle percentage from 100 to get the total usage.
  local cpu_idle=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/")
  local cpu_usage=$(echo "100 - ${cpu_idle}" | bc)
  
  # Round to the nearest integer for comparison.
  local cpu_usage_int=$(printf "%.0f" "${cpu_usage}")
  
  echo "INFO: Current CPU Usage is ${cpu_usage_int}%"
  
  if [ "${cpu_usage_int}" -gt "${CPU_THRESHOLD}" ]; then
    log_alert "High CPU Usage Detected: ${cpu_usage_int}% (Threshold: ${CPU_THRESHOLD}%)"
  fi
}

# Function to check memory usage.
check_memory_usage() {
  # Calculate the percentage of used memory.
  local mem_usage=$(free | awk '/Mem/ {printf "%.0f", $3/$2 * 100.0}')
  
  echo "INFO: Current Memory Usage is ${mem_usage}%"

  if [ "${mem_usage}" -gt "${MEMORY_THRESHOLD}" ]; then
    log_alert "High Memory Usage Detected: ${mem_usage}% (Threshold: ${MEMORY_THRESHOLD}%)"
  fi
}

# Function to check disk space usage.
check_disk_usage() {
  echo "INFO: Checking disk space usage..."
  # Loop through all mounted filesystems starting with '/dev/'.
  df -h | grep '^/dev/' | while read -r line; do
    local usage=$(echo "${line}" | awk '{print $5}' | sed 's/%//')
    local filesystem=$(echo "${line}" | awk '{print $1}')
    local mount_point=$(echo "${line}" | awk '{print $6}')
    
    if [ "${usage}" -gt "${DISK_THRESHOLD}" ]; then
      log_alert "High Disk Usage on ${filesystem} (${mount_point}): ${usage}% (Threshold: ${DISK_THRESHOLD}%)"
    fi
  done
}

# Function to check the number of running processes.
check_running_processes() {
  local process_count=$(ps -e --no-headers | wc -l)
  
  echo "INFO: Current number of running processes is ${process_count}"

  if [ "${process_count}" -gt "${PROCESS_THRESHOLD}" ]; then
    log_alert "High Number of Running Processes: ${process_count} (Threshold: ${PROCESS_THRESHOLD})"
  fi
}

# --- Main Script Execution ---
echo "--- Starting System Health Check at $(date) ---"

check_cpu_usage
check_memory_usage
check_disk_usage
check_running_processes

echo "--- Health Check Completed ---"
echo ""
