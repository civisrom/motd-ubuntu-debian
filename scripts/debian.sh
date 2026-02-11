#!/bin/bash
set -uo pipefail

# Check if running as root
if [ "$EUID" -ne 0 ]; then
	echo "Error: This script must be run as root (use sudo)"
	exit 1
fi

#clear
echo "Hi! This script will install custom MOTD for your Debian"
read -p "Continue? [Y/n] " -r REPLY
if [[ $REPLY =~ ^[Yy]?$ ]] || [ -z "$REPLY" ]; then
	# Install packages
	echo "Installing utilities (this may take up to 10 seconds):"
	echo -n "    - updating repos....."
	apt update >> /dev/null 2>&1
	echo "done"
	echo -n "    - toilet............."
	apt install toilet -y >> /dev/null 2>&1
	echo "done"
	echo -n "    - colorized-logs....."
	apt install colorized-logs -y >> /dev/null 2>&1
	echo "done"
	echo "Utilities installed successfully"

	# Download the archive
	echo "Downloading motd"
	if ! curl -L https://github.com/civisrom/motd-ubuntu-debian/archive/refs/heads/main.tar.gz 2>/dev/null | tar -zxv > /dev/null; then
		echo "Error: Failed to download or extract archive"
		exit 1
	fi

	# Move old motd files to directory
	echo "Backing up old motd to /etc/update-motd.d/old-motd"
	mkdir -p /etc/update-motd.d/old-motd
	find /etc/update-motd.d/ -maxdepth 1 -type f -exec mv {} /etc/update-motd.d/old-motd/ \; 2>/dev/null || true

	# Move unzipped motd files to /etc
	echo "Installing motd"
	mv motd-ubuntu-debian-main/motd/* /etc/update-motd.d > /dev/null 2>&1
	rm -f /etc/motd > /dev/null 2>&1
	ln -sf /var/run/motd /etc/motd > /dev/null 2>&1
	echo "Setting permissions"
	chmod 755 /etc/update-motd.d/[0-9][0-9]-*
	chmod 644 /etc/update-motd.d/colors.txt /etc/update-motd.d/ivrit.flf

	# Prompt for custom name
	echo ""
	read -p "Enter your name for MOTD header: " -r MOTD_NAME
	if [ -n "$MOTD_NAME" ]; then
		# Remove newlines and carriage returns
		MOTD_NAME=$(echo "$MOTD_NAME" | tr -d '\n\r')

		# Limit length to 50 characters
		if [ ${#MOTD_NAME} -gt 50 ]; then
			echo "Warning: Name too long, truncating to 50 characters"
			MOTD_NAME="${MOTD_NAME:0:50}"
		fi

		# Replace name in header file
		if [ -f "/etc/update-motd.d/00-header" ]; then
			sed -i "s|you name|$MOTD_NAME|g" /etc/update-motd.d/00-header
			echo "MOTD name set to: $MOTD_NAME"
		else
			echo "Warning: 00-header file not found"
		fi
	else
		echo "No name provided, keeping default 'you name'"
	fi

	# Clean up downloaded files
	echo "Cleaning up"
	rm -rf motd-ubuntu-debian-main > /dev/null 2>&1
	rm -- "$0"
	echo "Done!"
else
	rm -- "$0"
	echo "Installation has been cancelled. Bye!"
fi
