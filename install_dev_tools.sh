#!/bin/bash

set -e

# Оновлення списку пакетів
sudo apt update

#########################################
# Docker
#########################################
if command -v docker &> /dev/null; then
    echo "[✓] Docker вже встановлений."
else
    echo "[...] Встановлення Docker..."

    # Add Docker's official GPG key:
    sudo apt update
    sudo apt install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
    Types: deb
    URIs: https://download.docker.com/linux/ubuntu
    Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
    Components: stable
    Architectures: $(dpkg --print-architecture)
    Signed-By: /etc/apt/keyrings/docker.asc
    EOF

    sudo apt update

    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo systemctl status docker

    sudo systemctl start docker

    sudo usermod -aG docker "$USER"

    echo "[✓] Docker встановлено."
fi

#########################################
# Docker Compose
#########################################
if docker compose version &> /dev/null; then
    echo "[✓] Docker Compose вже встановлений."
else
    echo "[...] Встановлення Docker Compose..."

    sudo apt update

    sudo apt install -y docker-compose-plugin

    echo "[✓] Docker Compose встановлено."
fi

#########################################
# Python 3.14
#########################################
if command -v python3.14 &> /dev/null; then
    echo "[✓] Python3.14 вже встановлений."
else
    echo "[...] Встановлення Python3.14..."

    sudo apt update
    sudo apt install -y software-properties-common

    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt update

    sudo apt install -y python3.14 python3.14-venv python3.14-dev

    echo "[✓] Python3 встановлено."
fi

#########################################
# pip
#########################################
if python3.14 -m pip --version &> /dev/null; then
    echo "[✓] pip для Python 3.14 вже встановлений."
else
    echo "[...] Встановлення pip..."

    python3.14 -m ensurepip --upgrade

    echo "[✓] pip встановлено."
fi

#########################################
# Django
#########################################
if python3.14 -m django --version &> /dev/null; then
    echo "[✓] Django вже встановлений."
else
    echo "[...] Встановлення Django..."

    python3.14 -m pip install Django --break-system-packages

    echo "[✓] Django встановлено."
fi

#########################################
# Версії
#########################################

echo
echo "========== Встановлені версії =========="

docker --version
docker compose version
python3 --version
pip3 --version
python3 -m django --version