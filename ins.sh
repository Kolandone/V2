#!/bin/bash

# Define the MTU size and name
new_mtu="1280"
new_name="Koland"

# Run the install.sh script and pipe in the option '1' when prompted
output1=$({ echo "1"; } | bash <(curl -fsSL https://raw.githubusercontent.com/Kolandone/V2/main/installr.sh))

# Extract the IP and port from output1 using grep and awk
new_domain_port=$(echo "$output1" | grep -oP '(\d{1,3}\.){3}\d{1,3}:\d+' | head -n 1)

# Run the install.sh script again and pipe in the options '4' and 'wire-g' when prompted
output2=$({ echo "4"; echo "wire-g"; } | bash <(curl -fsSL https://raw.githubusercontent.com/Kolandone/V2/main/installr.sh))

# Combine outputs
output="$output1\n$output2"

# Use sed to replace the strings in the output
output=$(echo -e "$output" | sed -e "s/engage.cloudflareclient.com:2408/$new_domain_port/g")
output=$(echo -e "$output" | sed -e "s/1280/$new_mtu/g")
output=$(echo -e "$output" | sed -e "s/Koland/$new_name/g")

# Display the modified output
echo -e "$output"
