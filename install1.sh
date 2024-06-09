#!/bin/bash

# Prompt for user input
read -p "Enter the new domain and port (e.g., example.com:1234): " new_domain_port
read -p "Enter the new MTU size (default is 1280): " new_mtu
read -p "Enter the new name (default is Koland): " new_name

# Set default values if no input is provided
new_domain_port=${new_domain_port:-"engage.cloudflareclient.com:2408"}
new_mtu=${new_mtu:-"1280"}
new_name=${new_name:-"Koland"}

# Run the installr.sh script and pipe in the option '4' when prompted
output=$({ echo "4"; echo "wire-g"; } | bash <(curl -fsSL https://raw.githubusercontent.com/Kolandone/V2/main/installr.sh))

# Use sed to replace the strings in the output
output=$(echo "$output" | sed -e "s/engage.cloudflareclient.com:2408/$new_domain_port/g")
output=$(echo "$output" | sed -e "s/1420/$new_mtu/g")
output=$(echo "$output" | sed -e "s/Peyman_wire-g/$new_name/g")

# Display the modified output
echo "$output"
