#!/bin/bash
echo -e "\e[32myoutube:Kolandone\e[0m"

# Prompt for user input
read -p "Enter the new domain and port (e.g., example.com:1234): " user_input_domain_port
read -p "Enter the new MTU size (default is 1280): " new_mtu
read -p "Enter the new name (default is Koland): " new_name
read -p "Select an option (1 for IPv4, 2 for IPv6): " user_choice

# Fetch IP address based on user's choice
if [ "$user_choice" == "1" ]; then
    echo "Fetching IPv4 address from install.sh..."
    fetched_ip=$(echo "1" | bash <(curl -fsSL https://raw.githubusercontent.com/Kolandone/Selector/main/Sel.sh) | grep -oP '(\d{1,3}\.){3}\d{1,3}:\d+' | head -n 1)
elif [ "$user_choice" == "2" ]; then
    echo "Fetching IPv6 address from install.sh..."
    fetched_ip=$(echo "2" | bash <(curl -fsSL https://raw.githubusercontent.com/Kolandone/Selector/main/Sel.sh) | grep -oP '(\[?[a-fA-F\d:]+\]?\:\d+)' | head -n 1)
else
    echo "Invalid choice. Exiting..."
    exit 1
fi

# Check if we got a valid IP address
if [ -z "$fetched_ip" ]; then
    echo "Failed to fetch a valid IP address. Exiting..."
    exit 1
else
    new_domain_port=$fetched_ip
fi

# Set default values if no input is provided
new_mtu=${new_mtu:-"1280"}
new_name=${new_name:-"Koland"}

# Run the installr.sh script and pipe in the option '4' when prompted
output=$({ echo "4"; echo "wire-g"; } | bash <(curl -fsSL https://raw.githubusercontent.com/Ptechgithub/warp/main/endip/install.sh))

# Use sed to replace the strings in the output, properly escaping the new domain and port
escaped_domain_port=$(printf '%s\n' "$new_domain_port" | sed 's/[]\/$*.^|[]/\\&/g')
output=$(echo "$output" | sed -e "s|engage.cloudflareclient.com:2408|$escaped_domain_port|g")
output=$(echo "$output" | sed -e "s|1420|$new_mtu|g")
output=$(echo "$output" | sed -e "s|Peyman_wire-g|$new_name|g")

# Display the modified output
echo "$output"
