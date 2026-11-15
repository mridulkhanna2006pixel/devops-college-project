#!/usr/bin/env bash
# Run as an administrator on EC2. Installs Nginx and a narrow deploy permission.
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sudo apt update
sudo apt install -y nginx curl
sudo systemctl enable --now nginx
sudo install -o root -g root -m 0755 "$PROJECT_DIR/scripts/deploy-root.sh" /usr/local/sbin/deploy-college-site
printf '%s\n' 'jenkins ALL=(root) NOPASSWD: /usr/local/sbin/deploy-college-site' | sudo tee /etc/sudoers.d/jenkins-deploy >/dev/null
sudo chmod 0440 /etc/sudoers.d/jenkins-deploy
sudo visudo -cf /etc/sudoers.d/jenkins-deploy
sudo nginx -t
sudo systemctl is-active nginx
echo 'Nginx is ready. The deploy helper is root-owned and Jenkins has permission to run only that helper.'
