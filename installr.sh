#!/bin/bash

# Run the install.sh script
bash <(curl -fsSL https://raw.githubusercontent.com/Ptechgithub/warp/main/endip/install.sh)

# Execute the command '4'


# Run the wire-g command and modify the output
output=$(wire-g)
modified_output=${output//1420/1280}

# Print the new output
echo "$modified_output"
