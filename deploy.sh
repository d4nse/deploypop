#!/usr/bin/env bash

# Store source dirs
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
DOTS_DIR="$SCRIPT_DIR/rice/dots"
DCONF_DIR="$SCRIPT_DIR/rice/dconf"
CSS_DIR="$SCRIPT_DIR/rice/css"

install_neovim() {
    NVIM_EXTRACT_PATH="/tmp/nvim-linux64"
    NVIM_INSTALL_PATH="$HOME/opt/nvim"

    # Install neovim
    if [[ ! -d "$NVIM_INSTALL_PATH" ]]; then
        echo "Downloading latest Neovim..."
        curl --silent --location https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz --output "$NVIM_EXTRACT_PATH.tar.gz" &&
            tar --extract --file="$NVIM_EXTRACT_PATH.tar.gz" --directory="/tmp/" &&
            mv "$NVIM_EXTRACT_PATH" "$NVIM_INSTALL_PATH"
    else
        echo "Neovim is already installed to $NVIM_INSTALL_PATH"
    fi
}

install_fonts() {
    FONT_PATH="$HOME/.fonts"
    MESLO_REGULAR="$FONT_PATH/MesloLGS_NF_Regular.ttf"
    MESLO_BOLD="$FONT_PATH/MesloLGS_NF_Bold.ttf"
    MESLO_ITALIC="$FONT_PATH/MesloLGS_NF_Italic.ttf"
    MESLO_BOLD_ITALIC="$FONT_PATH/MesloLGS_NF_Bold_Italic.ttf"

    # Check path exists
    if [[ ! -d "$FONT_PATH" ]]; then mkdir "$FONT_PATH"; fi

    # Download fonts
    if [[ ! -f "$MESLO_REGULAR" ]]; then
        echo "Installing fonts..."
        curl --silent --location https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf --output "$MESLO_REGULAR"
        curl --silent --location https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf --output "$MESLO_BOLD"
        curl --silent --location https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf --output "$MESLO_ITALIC"
        curl --silent --location https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf --output "$MESLO_BOLD_ITALIC"
        echo "Rebuilding font cache..."
        fc-cache -f
    else
        echo "MesloLGS fonts are already installed in $FONT_PATH"
    fi
}

install_powerlevel() {
    # requirements: zsh zsh-syntax-highlighting
    POWER_INSTALL_PATH="$HOME/opt/powerlevel10k"

    if [[ ! -d "$POWER_INSTALL_PATH" ]]; then
        echo "Downloading powerlevel10k..."
        git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git "$POWER_INSTALL_PATH"
    else
        echo "Powerlevel10k is already installed to $POWER_INSTALL_PATH"
    fi
}

install_gnome_theme() {
    THEME_DOWNLOAD_PATH="/tmp/tokyonight-gtk"
    ICONS_DOWNLOAD_PATH="/tmp/candy-icons.zip"
    THEME_INSTALL_PATH="$HOME/.themes"
    ICONS_INSTALL_PATH="$HOME/.icons"
    THEME_NAME="Tokyonight-Dark-BL"

    # Create installation dirs
    if [[ ! -d "$THEME_INSTALL_PATH" ]]; then mkdir -p "$THEME_INSTALL_PATH"; fi
    if [[ ! -d "$ICONS_INSTALL_PATH" ]]; then mkdir -p "$ICONS_INSTALL_PATH"; fi

    # Install user-theme extension
    if [[ ! -d "$HOME/.local/share/gnome-shell/extensions/user-theme@gnome-shell-extensions.gcampax.github.com" ]]; then
        echo "Installing user-theme extension"
        # Im using gdbus call here to install this extension and enable it without the need to reboot or restart gnome shell
        gdbus call --session \
            --dest org.gnome.Shell.Extensions \
            --object-path /org/gnome/Shell/Extensions \
            --method org.gnome.Shell.Extensions.InstallRemoteExtension \
            "user-theme@gnome-shell-extensions.gcampax.github.com"
        sleep 10
    fi

    # Download and install gtk theme
    if [[ ! -d "$THEME_INSTALL_PATH/$THEME_NAME" ]]; then
        echo "Downloading Tokyo Night GTK theme..."
        git clone --quiet --depth=1 https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme "$THEME_DOWNLOAD_PATH" &&
            mv "$THEME_DOWNLOAD_PATH/themes/$THEME_NAME" "$THEME_INSTALL_PATH/"
    else
        echo "Tokyo Night GTK theme is already installed in $THEME_INSTALL_PATH"
    fi

    # Download and install icons
    if [[ ! -d "$ICONS_INSTALL_PATH/candy-icons-master" ]]; then
        echo "Downloading Candy Icons..."
        curl --silent --location https://github.com/EliverLara/candy-icons/archive/refs/heads/master.zip --output "$ICONS_DOWNLOAD_PATH" &&
            unzip -qq "$ICONS_DOWNLOAD_PATH" -d "$ICONS_INSTALL_PATH/"
    else
        echo "Candy icons are already installed in $ICONS_INSTALL_PATH"
    fi

}

