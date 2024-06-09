#!/bin/bash
# Run the installr.sh script
bash <(curl -fsSL https://raw.githubusercontent.com/Ptechgithub/warp/main/endip/install.sh)

# Automatically select option 4 (Install wire-g)
echo "4" | bash

# Wait for the installation to complete
sleep 2

# Run the wire-g command
wire-g
