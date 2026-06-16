#!/bin/bash

# --------------------------
# Restore Backup Script
# --------------------------

# Step 1: Ask for a website name.
echo
read -p "Enter the website name: " WEBSITE_NAME

# Step 2: Access the server.
echo
echo "search "$WEBSITE_NAME""

# Step 2: Access the server.
echo
echo "ssh servername"

# Step 3: Go root in order to find the proper backup files.
echo
echo "sudo su -"

# Step 4: Go to the home directory.
echo
echo "cd /home"

# Step 4: List the backupn files related to the server.
echo
echo "rclone ls Drive:"

# Step 5: Bring the backup file to the server.
echo
echo "rclone copy Drive:cpmove-"ACCOUNT_NAME".tar.gz /home/ --progress"

# Step 6: Restore the account using the backup file.
echo
echo "/scripts/restorepkg "ACCOUNT_NAME".tar.gz" /home

echo
echo "## Restore Backup process completed."


 

