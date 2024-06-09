#!/usr/bin/expect
spawn bash -c "bash <(curl -fsSL https://raw.githubusercontent.com/Kolandone/V2/main/installr.sh)"
expect "Enter your choice:"
send "4\r"
expect "Run -- >"
send "wire-g\r"
interact
