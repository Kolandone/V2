#!/data/data/com.termux/files/usr/bin/bash
set -e

# ---------------- Colors / Banner ----------------
GREEN="\e[32m"; CYAN="\e[36m"; YELLOW="\e[33m"; RED="\e[31m"; RESET="\e[0m"; PURPLE="\e[35m"; WHITE="\e[37m"
ERROR="\e[1;31m"; WARN="\e[93m"; END="\e[0m"

clear
echo -e "${CYAN}*********${RESET}"
echo -e "${CYAN}*${RESET} ${RED}Y${GREEN}O${YELLOW}U${PURPLE}T${CYAN}U${GREEN}B${WHITE}E${RESET} : ${PURPLE}KOLANDONE${RESET} ${CYAN}*${RESET}"
echo -e "${CYAN}*${RESET} ${RED}T${GREEN}E${YELLOW}L${PURPLE}E${CYAN}G${GREEN}R${WHITE}A${RED}M${RESET} : ${PURPLE}KOLANDJS1${RESET} ${CYAN}*${RESET}"
echo -e "${CYAN}*${RESET} ${RED}G${GREEN}I${YELLOW}T${PURPLE}H${CYAN}U${GREEN}B${RESET} : ${PURPLE}https://github.com/Kolandone${RESET} ${CYAN}*${RESET}"
echo -e "${CYAN}*********${RESET}"
echo -e "${CYAN}* ${GREEN}Date:${RESET} $(date '+%Y-%m-%d %H:%M:%S') ${CYAN}*${RESET}"
echo ""

# ---------------- Termux deps ----------------
pkg_install() {
  echo -e "${CYAN}Checking for required packages...${RESET}"
  pkg update -y >/dev/null 2>&1 || true
  pkg install -y curl openssl python xxd coreutils >/dev/null 2>&1
}

for c in curl openssl python xxd base64; do
  if ! command -v "$c" >/dev/null 2>&1; then
    pkg_install
    break
  fi
done

