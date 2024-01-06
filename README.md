# deploypop
This is a script designed to get Pop!_OS up and running with stuff I need.

## Installation
1. Install pop as normal with provided gui
2. Do `sudo apt update && sudo apt upgrade -y` and reboot
3. Clone this repo `git clone https://github.com/d4nse/deploypop`
4. Run the script `bash deploy.sh`

## TODO
- [x] Make basic deploy
- [x] Add gnome tokyo night theme and implement cosmic related fixes for it
- [ ] Implement mscorefonts installation
- [ ] Implement flatpak apps installation
- [ ] Add REAPER installation and configuration alog with jack, qjackctl and yabridge
- [ ] Add vscode installation and configuration
- [ ] Add an option to re-install (overwrite) something if needed

## Notes
Some packages to keep in mind:
#### APT
- ttf-mscorefonts-installer
#### FLATPAK
- com.obsproject.Studio
- md.obsidian.Obsidian
- org.kde.kdenlive
- org.telegram.desktop

### vscode
#### clangd
g++-12 package on ubuntu derivatives fixes the inability of clangd to find basic headers
#### latex
in addition to texlive install these for format to work:
libyaml-tiny-perl
libfile-homedir-perl
