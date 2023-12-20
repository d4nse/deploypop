#!/usr/bin/env bash

# Some packages to keep in mind:
# ttf-mscorefonts-installer
# ffmpeg vlc mpv feh
# lm-sensors tree neofetch
# keepassxc

SCRIPT_NAME="rice"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
RICE="$SCRIPT_DIR/rice"

echo() {
    command echo "$SCRIPT_NAME: $1"
}

make_dirs() {
    if [[ ! -d "$HOME/.fonts" ]]; then
        mkdir "$HOME/.fonts"
    fi
    if [[ ! -d "$HOME/opt" ]]; then
        mkdir "$HOME/opt"
    fi
}

install_meslo_fonts() {
    # requirements: curl
    echo "Downloading Meslo fonts..."
    curl --silent --location https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf --output "$HOME/.fonts/MesloLGS NF Regular.ttf"
    curl --silent --location https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf --output "$HOME/.fonts/MesloLGS NF Bold.ttf"
    curl --silent --location https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf --output "$HOME/.fonts/MesloLGS NF Italic.ttf"
    curl --silent --location https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf --output "$HOME/.fonts/MesloLGS Bold Italic.ttf"
    fc-cache -f
    echo "Meslo fonts successfully installed to ~/.fonts"
}

install_zsh() {
    # requirements: zsh zsh-syntax-highlighting git
    echo "Downloading powerlevel10k..."
    git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/opt/powerlevel10k"
    echo "Dropping dots to home..."
    cp {"$RICE/dots/.zshrc","$RICE/dots/.p10k"} "$HOME/"
    echo "CHSHing zsh..."
    chsh -s "$(which zsh)" "$(whoami)"
    echo "Successfully installed ZSH and rice, log in and out for changes to take effect"
}

install_gogh_theme() {
    # requirements: dconf-cli uuid-runtime
    theme_name="synthwave"
    gogh_root="$HOME/opt/gogh-themes"
    theme_root="$gogh_root/installs"

    if [[ ! -d "$gogh_root" ]]; then
        echo "Downloading Gogh themes into ~/opt/gogh-themes..."
        git clone --quiet https://github.com/Gogh-Co/Gogh.git "$gogh_root"
    else
        echo "Gogh themes are already installed in ~/opt/gogh-themes"
    fi

    if [[ -f "$theme_root/$theme_name.sh" ]]; then
        export TERMINAL=gnome-terminal
        bash "$theme_root/$theme_name.sh"
        echo "Gogh theme \"$theme_name\" successfully installed"
        echo "Change terminal profile to apply theme"
        #last_installed_theme_id=$(gsettings get org.gnome.Terminal.ProfilesList list | sed "s/'/\"/g" | jq '.[-1]')
    else
        echo "Gogh theme \"$theme_name\" was not found in ~/opt/gogh-themes"
    fi
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

install_neovim() {
    nvim_path="$HOME/opt/nvim-linux64"
    echo "Downloading latest Neovim..."
    curl --silent --location https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz --output "$nvim_path.tar.gz" &&
        tar --extract --file="$nvim_path.tar.gz" --directory="$HOME/opt/" &&
        rm "$nvim_path.tar.gz" &&
        mv "$nvim_path" "$HOME/opt/nvim/"
    echo "Successfully installed Neovim to: '~/opt/nvim/'"
}

install_librewolf() {
    # Installation script is taken from https://librewolf.net/installation/debian
    sudo apt update && sudo apt install -y wget gnupg lsb-release apt-transport-https ca-certificates
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
    sudo apt update
    sudo apt install librewolf -y
}

update_neovim() {
    nvim_path="$HOME/opt/nvim"
    echo "Updating Neovim..."
    rm -rf "$nvim_path"
    install_neovim
}