# ---------------- URL encode helper ----------------
urlencode() {
  local string="$1" encoded="" i c
  for ((i=0; i<${#string}; i++)); do
    c="${string:$i:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) encoded+="$c" ;;
      *) printf -v hex '%%%02X' "'$c"; encoded+="$hex" ;;
    esac
  done
  echo "$encoded"
}

# ---------------- AWG 2.0 obfuscation ----------------
generate_awg_obfuscation() {
  local h_min=5 h_max=2147483647 min_band=65536
  local c1_min=$((h_min + min_band - 1))
  local c1_max=$((h_max - 3 * min_band))
  local c1=$(( RANDOM % (c1_max - c1_min + 1) + c1_min ))
  local c2_min=$((c1 + min_band))
  local c2_max=$((h_max - 2 * min_band))
  local c2=$(( RANDOM % (c2_max - c2_min + 1) + c2_min ))
  local c3_min=$((c2 + min_band))
  local c3_max=$((h_max - min_band))
  local c3=$(( RANDOM % (c3_max - c3_min + 1) + c3_min ))

  local h1="${h_min}-${c1}"
  local h2="$((c1 + 1))-${c2}"
  local h3="$((c2 + 1))-${c3}"
  local h4="$((c3 + 1))-${h_max}"

  # S1-S3: 0..64, S4: 0..32
  local s1=$(( RANDOM % 65 ))
  local s2=$(( RANDOM % 65 ))
  local s3=$(( RANDOM % 65 ))
  local s4=$(( RANDOM % 33 ))

  # Jc: 1..25, Jmin: 64..800, Jmax: Jmin+64..1024
  local jc=$(( RANDOM % 25 + 1 ))
  local jmin=$(( RANDOM % 737 + 64 ))
  local jmax=$(( RANDOM % (1024 - jmin - 64 + 1) + jmin + 64 ))

  echo "$jc $jmin $jmax $s1 $s2 $s3 $s4 $h1 $h2 $h3 $h4"
}

# ---------------- WARP register (Cloudflare) ----------------
reg() {
  local keypair private_key public_key
  keypair=$(openssl genpkey -algorithm X25519 | openssl pkey -text -noout)

  private_key=$(echo "$keypair" | awk '/priv:/{flag=1; next} /pub:/{flag=0} flag' | tr -d '[:space:]' | xxd -r -p | base64)
  public_key=$(echo "$keypair"  | awk '/pub:/{flag=1} flag' | tr -d '[:space:]' | xxd -r -p | base64)

  curl -X POST 'https://api.cloudflareclient.com/v0a2158/reg' -sL --tlsv1.3 \
    -H 'CF-Client-Version: a-7.21-0721' \
    -H 'Content-Type: application/json' \
    -d '{ "key":"'"${public_key}"'", "tos":"'"$(date +"%Y-%m-%dT%H:%M:%S.000Z")"'" }' \
  | python -m json.tool \
  | sed "/\"account_type\"/i\ \"private_key\": \"$private_key\","
}

reserved_from_warpinfo() {
  local warp_info="$1"
  local reserved_str reserved_hex reserved_dec
  reserved_str=$(echo "$warp_info" | grep 'client_id' | cut -d\" -f4)
  reserved_hex=$(echo "$reserved_str" | base64 -d | xxd -p)
  reserved_dec=$(echo "$reserved_hex" | fold -w2 | while read -r HEX; do printf '%d ' "0x${HEX}"; done | awk '{print "["$1", "$2", "$3"]"}')
  echo "$reserved_dec"
}

# ---------------- Inputs ----------------
echo -e "${CYAN}Please provide the following details:${RESET}"
read -r -p "Select option (1 for IPv4, 2 for IPv6): " user_choice
read -r -p "Select config type (1 for WireGuard, 2 for AmneziaWG): " config_choice
read -r -p "Enter MTU size (default 1280): " new_mtu
read -r -p "Enter name (default KOLAND): " new_name
new_mtu=${new_mtu:-"1280"}
new_name=${new_name:-"KOLAND"}

# -------- Endpoint selection --------
if [ "$user_choice" == "1" ]; then
  echo -e "${CYAN}Fetching IPv4 address...${RESET}"
  fetched_ip=$(echo "1" | bash <(curl -fsSL https://raw.githubusercontent.com/Kolandone/Selector/main/Sel.sh) \
    | grep -oP '(\d{1,3}\.){3}\d{1,3}:\d+' | head -n 1)
elif [ "$user_choice" == "2" ]; then
  echo -e "${CYAN}Fetching IPv6 address...${RESET}"
  fetched_ip=$(echo "2" | bash <(curl -fsSL https://raw.githubusercontent.com/Kolandone/Selector/main/Sel.sh) \
    | grep -oP '\[\s*[a-fA-F\d:]+\s*\]:\d+\s*\|\s*\d+' \
    | awk '{print $1 " " $3}' | sort -k2 -n | head -n 1 | awk '{print $1}')
else
  echo -e "${RED}Invalid choice. Exiting...${RESET}"
  exit 1
fi

if [ -z "$fetched_ip" ]; then
  echo -e "${RED}Failed to fetch IP. Exiting...${RESET}"
  exit 1
fi

endpoint="$fetched_ip"
echo -e "${GREEN}Fetched endpoint: $endpoint${RESET}"

# -------- WARP account generation --------
echo -e "${CYAN}Generating Warp account...${RESET}"
warp_info="$(reg)"

private_key=$(echo "$warp_info" | grep -oP '"private_key"\s*:\s*"\K[^"]+')
public_key=$(echo "$warp_info"  | grep -oP '"public_key"\s*:\s*"\K[^"]+')

address_ipv4="172.16.0.2"

reserved_bracketed="$(reserved_from_warpinfo "$warp_info")"
reserved_csv="$(echo "$reserved_bracketed" | tr -d '[] ')"

if [[ -z "$private_key" || -z "$public_key" || -z "$reserved_csv" ]]; then
  echo -e "${RED}Error: Failed to parse WARP response.${RESET}"
  echo "$warp_info"
  exit 1
fi

ep_host="${endpoint%:*}"
ep_port="${endpoint##*:}"

# -------- Generate AWG obfuscation if needed --------
if [ "$config_choice" == "2" ]; then
  read -r jc jmin jmax s1 s2 s3 s4 h1 h2 h3 h4 <<< "$(generate_awg_obfuscation)"
fi

# -------- Output --------
echo -e "\n${GREEN}=== WARP Config ($([ "$config_choice" == "2" ] && echo "AmneziaWG" || echo "WireGuard")) ===${RESET}"
echo -e "${CYAN}[Interface]${RESET}"
echo "Address = $address_ipv4/32"
echo "MTU = $new_mtu"
echo "PrivateKey = $private_key"

if [ "$config_choice" == "2" ]; then
  echo "Jc = $jc"
  echo "Jmin = $jmin"
  echo "Jmax = $jmax"
  echo "S1 = $s1"
  echo "S2 = $s2"
  echo "S3 = $s3"
  echo "S4 = $s4"
  echo "H1 = $h1"
  echo "H2 = $h2"
  echo "H3 = $h3"
  echo "H4 = $h4"
fi

echo -e "${CYAN}[Peer]${RESET}"
echo "PublicKey = $public_key"
echo "Endpoint = $endpoint"
echo "AllowedIPs = 0.0.0.0/0"
echo "Reserved = [$reserved_csv]"

# -------- sing-box JSON --------
echo -e "\n${GREEN}=== sing-box JSON ===${RESET}"
cat <<EOF
{
  "endpoints": [
    {
      "type": "$([ "$config_choice" == "2" ] && echo "amnezia" || echo "wireguard")",
      "tag": "warp-ep",
      "mtu": $new_mtu,
      "address": ["$address_ipv4/32"],
      "private_key": "$private_key",
$([ "$config_choice" == "2" ] && cat <<AWG
      "obfs": {
        "enabled": true,
        "type": "amneziawg",
        "jc": $jc,
        "jmin": $jmin,
        "jmax": $jmax,
        "s1": $s1,
        "s2": $s2,
        "s3": $s3,
        "s4": $s4,
        "h1": $h1,
        "h2": $h2,
        "h3": $h3,
        "h4": $h4
      },
AWG
)
      "peers": [
        {
          "address": "$ep_host",
          "port": $ep_port,
          "public_key": "$public_key",
          "allowed_ips": ["0.0.0.0/0"],
          "reserved": [$reserved_csv]
        }
      ]
    }
  ]
}
EOF

# -------- WireGuard URL --------
reserved_encoded=$(urlencode "$reserved_csv")
private_key_encoded=$(urlencode "$private_key")
public_key_encoded=$(urlencode "$public_key")
address_encoded=$(urlencode "$address_ipv4/32")

wg_url="wireguard://$private_key_encoded@$endpoint?address=$address_encoded&reserved=$reserved_encoded&publickey=$public_key_encoded&mtu=$new_mtu#$new_name"

echo -e "\n${CYAN}========================================${RESET}"
echo -e "${YELLOW}$wg_url${RESET}"
echo -e "${CYAN}========================================${RESET}"

# -------- Save output --------
output_file="warp_config_$(date +%H%M%S).txt"
{
  echo "WARP Config ($([ "$config_choice" == "2" ] && echo "AmneziaWG" || echo "WireGuard"))"
  echo "[Interface]"
  echo "Address = $address_ipv4/32"
  echo "MTU = $new_mtu"
  echo "PrivateKey = $private_key"
  if [ "$config_choice" == "2" ]; then
    echo "Jc = $jc"
    echo "Jmin = $jmin"
    echo "Jmax = $jmax"
    echo "S1 = $s1"
    echo "S2 = $s2"
    echo "S3 = $s3"
    echo "S4 = $s4"
    echo "H1 = $h1"
    echo "H2 = $h2"
    echo "H3 = $h3"
    echo "H4 = $h4"
  fi
  echo ""
  echo "[Peer]"
  echo "PublicKey = $public_key"
  echo "Endpoint = $endpoint"
  echo "AllowedIPs = 0.0.0.0/0"
  echo "Reserved = [$reserved_csv]"
  echo ""
  echo "URL: $wg_url"
} > "$output_file"

# -------- Upload --------
echo -e "\n${CYAN}Uploading to sendit.sh...${RESET}"
upload_response="$(curl -sS sendit.sh -T "$output_file" || true)"

if echo "$upload_response" | grep -Eo 'https?://[^ ]+' >/dev/null 2>&1; then
  upload_link="$(echo "$upload_response" | grep -Eo 'https?://[^ ]+' | head -n 1)"
  echo -e "${GREEN}File uploaded!${RESET}"
  echo -e "${CYAN}Share link:${RESET} ${YELLOW}$upload_link${RESET}"
else
  echo -e "${RED}Upload failed.${RESET}"
  echo "$upload_response"
fi
