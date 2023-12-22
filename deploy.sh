#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
RICE_DIR="$SCRIPT_DIR/rice"

print_help() {
    echo "Script for automatic system deployment POP!_OS edition."
    echo
    echo "Usage: $0 [a|m|h]"
    echo
    echo "  -a, --automatic     install everything without prompting"
    echo "  -m, --manual        enter manual mode and choose what to install"
    echo "  -h, --help          print this page"
}

install_gogh_theme() {
    # requirements: dconf-cli uuid-runtime
    GOGH_THEME_NAME="synthwave"
    GOGH_INSTALL_PATH="$HOME/opt/gogh-themes"
    GOGH_THEME_PATH="$GOGH_INSTALL_PATH/installs/$GOGH_THEME_NAME.sh"

    # Install Gogh
    if [[ -d "$GOGH_INSTALL_PATH" ]]; then
        echo "Gogh is already installed to $GOGH_INSTALL_PATH"
    else
        echo "Downloading latest Gogh..."
        git clone --quiet https://github.com/Gogh-Co/Gogh.git "$GOGH_INSTALL_PATH"
        echo "Successfully installed Gogh to '$GOGH_INSTALL_PATH'"
    fi

    # Install theme
    if [[ -f "$GOGH_THEME_PATH" ]]; then
        if [[ -f "$GOGH_THEME_PATH.installed" ]]; then
            echo "Terminal theme '$GOGH_THEME_NAME' is already installed"
        else
            export TERMINAL=gnome-terminal
            bash "$GOGH_THEME_PATH"
            touch "$GOGH_THEME_PATH.installed"
            echo "Terminal theme '$GOGH_THEME_NAME' successfully installed"
        fi
    else
        echo "Terminal theme '$GOGH_THEME_NAME' was not found in '$GOGH_INSTALL_PATH/installs/'"
    fi
}

install_neovim() {
    NVIM_EXTRACT_PATH="/tmp/nvim-linux64"
    NVIM_INSTALL_PATH="$HOME/opt/nvim"
    NVIM_DOT_PATH="$HOME/.config/nvim"

    # Check path exists
    if [[ ! -d "$NVIM_DOT_PATH" ]]; then
        mkdir -p "$NVIM_DOT_PATH"
    fi

    # Install neovim
    if [[ -d "$NVIM_INSTALL_PATH" ]]; then
        echo "Neovim is already installed to $NVIM_INSTALL_PATH"
    else
        echo "Downloading latest Neovim..."
        curl --silent --location https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz --output "$NVIM_EXTRACT_PATH.tar.gz" &&
            tar --extract --file="$NVIM_EXTRACT_PATH.tar.gz" --directory="/tmp/" &&
            mv "$NVIM_EXTRACT_PATH" "$NVIM_INSTALL_PATH"
        echo "Successfully installed Neovim to '$NVIM_INSTALL_PATH'"
    fi

    echo "Dropping dots to $NVIM_DOT_PATH..."
    cp "$RICE_DIR/dots/init.vim" "$NVIM_DOT_PATH"
}

install_fonts() {
    FONT_PATH="$HOME/.fonts"
    MESLO_REGULAR="$FONT_PATH/MesloLGS_NF_Regular.ttf"
    MESLO_BOLD="$FONT_PATH/MesloLGS_NF_Bold.ttf"
    MESLO_ITALIC="$FONT_PATH/MesloLGS_NF_Italic.ttf"
    MESLO_BOLD_ITALIC="$FONT_PATH/MesloLGS_NF_Bold_Italic.ttf"

    # Check path exists
    if [[ ! -d "$FONT_PATH" ]]; then
        mkdir "$FONT_PATH"
    fi

    # Check if font is installed, download if not
    if [[ ! -f "$MESLO_REGULAR" ]]; then
        echo "Downloading Meslo Regular..."
        curl --silent --location https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf --output "$MESLO_REGULAR"
    fi
    if [[ ! -f "$MESLO_BOLD" ]]; then
        echo "Downloading Meslo Bold..."
        curl --silent --location https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf --output "$MESLO_BOLD"
    fi
    if [[ ! -f "$MESLO_ITALIC" ]]; then
        echo "Downloading Meslo Italic..."
        curl --silent --location https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf --output "$MESLO_ITALIC"
    fi
    if [[ ! -f "$MESLO_BOLD_ITALIC" ]]; then
        echo "Downloading Meslo Bold Italic..."
        curl --silent --location https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf --output "$MESLO_BOLD_ITALIC"
    fi
    echo "Rebuilding font cache..."
    fc-cache -f
}

install_zsh_config() {
    # requirements: zsh zsh-syntax-highlighting
    POWER_INSTALL_PATH="$HOME/opt/powerlevel10k"

    # Install powerlevel10k theme
    if [[ -d "$POWER_INSTALL_PATH" ]]; then
        echo "Powerlevel10k is already installed to $POWER_INSTALL_PATH"
    else
        echo "Downloading powerlevel10k..."
        git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git "$POWER_INSTALL_PATH"
    fi

    # Copy dotfiles
    echo "Dropping dots to home..."
    cp {"$RICE_DIR/dots/.zshrc","$RICE_DIR/dots/.p10k"} "$HOME/"

    # Change shell to zsh
    if [ "$SHELL" != "/usr/bin/zsh" ]; then
        echo "Changing shell to ZSH..."
        chsh -s "$(which zsh)" "$(whoami)"
    else
        echo "Shell is already set to ZSH"
    fi

    echo "Successfully installed ZSH configuration"
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

    # For all:
    #   get latest neovim from github, not apt. Put it in $HOME/opt

    # For C++ profile:
    #   clangd cmake
    #   also g++-12 on ubuntu derivatives fixes the inability of clangd to find basic headers

    # For BASH:
    #   shfmt shellcheck

    # For python:
    #   python3-pip
    #   ALWAYS MAKE A VENV

    # For Latex:
    #   in addition to texlive install these for format to work:
    #       libyaml-tiny-perl
    #       libfile-homedir-perl

    # Run this to fix indentation:
    # echo "IndentWidth: 4" >> "$HOME/.clang-format"
    return 0
}

install_reaper() {
    # ADD REAPER CONFIGURATION ALONG WITH YABRIDGE N SHIT
    # qjackctl will usually pull jackd and all the dependencies they need together
    # list of libs: libgdk3.0-cil libgdk3.0-cil-dev qjackctl
    return 0
}

automatic_wizard() {
    # Get requirements
    sudo apt-get update 1>/dev/null &&
        xargs sudo apt-get install -y <"$SCRIPT_DIR/requirements.txt" 1>/dev/null

    # Setup directories
    if [[ ! -d "$HOME/opt" ]]; then
        mkdir "$HOME/opt"
    fi

    # Run installs
    install_fonts
    install_gogh_theme
    install_neovim
    install_zsh_config

    # Get the rest of the apps
    sudo apt-get update 1>/dev/null &&
        xargs sudo apt-get install -y <"$SCRIPT_DIR/apps.txt" 1>/dev/null

    echo "Done. Log out for changes to take effect."
}

getopts amh opt
case $opt in
a)
    echo "Automatic installation is chosen"
    ;;
m)
    echo "Manual installation is chosen"
    ;;
h)
    print_help
    ;;
*)
    print_help
    ;;
esac
