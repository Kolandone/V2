#!/bin/bash

# Define the URL of the script
SCRIPT_URL="https://github.com/Ptechgithub/warp/raw/main/wire-g.sh"

# Download and execute the script
curl -s "$SCRIPT_URL" | bash

# Function to run wire-g and modify the output
run_and_modify_output() {
    # Run wire-g and capture the output
    output=$(wire-g)

    # Replace 1420 with 1280 in the output
    modified_output=${output//1420/1280}

    # Print the new output
    echo "$modified_output"
}

# Call the function every time the script starts
run_and_modify_output
