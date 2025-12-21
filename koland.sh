#!/bin/bash

clear

GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"
PURPLE="\e[35m"
WHITE="\e[37m"

echo -e "${CYAN}*****************************************${RESET}"
echo -e "${CYAN}*${RESET} ${RED}Y${GREEN}O${YELLOW}U${PURPLE}T${CYAN}U${GREEN}B${WHITE}E${RESET} : ${PURPLE}KOLANDONE${RESET}         ${CYAN}*${RESET}"
echo -e "${CYAN}*${RESET} ${RED}T${GREEN}E${YELLOW}L${PURPLE}E${CYAN}G${GREEN}R${WHITE}A${RED}M${RESET} : ${PURPLE}KOLANDJS1${RESET}         ${CYAN}*${RESET}"
echo -e "${CYAN}*${RESET} ${RED}G${GREEN}I${YELLOW}T${PURPLE}H${CYAN}U${GREEN}B${RESET} : ${PURPLE}https://github.com/Kolandone${RESET} ${CYAN}*${RESET}"
echo -e "${CYAN}*****************************************${RESET}"
echo -e "${CYAN}* ${GREEN}Date:${RESET} $(date '+%Y-%m-%d %H:%M:%S') ${CYAN}*${RESET}"
echo ""

pkg_install() {
    echo -e "${CYAN}Checking for required packages...${RESET}"
    pkg update -y && pkg install curl -y
}

if ! command -v curl >/dev/null 2>&1; then
    pkg_install
fi

urlencode() {
    local string="$1"
    local encoded=""
    local i
    for ((i=0; i<${#string}; i++)); do
        local c="${string:$i:1}"
        case "$c" in
            [a-zA-Z0-9.~_-]) encoded+="$c" ;;
            *) printf -v hex '%%%02X' "'$c"; encoded+="$hex" ;;
        esac
    done
    echo "$encoded"
}

echo -e "${CYAN}Please provide the following details:${RESET}"
read -p "Select an option (1 for IPv4, 2 for IPv6): " user_choice
read -p "Enter the new MTU size (default is 1280): " new_mtu
read -p "Enter the new name (default is KOLAND): " new_name

new_mtu=${new_mtu:-"1280"}
new_name=${new_name:-"KOLAND"}

if [ "$user_choice" == "1" ]; then
    echo -e "${CYAN}Fetching IPv4 address...${RESET}"
    fetched_ip=$(echo "1" | bash <(curl -fsSL https://raw.githubusercontent.com/Kolandone/Selector/main/Sel.sh) | grep -oP '(\d{1,3}\.){3}\d{1,3}:\d+' | head -n 1)
elif [ "$user_choice" == "2" ]; then
    echo -e "${CYAN}Fetching IPv6 address...${RESET}"
    fetched_ip=$(echo "2" | bash <(curl -fsSL https://raw.githubusercontent.com/Kolandone/Selector/main/Sel.sh) | grep -oP '\[\s*[a-fA-F\d:]+\s*\]:\d+\s*\|\s*\d+' | awk '{print $1 " " $3}' | sort -k2 -n | head -n 1 | awk '{print $1}')
else
    echo -e "${RED}Invalid choice. Exiting...${RESET}"
    exit 1
fi

if [ -z "$fetched_ip" ]; then
    echo -e "${RED}Failed to fetch a valid IP address. Exiting...${RESET}"
    exit 1
else
    new_endpoint="$fetched_ip"
    echo -e "${GREEN}Fetched endpoint: $new_endpoint${RESET}"
fi

echo -e "${CYAN}Generating Warp account...${RESET}"
response=$(curl -s "https://fscarmen.cloudflare.now.cc/doGenerate")

if [[ -z "$response" ]]; then
    echo -e "${RED}Error: Empty response from API.${RESET}"
    exit 1
fi

private_key=$(echo "$response" | grep "PrivateKey" | awk -F '= ' '{print $2}' | head -n 1)
address_ipv4=$(echo "$response" | grep "Address" | awk -F '= ' '{print $2}' | head -n 1)
address_ipv6=$(echo "$response" | grep "Address" | awk -F '= ' '{print $2}' | tail -n 1)
public_key=$(echo "$response" | grep "PublicKey" | awk -F '= ' '{print $2}' | head -n 1)
reserved=$(echo "$response" | grep "Reserved" | awk -F '= ' '{print $2}' | head -n 1 | tr -d '[] ' | sed 's/[^0-9,]*//g')

endpoint="$new_endpoint"

echo -e "\n${GREEN}=== Warp Account Details ===${RESET}"
echo -e "${CYAN}[Interface]${RESET}"
echo "Address = $address_ipv4/32, $address_ipv6/128"
echo "MTU = $new_mtu"
echo "PrivateKey = $private_key"
echo -e "${CYAN}[Peer]${RESET}"
echo "PublicKey = $public_key"
echo "Endpoint = $endpoint"

# --- JSON Endpoint Processing ---
ep_host="${endpoint%:*}"
ep_port="${endpoint##*:}"

echo -e "\n${GREEN}=== Endpoint JSON Config ===${RESET}"
cat << EOF
{
  "endpoints": [
    {
      "type": "wireguard",
      "tag": "warp-ep",
      "mtu": $new_mtu,
      "address": [
        "$address_ipv4/32",
        "$address_ipv6/128"
      ],
      "private_key": "$private_key",
      "peers": [
        {
          "address": "$ep_host",
          "port": $ep_port,
          "public_key": "$public_key",
          "allowed_ips": [
            "0.0.0.0/0",
            "::/0"
          ],
          "reserved": [$reserved]
        }
      ]
    }
  ]
}
EOF

reserved_encoded=$(urlencode "$reserved")
private_key_encoded=$(urlencode "$private_key")
public_key_encoded=$(urlencode "$public_key")
address_encoded=$(urlencode "$address_ipv4/32,$address_ipv6/128")
wg_url="wireguard://$private_key_encoded@$endpoint?address=$address_encoded&reserved=$reserved_encoded&publickey=$public_key_encoded&mtu=$new_mtu#$new_name"

echo -e "\n${CYAN}========================================${RESET}"
echo -e "${YELLOW}$wg_url${RESET}"
echo -e "${CYAN}========================================${RESET}"

output_file="warp_config_$(date +%H%M%S).txt"
{
    echo "WireGuard Config"
    echo "Address = $address_ipv4/32, $address_ipv6/128"
    echo "PrivateKey = $private_key"
    echo "PublicKey = $public_key"
    echo "Endpoint = $endpoint"
    echo "Reserved = $reserved"
    echo "URL: $wg_url"
} > "$output_file"


echo -e "\n${CYAN}Uploading to bashupload.com...${RESET}"

upload_response=$(curl -s https://bashupload.com/ -F "file=@$output_file")
upload_link=$(echo "$upload_response" | grep -o 'https://bashupload.com/[^ ]*' | head -n 1)

if [ -n "$upload_link" ]; then
    echo -e "${GREEN}File uploaded successfully!${RESET}"
    echo -e "${CYAN}Share link:${RESET} ${YELLOW}$upload_link${RESET}"
else
    echo -e "${RED}Upload failed. Checking response...${RESET}"
    echo "$upload_response"
fi

