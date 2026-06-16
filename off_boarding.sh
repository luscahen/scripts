#!/bin/bash

# --------------------------
# Offboarding Script
# --------------------------

# Step 1: Ask for account name
read -p "Enter the account name: " account_name

echo ""
echo "Find the website name for '$account_name', you can use these tools for it::"
echo "1) https://gobellmedia.lightning.force.com/lightning/page/home"
echo "2) https://drive.google.com/drive/shared-drives"
echo ""

# Step 2: Ask for website name
read -p "Enter the website name for '$account_name': " website_name
echo ""
echo "Website set as: $website_name"
echo ""

# Step 3: Find the domain information and server.
    echo "Fetching domain information for $website_name..."
    echo ""
    echo "Registrar:"
    whois "$website_name" | grep -i "Registrar"
    echo ""
    echo "Nameservers:"
    whois "$website_name" | grep -i "Name Server"
    echo ""
    echo "A record:"
    dig +short "$website_name" A
    echo ""
    echo "Suggested command to run manually:"
    echo "search $website_name"
    echo ""

# Step 3:
    echo ""
    echo "If the server was not found, use the following locations:"
    echo "1) https://drive.google.com/drive/shared-drives"
    echo "2) https://securitytrails.com/"
    echo "3) https://tyfoon.azure.bellmedia.io:8443/admin/home/"
    echo "4) https://super-path.atlassian.net/jira/dashboards/last-visited"
    echo "5) https://docs.google.com/spreadsheets/d/1xxVXB41_vZivaBttvaNO2Z6l1mw6TxScQoNqXvNhF6c/edit?pli=1&gid=1750630343#gid=1750630343"
    echo ""

# Step 3: Ask for offboarding type
echo "What type of offboarding is this?"
echo "1) Myce"
echo "2) WordPress"
read -p "Enter 1 for Myce or 2 for WordPress: " offboarding_choice

case $offboarding_choice in
  1)
    guide_url="https://super-path.atlassian.net/wiki/spaces/SA/pages/3482910725/MYCE+Offboarding"
    guide_type="Myce"
        echo ""
        echo "---------------------------------------------"
        echo "Myce OFFBOARDING STEPS"
        echo "---------------------------------------------"
        echo ""
        echo "1. Configure the hosts file:"
        echo "search $website_name"
        echo ""

        echo "nano /etc/hosts"
        echo "10.10.10.10 "$website_name" www."$website_name""
        echo "cd /Users/lucas/projects/client-files"
        echo "suck www."$website_name""
        echo "open ."
        echo ""
        echo "Go to the Google Drive Shared folder and locate the domain is on."
        echo "Drag the zip backup file backed up into the folder."
        echo "Share/Copy the link to the backup and add it to the Teamwork tasks."
        Echo "Make sure to mark as completed and uncheck "Mark as Biliable.""  
        echo ""
        echo "---------------------------------------------"
        echo "MYCE OFFBOARDING COMPLETE ✅"
        echo "---------------------------------------------"
        echo ""
    ;;
  2)
    guide_url="https://super-path.atlassian.net/wiki/spaces/SA/pages/2345205774/WordPress+Customer+Offboarding+Steps"
    guide_type="WordPress"
        echo ""
        echo "---------------------------------------------"
        echo "WORDPRESS OFFBOARDING STEPS"
        echo "---------------------------------------------"
        echo ""
        echo "1. Access the server:"
        echo ""
        echo "   ssh user@servername"
        echo "   sudo su -"
        echo ""
        echo "2. Switch to the site’s user account:"
        echo ""
        echo "   gouser $website_name"
        echo "   cd public_html"
        echo ""
        echo "3. Backup the WordPress site:"
        echo ""
        echo "   wp db export"
        echo "   zip -r ${website_name}-`date +%F`.zip public_html/"
        echo "   pwd"
        echo "   exit"
        echo ""
        echo "4. Upload the backup to Google Drive:"
        echo ""
        echo "   rclone copy ${website_name}-\$(date +%F).zip Drive: --progress"
        echo "   echo '✅ Check if the file was created correctly in Drive.'"
        echo "   rm -rf ${website_name}-\$(date +%F).zip"
        echo ""
        echo "---------------------------------------------"
        echo ""
        echo "5. Salesforce steps:"
        echo ""
        echo "   • Go to Salesforce → Customer Master Files."
        echo "   • If there is no link under “Customer Master Files”, skip this step."
        echo "   • Otherwise, go to Cancellation Files (create if needed)."
        echo "   • Copy the ZIP file link from the WordPress backup."
        echo "   • Adjust sharing permissions and copy the URL."
        echo ""
        echo "---------------------------------------------"
        echo ""
        echo "6. Final Teamwork steps:"
        echo ""
        echo "   • Go to the Teamwork project."
        echo "   • Paste the URL under Links."
        echo ""
        echo "---------------------------------------------"
        echo "WORDPRESS OFFBOARDING COMPLETE ✅"
        echo "---------------------------------------------"
        echo ""
    ;;
  *)
    echo "Invalid choice. Please run the script again and choose 1 or 2."
    exit 1
    ;;
esac


