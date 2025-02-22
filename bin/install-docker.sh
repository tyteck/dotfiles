#!/bin/bash
# This script is installing docker & compose

# cleaning
sudo apt remove -y docker docker-engine docker.io containerd runc

# requirements
sudo apt update -y && sudo apt install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# installing
sudo apt update -y && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
