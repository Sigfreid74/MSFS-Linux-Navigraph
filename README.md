#Navigraph Simlink for MSFS 2020 on Linux (Steam Flatpak)
A seamless, automated solution to get Navigraph Simlink running and communicating with Microsoft Flight Simulator 2020 on Linux, specifically designed for the Steam Flatpak environment.

🛩️ The Problem
Running Navigraph Simlink alongside MSFS on a Linux system (especially via Flatpak) is notoriously difficult due to three main issues:

Oauth Login Failures: Simlink relies on your web browser to log in via a navigraph-traffic-desktop:// protocol link. By default, Linux browsers have no idea how to pass this token back into the isolated Proton container running the app.

The Flatpak Sandbox: Steam running as a Flatpak cannot execute scripts located in your host machine's home folder, leading to "File Not Found" or permission errors.

Window Focus Fights: Launching Simlink at the exact same time as MSFS often causes the sim to hang or crash while Proton tries to establish the initial window.

🛠️ The Solution
This repository provides a single setup.sh script that fixes all of these issues at once.

It automatically generates a .desktop protocol handler so your Linux browser can securely log into Simlink.

It places a wrapper script inside the Flatpak sandbox where Steam can actually see it.

It introduces a smart 30-second delay so MSFS can fully initialize before Simlink launches in the background.

🚀 Installation Guide
Prerequisites
You must have Microsoft Flight Simulator 2020 installed via the Steam Flatpak.

You must have run the Navigraph Simlink Windows installer at least once inside your MSFS Proton prefix.

Step 1: Run the Setup Script
Download the setup.sh script from this repository, make it executable, and run it in your terminal.

Bash
# Download the script
wget https://raw.githubusercontent.com/Sigfreid74/MSFS-Linux-Navigraph/main/setup.sh

# Make it executable
chmod +x setup.sh

# Run the setup
./setup.sh
The script will attempt to auto-detect your Steam Library. If you use a custom library location (like /var/steam-library), it will find it or ask you to input the path.

Step 2: Set Steam Launch Options
Once the script finishes, you need to tell Steam to use the new wrapper.

Open Steam.

Right-click Microsoft Flight Simulator in your library and select Properties.

On the General tab, scroll down to Launch Options.

Copy and paste the exact string below:

Bash
"/home/$USER/navigraph_wrapper.sh" %command%
(Note: Even though the script is physically saved in ~/.var/app/com.valvesoftware.Steam/, the Flatpak sandbox sees that folder as your home directory. Using /home/$USER/ is the correct, internal path.)

Step 3: Log In (First Time Only)
Launch MSFS from Steam.

Wait about 30 seconds for the game to start and for the Simlink window to appear.

Click Sign In on the Simlink window.

Your Linux default web browser will open to the Navigraph login page. Log in to your account.

Your browser will ask if you want to open the link using the handler. Click Allow/Yes.

Simlink will authenticate and minimize to your system tray.

You're done! Moving forward, Simlink will automatically boot up in the background every time you launch MSFS.

⚙️ How It Works (Under the Hood)
If you are curious about what the setup.sh script actually does:

Creates a .desktop file in ~/.local/share/applications/ that maps the navigraph-traffic-desktop:// protocol directly into your specific Proton prefix.

Registers the MIME type using gio and xdg-mime so Fedora, Ubuntu, Arch, and other distros know how to route the login request.

Generates a wrapper script at ~/.var/app/com.valvesoftware.Steam/navigraph_wrapper.sh that launches Simlink with a sleep 30 delay, then executes the game.

📝 Troubleshooting
Simlink isn't connecting to the Sim: Ensure that the Navigraph SimConnect module was successfully installed into your MSFS Community folder.

Changing Proton Versions: The script defaults to Proton - Experimental. If you change MSFS to use a different Proton version (like GE-Proton), you will need to manually edit the wrapper script inside ~/.var/app/com.valvesoftware.Steam/navigraph_wrapper.sh to point to the correct Proton executable.

Check out SimConnectBridge!
If you use Logitech Flight Panels (Multi, Radio, Switch) and want them working seamlessly in MSFS on Linux, check out my other project: SimConnectBridge.
