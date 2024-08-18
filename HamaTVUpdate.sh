#!/bin/bash
set -e

# Variables
PLEX_CONTAINER="Plex-Media-Server"
PLEX_APPDATA="/mnt/user/appdata/Plex-Media-Server/Library/Application Support/Plex Media Server"
PLUGINS_DIR="${PLEX_APPDATA}/Plug-ins/Hama.bundle"
SCANNERS_DIR="${PLEX_APPDATA}/Scanners/Series"
SCANNER_SCRIPT_URL="https://raw.githubusercontent.com/ZeroQI/Absolute-Series-Scanner/master/Scanners/Series/Absolute%20Series%20Scanner.py"
SCANNER_LOCAL_FILE="${SCANNERS_DIR}/Absolute Series Scanner.py"
USER_GROUP="nobody:users"

# Flags to track whether updates are needed
NEED_UPDATE=false

# Check if Hama.bundle needs an update
if ! git config --global --get-all safe.directory | grep -Fxq "$PLUGINS_DIR"; then
    git config --global --add safe.directory "$PLUGINS_DIR"
fi

if cd "$PLUGINS_DIR"; then
    if ! git fetch; then
        echo "Failed to fetch updates from the repository."
        exit 1
    fi

    if ! git diff --quiet HEAD origin/master; then
        echo "Hama.bundle update needed."
        NEED_UPDATE=true
    fi
else
    echo "Failed to change directory to $PLUGINS_DIR."
    exit 1
fi

# Check if Absolute Series Scanner script needs an update
if [ -f "$SCANNER_LOCAL_FILE" ]; then
    LOCAL_HASH=$(sha256sum "$SCANNER_LOCAL_FILE" | awk '{ print $1 }')
    REMOTE_HASH=$(wget -qO- "$SCANNER_SCRIPT_URL" | sha256sum | awk '{ print $1 }')

    if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
        echo "Absolute Series Scanner script update needed."
        NEED_UPDATE=true
    fi
else
    echo "Downloading Absolute Series Scanner script for the first time..."
    NEED_UPDATE=true
fi

# Stop Plex only if an update is needed
if $NEED_UPDATE; then
    if [ "$(docker inspect -f '{{.State.Running}}' $PLEX_CONTAINER)" == "true" ]; then
        if ! docker stop $PLEX_CONTAINER; then
            echo "Failed to stop Docker container $PLEX_CONTAINER."
            exit 1
        fi
    fi

    # Apply updates if needed
    if ! git diff --quiet HEAD origin/master; then
        if ! git reset --hard HEAD && git pull; then
            echo "Failed to update the Hama.bundle."
            exit 1
        fi
        chown -R $USER_GROUP "$PLUGINS_DIR"
        chmod 775 -R "$PLUGINS_DIR"
    fi

    if [ ! -f "$SCANNER_LOCAL_FILE" ] || [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
        if ! wget -O "$SCANNER_LOCAL_FILE" "$SCANNER_SCRIPT_URL"; then
            echo "Failed to download the Absolute Series Scanner script."
            exit 1
        fi
        chown -R $USER_GROUP "${PLEX_APPDATA}/Scanners"
        chmod 775 -R "${PLEX_APPDATA}/Scanners"
    fi

    # Restart Plex after updates
    if ! docker start $PLEX_CONTAINER; then
        echo "Failed to start Docker container $PLEX_CONTAINER."
        exit 1
    fi

    echo "Updates applied. Plex Media Server is running."
else
    echo "No updates needed. Plex Media Server continues running."
fi