tweak_gnome_settings() {
    # Fix missing gsettings schema for shell themes
    echo "About to fix gsettings missing schema, requires sudo"
    sudo cp "$HOME/.local/share/gnome-shell/extensions/user-theme@gnome-shell-extensions.gcampax.github.com/schemas/org.gnome.shell.extensions.user-theme.gschema.xml" "/usr/share/glib-2.0/schemas" &&
        sudo glib-compile-schemas /usr/share/glib-2.0/schemas

    # Apply themes
    THEME_NAME="Tokyonight-Dark-BL"
    gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
    gsettigns set org.gnome.shell.extensions.user-theme name "$THEME_NAME"

    # Apply icons
    gsettings set org.gnome.desktop.interface icon-theme "candy-icons-master"

    # Adjust cosmic settings
    COSMIC_PATH="/usr/share/gnome-shell/extensions/pop-cosmic@system76.com"
    if [[ -d "$COSMIC_PATH" ]]; then
        # This fixes off-color application menu
        echo "About to change system-wide COSMIC file dark.css, requires sudo"
        sudo mv "$COSMIC_PATH/dark.css" "$COSMIC_PATH/dark.css.old"
        sudo cp "$CSS_DIR/dark.css" "$COSMIC_PATH/dark.css"
        echo "Saved old dark.css to dark.css.old"

        # This fixes off-color dash-to-dock
        gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
        gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.9
        gsettings set org.gnome.shell.extensions.dash-to-dock background-color '#1a1b26'

        # Other
        gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false                      # Shorter dash-to-dock
        gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true                         # Hide dock when an app overlays it
        gsettings set org.gnome.shell.extensions.pop-cosmic show-workspaces-button false               # Disable workspaces button upper left corner
        gsettings set org.gnome.shell.extensions.pop-cosmic show-applications-button false             # Disable applications button upper left corner
        gsettings set org.gnome.shell.extensions.pop-cosmic clock-alignment 'CENTER'                   # Clock in the middle
        gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'                         # Disable mouse acceleration
        gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true                          # Reverse scroll direction
        gsettings set org.gnome.desktop.peripherals.mouse speed -0.40                                  # Change mouse speed (red mouse profile)
        gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:appmenu' # Title bar buttons placement on left
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'         # Disable automatic suspend
    fi
}

add_repo_librewolf() {
    # Installation script is taken from https://librewolf.net/installation/debian
    # requirements: wget gnupg lsb-release apt-transport-https ca-certificates
    distro=$(if echo " una bookworm vanessa focal jammy bullseye vera uma " | grep -q " $(lsb_release -sc) "; then lsb_release -sc; else echo focal; fi)
    wget -O- https://deb.librewolf.net/keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/librewolf.gpg
    sudo tee /etc/apt/sources.list.d/librewolf.sources <<EOF >/dev/null
Types: deb
URIs: https://deb.librewolf.net
Suites: $distro
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/librewolf.gpg
EOF
}

install_vscode() {
    # When doing vscode installation like this:
    #   sudo apt install code
    # Make sure to specify the latest version at the time:
    #   sudo apt install code=1.84.2-1699528352
    return 0
}

install_reaper() {
    # ADD REAPER CONFIGURATION ALONG WITH YABRIDGE N SHIT
    # qjackctl will usually pull jackd and all the dependencies they need together
    # list of libs: libgdk3.0-cil libgdk3.0-cil-dev qjackctl
    return 0
}

# welcome
echo "Deploying POP_OS!"

# Get requirements
echo "Installing dependencies.txt..."
xargs sudo apt-get install -y <"$SCRIPT_DIR/requirements.txt" 1>/dev/null

# Setup directories
if [[ ! -d "$HOME/opt" ]]; then
    mkdir "$HOME/opt"
fi

# Run installs
install_fonts
install_gnome_theme
install_neovim
install_powerlevel

# Add additional repos
add_repo_librewolf

# Load gnome settings
echo "Loading gnome-terminal-profiles.dconf..."
dconf load /org/gnome/terminal/legacy/profiles:/ <"$DCONF_DIR/gnome-terminal-profiles.dconf"
tweak_gnome_settings

# Copy dots
echo "Copying dots..."
cp "$DOTS_DIR/.zshrc" "$HOME/"
cp "$DOTS_DIR/.p10k.zsh" "$HOME/"
cp "$DOTS_DIR/.clang-format" "$HOME/"
cp --recursive "$DOTS_DIR/nvim" "$HOME/.config/"
cp --recursive "$DOTS_DIR/feh" "$HOME/.config/"

# Get the rest of the apps
#echo "Installing the rest of the apps through aptitude..."
#sudo apt-get update 1>/dev/null &&
#    xargs sudo apt-get install -y <"$SCRIPT_DIR/apps.txt" 1>/dev/null

# Change shell to zsh
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "Changing shell to ZSH..."
    chsh -s "$(which zsh)" "$(whoami)"
else
    echo "Shell is already set to ZSH"
fi

echo "Done. Reboot for changes to take effect."
