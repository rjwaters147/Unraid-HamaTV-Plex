#!/bin/bash

# Variables
PLEX_CONTAINER="Plex-Media-Server"
PLEX_APPDATA="/mnt/user/appdata/Plex-Media-Server"
PLUGINS_DIR="$PLEX_APPDATA/Library/Application Support/Plex Media Server/Plug-ins"
SCANNERS_DIR="$PLEX_APPDATA/Library/Application Support/Plex Media Server/Scanners/Series"
HAMA_BUNDLE_REPO="https://github.com/ZeroQI/Hama.bundle.git"
SCANNER_SCRIPT_URL="https://raw.githubusercontent.com/ZeroQI/Absolute-Series-Scanner/master/Scanners/Series/Absolute%20Series%20Scanner.py"
HAMA_DATA_DIR="$PLEX_APPDATA/Library/Application Support/Plex Media Server/Plug-in Support/Data/com.plexapp.agents.hama"
USER_GROUP="nobody:users"

# Stop Plex Media Server
if docker ps | grep -q $PLEX_CONTAINER; then
    if ! docker stop $PLEX_CONTAINER; then
        echo "Failed to stop Docker container $PLEX_CONTAINER."
        exit 1
    fi
else
    echo "$PLEX_CONTAINER is not running."
fi

# Install Hama.bundle
if cd "$PLUGINS_DIR"; then
    if [ ! -d "Hama.bundle" ]; then
        if ! git clone $HAMA_BUNDLE_REPO; then
            echo "Failed to clone Hama.bundle repository."
            exit 1
        fi
    fi
    chown -R $USER_GROUP "Hama.bundle"
    chmod 775 -R "Hama.bundle"
else
    echo "Failed to change directory to $PLUGINS_DIR"
    exit 1
fi

# Install Absolute Series Scanner
mkdir -p "$SCANNERS_DIR"
if ! wget -O "$SCANNERS_DIR/Absolute Series Scanner.py" $SCANNER_SCRIPT_URL; then
    echo "Failed to download Absolute Series Scanner script."
    exit 1
fi
chown -R $USER_GROUP "$SCANNERS_DIR"
chmod 775 -R "$SCANNERS_DIR"

# Create required directories for Hama Data
mkdir -p "$HAMA_DATA_DIR/DataItems/AniDB" \
         "$HAMA_DATA_DIR/DataItems/Plex" \
         "$HAMA_DATA_DIR/DataItems/OMDB" \
         "$HAMA_DATA_DIR/DataItems/TMDB" \
         "$HAMA_DATA_DIR/DataItems/TVDB/blank" \
         "$HAMA_DATA_DIR/DataItems/TVDB/_cache/fanart/original" \
         "$HAMA_DATA_DIR/DataItems/TVDB/episodes" \
         "$HAMA_DATA_DIR/DataItems/TVDB/fanart/original" \
         "$HAMA_DATA_DIR/DataItems/TVDB/fanart/vignette" \
         "$HAMA_DATA_DIR/DataItems/TVDB/graphical" \
         "$HAMA_DATA_DIR/DataItems/TVDB/posters" \
         "$HAMA_DATA_DIR/DataItems/TVDB/seasons" \
         "$HAMA_DATA_DIR/DataItems/TVDB/seasonswide" \
         "$HAMA_DATA_DIR/DataItems/TVDB/text" \
         "$HAMA_DATA_DIR/DataItems/FanartTV"

# Set ownership and permissions for Hama Data
chown -R $USER_GROUP "$HAMA_DATA_DIR"
chmod 775 -R "$HAMA_DATA_DIR"

# Start Plex Media Server
if ! docker start $PLEX_CONTAINER; then
    echo "Failed to start Docker container $PLEX_CONTAINER."
    exit 1
fi

echo "HamaTV Metadata agent and Absolute Series Scanner installed successfully."