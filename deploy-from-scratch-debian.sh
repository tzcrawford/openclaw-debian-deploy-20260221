#!/bin/bash

sudo apt update -y || exit
sudo apt upgrade -y || exit
sudo apt install -y sudo vim git tmux firefox-esr xauth alacritty htop lsof || exit

sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
swapon --show
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

NEWUSERNAME="user"
SSH_KEY_COMMENT="$NEWUSERNAME@$(hostname)-$(date -I)"

echo "Creating user: $NEWUSERNAME"

# Create user with home directory and bash shell
if id "$NEWUSERNAME" &>/dev/null; then
    echo "User $NEWUSERNAME already exists. Skipping creation."
else
    useradd -m -s /bin/bash "$NEWUSERNAME"
fi

# Set password
passwd "$NEWUSERNAME"

# Add user to sudo group
usermod -aG sudo "$NEWUSERNAME"
usermod -aG wheel "$NEWUSERNAME"

# Create .ssh directory
sudo -u "$NEWUSERNAME" ssh-keygen -t ed25519 -C "$SSH_KEY_COMMENT"
sudo -u "$NEWUSERNAME" echo "EDITOR=vim" >> .bashrc
sudo -u "$NEWUSERNAME" echo "SUDO_EDITOR=vim" >> .bashrc

echo -e "Paste the following in sudoers (press enter to trigger):\n%wheel ALL=(ALL) NOPASSWD: ALL"
read
SUDO_EDITOR=vim sudoedit /etc/sudoers


