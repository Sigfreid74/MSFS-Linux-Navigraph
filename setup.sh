#!/bin/bash

echo "====================================================="
echo "   Navigraph Simlink Setup for MSFS 2020 (Flatpak)   "
echo "====================================================="
echo ""

APP_ID="1250410"
FLATPAK_HOME="$HOME/.var/app/com.valvesoftware.Steam"
STEAM_ROOT="$FLATPAK_HOME/.local/share/Steam"

# --- STEP 1: DETECT STEAM LIBRARY PATH ---
echo "Searching for MSFS 2020 installation..."

if [ -d "$STEAM_ROOT/steamapps/compatdata/$APP_ID" ]; then
    LIB_PATH="$STEAM_ROOT"
    echo "Found MSFS in default Flatpak directory."
elif [ -d "/var/steam-library/steamapps/compatdata/$APP_ID" ]; then
    LIB_PATH="/var/steam-library"
    echo "Found MSFS in custom /var/steam-library directory."
else
    echo "MSFS 2020 compatdata not found in default locations."
    read -p "Please enter the path to the Steam Library containing MSFS (e.g., /mnt/games/SteamLibrary): " LIB_PATH
    
    # Verify the user-provided path
    if [ ! -d "$LIB_PATH/steamapps/compatdata/$APP_ID" ]; then
        echo "Error: Could not find MSFS prefix at $LIB_PATH/steamapps/compatdata/$APP_ID"
        echo "Please check your path and run this script again."
        exit 1
    fi
fi

echo ""

# --- STEP 2: CREATE DESKTOP FILE FOR OAUTH LOGIN ---
echo "Creating Navigraph Oauth Login Handler..."
mkdir -p ~/.local/share/applications

cat << EOF > ~/.local/share/applications/Navigraph-Simlink.desktop
[Desktop Entry]
Name=Navigraph Simlink
Comment=Navigraph Simlink (Proton - runs in MSFS prefix)
Exec=env STEAM_COMPAT_CLIENT_INSTALL_PATH='$STEAM_ROOT' STEAM_COMPAT_DATA_PATH='$LIB_PATH/steamapps/compatdata/$APP_ID' '$STEAM_ROOT/steamapps/common/Proton - Experimental/proton' run '$LIB_PATH/steamapps/compatdata/$APP_ID/pfx/drive_c/Program Files/Navigraph/Simlink/NavigraphSimlink.exe' %u
Type=Application
MimeType=x-scheme-handler/navigraph-traffic-desktop;
Categories=Game;Simulation;
NoDisplay=false
StartupNotify=true
Terminal=false
Path=$LIB_PATH/steamapps/compatdata/$APP_ID/pfx/drive_c
EOF

# --- STEP 3: REGISTER MIME TYPES ---
echo "Registering protocol handlers (gio & xdg-mime)..."
gio mime x-scheme-handler/navigraph-traffic-desktop Navigraph-Simlink.desktop >/dev/null 2>&1
xdg-mime default Navigraph-Simlink.desktop x-scheme-handler/navigraph-traffic-desktop >/dev/null 2>&1
update-desktop-database ~/.local/share/applications >/dev/null 2>&1

# --- STEP 4: CREATE THE FLATPAK WRAPPER SCRIPT ---
echo "Creating Steam launch wrapper script..."

# We write the script with a placeholder for the library path, then replace it.
# This avoids variable expansion issues inside the 'EOF' block for $HOME.
cat << 'EOF' > "$FLATPAK_HOME/navigraph_wrapper.sh"
#!/bin/bash
# 1. Start Simlink in the background with a 30-second delay
(sleep 30 && \
STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam" \
STEAM_COMPAT_DATA_PATH="___LIB_PATH___/steamapps/compatdata/1250410" \
"$HOME/.local/share/Steam/steamapps/common/Proton - Experimental/proton" \
run "___LIB_PATH___/steamapps/compatdata/1250410/pfx/drive_c/Program Files/Navigraph/Simlink/NavigraphSimlink.exe") &

# 2. Launch MSFS 2020
exec "$@"
EOF

# Inject the detected library path into the wrapper script
sed -i "s|___LIB_PATH___|$LIB_PATH|g" "$FLATPAK_HOME/navigraph_wrapper.sh"

# Make it executable
chmod +x "$FLATPAK_HOME/navigraph_wrapper.sh"

echo ""
echo "====================================================="
echo "                 SETUP COMPLETE!                     "
echo "====================================================="
echo "To finish up, follow these steps:"
echo "1. Open Steam -> MSFS 2020 Properties -> General"
echo "2. Set your Launch Options exactly to this:"
echo ""
echo "   \"/home/\$USER/navigraph_wrapper.sh\" %command%"
echo ""
echo "3. Launch MSFS. Once Simlink opens, click 'Sign In'."
echo "4. The browser will open. Click 'Allow' and the link"
echo "   should automatically pass into the sim."
echo "====================================================="
