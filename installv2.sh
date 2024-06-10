 apt update -y
apt install xz-utils bzip2 -y
curl -o $PREFIX/bin/kolandone https://raw.githubusercontent.com/Kolandone/V2/main/kolandone.sh
chmod +x $PREFIX/bin/kolandone
