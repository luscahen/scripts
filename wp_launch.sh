#!/bin/bash

# WordPress Launch site Reference Script 

echo
echo "Make sure we have DNS access to perform the update later."
echo
read -p "Press ENTER to continue..."
echo

echo
read -p "Enter the DEV Website name: " DEV_NAME
read -p "Enter the Target/Live Website name: " TARGET_NAME
echo

# Find the server related to the blueprint/template site.
echo "## Find the respective server of the DEV site LOCATION."
echo "search ${DEV_NAME}"
echo
read -p "Press ENTER to continue..."
echo

echo "## Access the destination server, usually wpa07."
echo "## Go to Transfer Tool, paste the server where the DEV site is located."
echo "## Disable Live Mode."
echo
read -p "Press ENTER to continue..."
echo
echo "## Once the account is transfered, Go to WHM:"
echo "## MultiPHP Manager >> User Domain Settings >> and make sure it is set as inherited."
echo "## List Accounts >> Modify Account >> Change the domain name to the target = $TARGET_NAME site name."
echo
read -p "Press ENTER to continue..."
echo
echo "## Run the following command to find the cPanel username of the account you transfered.."
echo "grep \"$TARGET_NAME\" /etc/userdatadomains"
echo
read -p "Press ENTER to continue..."
echo
read -p "Enter the cPanel username for the site transfered: " TARGET_USER
echo

echo
echo "--- Commands Reference ---"
echo

echo "sudo gouser $TARGET_NAME"

echo "cd public_html/"

echo "wp search-replace '$DEV_NAME' '$TARGET_NAME' --all-tables --recurse-objects --skip-columns=email,guid --dry-run"
echo "wp search-replace '$DEV_NAME' '$TARGET_NAME' --all-tables --recurse-objects --skip-columns=email,guid"

echo "wp cache flush"

echo "wp option set home 'https://$TARGET_NAME'"
echo "wp option set siteurl 'https://$TARGET_NAME'"

echo "wp option get home"

echo "wp option set blog_public 1 # or 0 if it is a subdomain (landing page)"

echo "wp rewrite flush"

echo "wp w3-total-cache flush all # if w3 installed"

echo "wp user list"
echo

NEW_PASS="$(pwgen -n1 -s 16)"
#echo "Generated Password: $NEW_PASS"
echo "wp user update 1 --user_pass="$NEW_PASS""
echo

read -p "Is it requested to update core and plugins? (Y/N): " UPDATE_CHOICE
if [[ "$UPDATE_CHOICE" =~ ^[Yy]$ ]]; then
  echo "wp core update"
  echo "wp plugin update --all"
fi
echo

read -p "Press ENTER to continue..."
echo

echo "less .htaccess"
echo "less wp-config.php"
echo


read -p "Are the Security Headers present? (Y/N): " UPDATE_CHOICE
if [[ "$UPDATE_CHOICE" =~ ^[Nn]$ ]]; then
echo
echo "## If the Security Headers are not present in the .htaccess, add them manually at the top of the file."
echo "nano .htaccess"
echo

cat << 'EOF'
# Added security headers.
<IfModule mod_headers.c>
    Header set X-Content-Type-Options "nosniff"
    Header set X-Frame-Options "SAMEORIGIN"
    Header set X-XSS-Protection "1; mode=block"
    Header set Cache-Control "max-age=18000"
    Header always set Strict-Transport-Security "max-age=7776000; includeSubDomains; preload" "expr=%{HTTPS} == 'on'"
    Header always edit Set-Cookie (.*) "$1; HTTPOnly; Secure"
    Header set Referrer-Policy "strict-origin-when-cross-origin"
    Header set Permissions-Policy "autoplay=(), camera=(), geolocation=(), microphone=(), midi=()"
</IfModule>
EOF
fi

echo

read -p "Is it requested to add 301s? (Y/N): " UPDATE_CHOICE
if [[ "$UPDATE_CHOICE" =~ ^[Yy]$ ]]; then
echo "## Adding 301 redirects using the Redirection Plugin."
echo	"## Go to Plugins >> Redirection Plugin >> Import/Export"
echo	"## Open the 301s file informed in the ticket."
echo	"## Format the file to be able to import, remember to create a new sheet with the two columns only."
echo	"## Download as .csv file."
echo	"## Import the file into the Redirection Plugin."
echo	"## Test the redirects."

fi
echo

read -p "Press ENTER to continue..."
echo

echo "## Update the DNS records now."
echo
echo "## You should use the IP address of the Destination server."
echo "## Create A record."
echo "## Test the propagation."
echo "## Test the website."
echo

read -p "Press ENTER to continue..."
echo

echo "## Run AutoSSL for the user."
echo "## Enable AutoSSL to run automatically for the user."
echo
read -p "Press ENTER to continue..."
echo

echo
echo "## Test the website and the backend to see if it is working properly."
echo "https://$DEV_NAME"
echo "https://$DEV_NAME/wp-admin"

echo
echo "## Go to ManageWP and create the website"
echo "User: bell"
echo "Pass: $NEW_PASS"
echo

echo "## Update the Ticket accordingly."
echo "## Update the Slack channel."
echo "## Remember to Update the Tracking Sheet"
echo
echo "## Dev Site Creation Reference script completed."
echo
