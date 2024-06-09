#!/bin/bash
# Run the installr.sh script and pipe in the option '4' when prompted
{ echo "4"; echo "wire-g"; } | bash <(curl -fsSL https://raw.githubusercontent.com/Kolandone/V2/main/installr.sh)
