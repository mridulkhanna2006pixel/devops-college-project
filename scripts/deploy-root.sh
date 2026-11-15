#!/usr/bin/env bash
# Install a root-owned copy at /usr/local/sbin/deploy-college-site.
# It intentionally accepts no arguments and reads one fixed Jenkins workspace.
set -euo pipefail
readonly SOURCE_DIR="/var/lib/jenkins/workspace/devops-college-project"
readonly DEST_DIR="/var/www/html"
for file in index.html style.css script.js; do
  if [[ ! -f "$SOURCE_DIR/$file" || -L "$SOURCE_DIR/$file" ]]; then
    echo "ERROR: required source file not found: $SOURCE_DIR/$file" >&2
    exit 1
  fi
done
install -o root -g www-data -m 0644 "$SOURCE_DIR/index.html" "$DEST_DIR/index.html"
install -o root -g www-data -m 0644 "$SOURCE_DIR/style.css" "$DEST_DIR/style.css"
install -o root -g www-data -m 0644 "$SOURCE_DIR/script.js" "$DEST_DIR/script.js"
echo "SUCCESS: website files deployed from $SOURCE_DIR to $DEST_DIR"
