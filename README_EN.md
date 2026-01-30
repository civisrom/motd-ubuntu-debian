# Custom MOTD for Ubuntu/Debian

[Русская версия](README.md)

Customizable Message of the Day (MOTD) for Ubuntu and Debian servers with system information display.

## Features

- **Custom Header** - Personalized ASCII art banner with your name
- **System Information** - Real-time display of:
  - Last login information
  - System uptime
  - CPU load average
  - Memory usage (used/free/total)
  - Disk usage (used/free/total)
  - Active user logins
  - Running processes
  - Service status (Marzban, Caddy, vnStat, UFW)
- **Colorized Output** - Color-coded information for better readability
- **Automatic Backup** - Old MOTD files are backed up before installation

## Installation

### For Ubuntu:
```bash
curl -L https://raw.githubusercontent.com/civisrom/motd-ubuntu-debian/refs/heads/main/scripts/ubuntu.sh > motd_install.sh && sudo chmod +x motd_install.sh && sudo ./motd_install.sh
```

### For Debian:
```bash
curl -L https://raw.githubusercontent.com/civisrom/motd-ubuntu-debian/refs/heads/main/scripts/debian.sh > motd_install.sh && sudo chmod +x motd_install.sh && sudo ./motd_install.sh
```

During installation, you will be prompted to:
1. Confirm installation (press Enter or Y to continue)
2. Enter your custom name for the MOTD header (max 50 characters)

## Requirements

- Root/sudo access
- `curl` for downloading
- Packages (installed automatically):
  - `toilet` - for ASCII art text
  - `colorized-logs` - for color support

## What Gets Installed

The script will:
1. Install required packages
2. Backup existing MOTD to `/etc/update-motd.d/old-motd`
3. Install new MOTD scripts to `/etc/update-motd.d/`
4. Set executable permissions
5. Configure custom header name

## MOTD Components

| File | Description |
|------|-------------|
| `00-header` | Custom ASCII art header with your name |
| `01-last-login` | Last login information |
| `03-uptime` | System uptime |
| `04-load-average` | CPU load average |
| `05-memory` | Memory usage statistics |
| `06-disk-usage` | Disk space usage |
| `07-logins` | Current user logins |
| `08-processes` | Running processes count |
| `09-services` | Service status monitoring |
| `10-docker` | Docker containers (disabled by default) |
| `99-footer` | Footer spacing |

## Customization

### Changing Your Name
Edit `/etc/update-motd.d/00-header` and replace the text in the toilet command:
```bash
sudo nano /etc/update-motd.d/00-header
# Change the name in: toilet -d /etc/update-motd.d/ -f ivrit "your name"
```

### Enabling Docker Monitoring
Uncomment lines in `/etc/update-motd.d/10-docker`:
```bash
sudo nano /etc/update-motd.d/10-docker
# Remove the '#' from the beginning of each line
```

### Adding Custom Services
Edit `/etc/update-motd.d/09-services` to add your services:
```bash
services["your-service"]="Service Name"
services_order+=("your-service")
```

### Customizing Colors
Edit `/etc/update-motd.d/colors.txt` to change color scheme.

## Security Features

- Root privilege verification
- Input validation (name length, special characters)
- Secure sed operations with pipe delimiters
- Error handling for download/extraction failures
- Safe file backup operations

## Uninstallation

To restore original MOTD:
```bash
sudo rm -rf /etc/update-motd.d/*
sudo mv /etc/update-motd.d/old-motd/* /etc/update-motd.d/
sudo rmdir /etc/update-motd.d/old-motd
```

## License

Free to use and modify.

## Author

civisrom
