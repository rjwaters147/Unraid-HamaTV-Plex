# HamaTV Plex Media Server Scripts

This repository contains two shell scripts to install and update the HamaTV Metadata agent and Absolute Series Scanner for Plex Media Server on a Linux system, specifically designed for use with Unraid. These scripts are intended to be run using the Unraid UserScripts plugin for easy automation and scheduling.

HAMATV: https://github.com/ZeroQI/Hama.bundle
Absolute-Series-Scanner: https://github.com/ZeroQI/Absolute-Series-Scanner

This script does not alter HamaTV or Absolute-Series-Scanner in anyway, it simply just installs or updates them so you don't have to do it manually.

## Purpose

- **HamaTVInstall.sh**: Installs the HamaTV Metadata agent and the Absolute Series Scanner for Plex Media Server.
- **HamaTVUpdate.sh**: Updates the HamaTV Metadata agent and the Absolute Series Scanner, checking for changes before stopping the Plex Media Server to minimize downtime.

## Requirements

- **Unraid OS**: These scripts are designed to be run on Unraid.
- **UserScripts Plugin**: The scripts are intended to be used with the Unraid UserScripts plugin for scheduling and automation.
- **Docker**: Plex Media Server must be running in a Docker container.

## Usage

### HamaTVInstall.sh

This script installs the HamaTV Metadata agent and the Absolute Series Scanner for Plex Media Server. It will:

1. Stop the Plex Media Server Docker container.
2. Clone the Hama.bundle from GitHub into the appropriate Plex directory.
3. Download the Absolute Series Scanner script.
4. Set appropriate permissions for the files and directories.
5. Start the Plex Media Server Docker container.

#### How to Run:

1. Install the UserScripts plugin from the Unraid Community Applications.
2. Create a new script in UserScripts and paste the contents of `HamaTVInstall.sh`.
3. Run the script manually to install HamaTV and the Absolute Series Scanner.

### HamaTVUpdate.sh

This script checks for updates to the HamaTV Metadata agent and the Absolute Series Scanner. If updates are needed, it will stop the Plex Media Server, apply the updates, and restart the server. The script ensures that Plex is only stopped if updates are necessary.

#### How to Run:

1. Install the UserScripts plugin from the Unraid Community Applications.
2. Create a new script in UserScripts and paste the contents of `HamaTVUpdate.sh`.
3. Schedule the script to run monthly or as desired to keep your HamaTV agent and scanner up-to-date.

### Variables

The following variables are used in both scripts. You may modify these if your setup differs from the default:

- `PLEX_CONTAINER`: The name of your Plex Media Server Docker container. Default: `Plex-Media-Server`.
- `PLEX_APPDATA`: The path to your Plex Media Server appdata directory. Default: `/mnt/user/appdata/Plex-Media-Server/Library/Application Support/Plex Media Server`.
- `PLUGINS_DIR`: The directory where Plex plugins are stored. Default: `${PLEX_APPDATA}/Plug-ins/Hama.bundle`.
- `SCANNERS_DIR`: The directory where Plex scanners are stored. Default: `${PLEX_APPDATA}/Scanners/Series`.
- `SCANNER_SCRIPT_URL`: The URL to download the Absolute Series Scanner script. Default: `https://raw.githubusercontent.com/ZeroQI/Absolute-Series-Scanner/master/Scanners/Series/Absolute%20Series%20Scanner.py`.
- `USER_GROUP`: The user and group that own the Plex directories. Default: `nobody:users`.

## Unraid UserScripts Plugin

These scripts are intended to be used with the [UserScripts](https://forums.unraid.net/topic/48286-plugin-ca-user-scripts/) plugin for Unraid. The UserScripts plugin allows you to create custom scripts and schedule them to run at specific times, making it perfect for automating tasks like installing and updating plugins for Plex.