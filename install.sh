 apt update -y
apt install wireguard-tools jq xz-utils bzip2 -y
curl -o $PREFIX/bin/wire-g https://raw.githubusercontent.com/Ptechgithub/warp/main/wire-g.sh
chmod +x $PREFIX/bin/wire-g
