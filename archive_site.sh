#!/bin/bash

# --------------------------
# Offboarding Script
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

# Step 3: Ask for the server's name to be used later.
#echo
#echo "What is the servername?" SERVER_NAME

# Step 4: Ask for a cPanel account name.
echo
read -p "Enter the cPanel account name: " ACCOUNT_NAME

# Step 5: Prepare the commands.
echo
echo "Commands Reference:"
echo
echo "cd /home"
echo
echo "/scripts/pkgacct $ACCOUNT_NAME"
echo
echo "rclone copy /home/cpmove-"$ACCOUNT_NAME".tar.gz Drive: --progress"

# step 6: Verify if the backup is in place.
echo
echo "rclone ls Drive: | grep cpmove-"$ACCOUNT_NAME".tar.gz"
echo "https://drive.google.com/drive/folders/1fSomfWja3ucNqN9dUuLlDYe6wTs3s8dB"

# step 7: Remove the cPanel account.
echo
echo "/scripts/removeacct --force "$ACCOUNT_NAME""
echo

echo "## Aarchive process completed."


 

