#!/bin/bash

# Define the new domain and port, MTU size, and name
new_domain_port="example.com:1234"
new_mtu="1280"
new_name="Koland"

# Run the install.sh script and pipe in the option '1' when prompted
output1=$({ echo "1"; } | bash <(curl -fsSL https://raw.githubusercontent.com/Ptechgithub/warp/main/endip/install.sh) 2>&1)

# Run the install.sh script again and pipe in the options '4' and 'wire-g' when prompted
output2=$({ echo "4"; echo "wire-g"; } | bash <(curl -fsSL https://raw.githubusercontent.com/Ptechgithub/warp/main/endip/install.sh) 2>&1)

# Combine outputs
combined_output="$output1\n$output2"

# Use sed to replace the strings in the output
modified_output=$(echo -e "$combined_output" | sed -e "s/engage.cloudflareclient.com:2408/$new_domain_port/g")
modified_output=$(echo -e "$modified_output" | sed -e "s/1280/$new_mtu/g")
modified_output=$(echo -e "$modified_output" | sed -e "s/Peyman_wire-g/$new_name/g")

# Display the modified output
echo -e "$modified_output"
