#!/bin/bash
echo -e "\e[32myoutube:Kolandone\e[0m"

# Function to run wire-g command
run_wire_g() {
    if command -v wire-g &> /dev/null; then
        echo "Running wire-g..."
        wire-g
    else
        echo "wire-g command not found."
        return 1 # Return an error code if wire-g is not found
    fi
}

# Prompt for user input
read -p "Enter the new domain and port (e.g., example.com:1234): " user_input_domain_port
read -p "Enter the new MTU size (default is 1280): " new_mtu
read -p "Enter the new name (default is Koland): " new_name

# Check if the user has provided a domain and port
if [ -z "$user_input_domain_port" ]; then
    echo "No domain and port provided. Fetching from install.sh..."
    fetched_domain_port=$(echo "1" | bash <(curl -fsSL https://raw.githubusercontent.com/Kolandone/V2/main/installr.sh) | grep -oP '(\d{1,3}\.){3}\d{1,3}:\d+' | head -n 1)
    
    if [ -z "$fetched_domain_port" ]; then
        echo "Failed to fetch a valid IP and port. Exiting..."
        exit 1
    else
        new_domain_port=$fetched_domain_port
    fi
else
    new_domain_port=$user_input_domain_port
fi

# Set default values if no input is provided
new_mtu=${new_mtu:-"1280"}
new_name=${new_name:-"Koland"}

# Run the install.sh script
output=$(bash <(curl -fsSL https://raw.githubusercontent.com/Kolandone/V2/main/install.sh))

# After running install.sh, run wire-g and check if it was successful
if run_wire_g; then
    # Use sed to replace the strings in the output
    output=$(echo "$output" | sed -e "s/engage.cloudflareclient.com:2408/$new_domain_port/g")
    output=$(echo "$output" | sed -e "s/1420/$new_mtu/g")
    output=$(echo "$output" | sed -e "s/Peyman_wire-g/$new_name/g")

    # Display the modified output
    echo "$output"
else
    echo "Failed to run wire-g. Please check if it's installed and in your PATH."
fi
