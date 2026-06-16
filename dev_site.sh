#!/bin/bash

clear

# WordPress Dev Site Reference Script
echo
read -p "Enter the DEVSITE website name: " DEV_NAME
read -p "Enter the BLUEPRINT website name: " BLUEPRINT_NAME
echo

# Find the server related to the blueprint/template site.
echo "## Run the following command to find the respective server of the Blueprint/Template site."
echo "search ${BLUEPRINT_NAME}"
echo
read -p "Press ENTER to continue..."
echo

echo "## Make sure the blueprint/template website is under the dev server."
echo "## If needed, transfer the website accordingly."
echo "## Create the Dev Requested website in WHM."

echo
echo "## Locate the cPanel username:"
echo "grep \"$DEV_NAME\" /etc/userdatadomains | awk -F': ' '{print \$2}' | cut -d'=' -f1"
echo "grep \"$BLUEPRINT_NAME\" /etc/userdatadomains | awk -F': ' '{print \$2}' | cut -d'=' -f1"

echo
read -p "Press ENTER to continue..."

# 
read -p "Enter the cPanel username for DEV site: " DEV_USER
read -p "Enter the cPanel username for BLUEPRINT site: " BLUEPRINT_USER
echo

echo
echo "--- Commands Reference ---"
echo

echo "rsync -azvh --chown=$DEV_USER:$DEV_USER /home/$BLUEPRINT_USER/public_html/ /home/$DEV_USER/public_html/"

echo "cd /home/$DEV_USER/"

echo "chown $DEV_USER:nobody public_html"

echo "ll public_html/.htaccess"

echo "grep DB public_html/wp-config.php"

echo "mysqldump ${BLUEPRINT_NAME}_dev > ${BLUEPRINT_NAME}_dev.sql"

# Generating DB credentials automatically
DB_NAME_SUFFIX=$(pwgen -n1 -s 5)
DB_USER_SUFFIX=$(pwgen -n1 -s 5)
DB_PASS=$(pwgen -n1 -s 16)

echo

echo "## New DB credentials:"
echo "DB Name: wp_$DB_NAME_SUFFIX"
echo "DB User: wp_$DB_USER_SUFFIX"
echo "DB Pass: $DB_PASS"
echo "## Go to cPanel and create DB via Database Wizard using the New DB credentials above."

echo

echo "mysql wp_$DB_NAME_SUFFIX < ${BLUEPRINT_NAME}_dev.sql"

echo

echo "sudo gouser $DEV_NAME"
echo "cd public_html/"
echo

echo "##Update the wp-config.php with the correct credentials:"
cat <<EOF
wp config set DB_NAME "wp_$DB_NAME_SUFFIX"
wp config set DB_USER "wp_$DB_USER_SUFFIX"
wp config set DB_PASSWORD "$DB_PASS"
wp config set DB_HOST "localhost"
EOF

echo
echo "wp option get home"
echo "wp option set home 'https://$DEV_NAME'"
echo "wp option set siteurl 'https://$DEV_NAME'"

echo "wp search-replace '$BLUEPRINT_NAME' '$DEV_NAME' --all-tables --recurse-objects --skip-columns=email,guid --dry-run"
echo "wp search-replace '$BLUEPRINT_NAME' '$DEV_NAME' --all-tables --recurse-objects --skip-columns=email,guid"

echo "wp rewrite flush"
echo "wp cache flush"

echo "wp config shuffle-salts"

echo
cat <<'EOF'
wp option update aatxt_typology openai
wp option update aatxt_model_openai gpt-5-mini
wp eval '
  $key = "sk-YOUR-KEY-HERE";
  $encrypted = AATXT\App\Utilities\Encryption::make()->encrypt($key);
  update_option("aatxt_api_key_openai", $encrypted);
  echo "🔑 OpenAI API key saved.\n";
'
wp option update aatxt_preserve_existing_alt_text 1
EOF
echo

echo "wp core update"
echo "wp plugin update --all"
echo "rm -rf wp-content/cache/*"

#Install and enable millicache
cat <<EOF
wp plugin install https://millipress.com/millicache/download --activate
wp config set WP_CACHE true --raw
EOF
echo

cat <<'EOF'
wp plugin install --force --activate "https://updates.superpath.cloud/wp/?action=download&slug=ion-wp-sso"
wp option set ion_disable_wp_login 0
nano pub.key
wp option set ion_public_key --format=plaintext < pub.key
wp cache flush
rm -f pub.key
EOF

### This is not necessary anymore since we are not connecting to ION.
#generating a new password and attributing it to user ID 1 (admin)
#NEW_PASS="$(pwgen -n1 -s 16)"
#echo "wp user update 1 --user_pass="$NEW_PASS""
### ---------

echo
echo "exit"
echo "sudo /root/bin/prefix-update-script/update-wpdb-prefix.sh $DEV_USER"

echo
echo "## Test the website and the backend to see if it is working properly."
echo "https://$DEV_NAME"

echo "## Update the ticket"
echo

echo "## Dev Site Creation Reference script completed."
echo
