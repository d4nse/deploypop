# Deploy POP!

## TODO
- [ ] Add an option to re-install (overwrite) something if needed
- [ ] Add REAPER installation and configuration alog with jack, qjackctl and yabridge
- [ ] Add vscode installation and configuration

## Notes
Some notes on how to do automation in Gnome
Some packages to keep in mind:
#### APT
- ttf-mscorefonts-installer
#### FLATPAK
- com.obsproject.Studio
- md.obsidian.Obsidian
- org.kde.kdenlive
- org.telegram.desktop

### gnome-terminal profiles
Dump (export) terminal profiles using dconf:
```bash
dconf dump /org/gnome/terminal/legacy/profiles:/ > gnome-terminal-profiles.dconf
```
Load (import) terminal profiles using dconf:
```bash
dconf load /org/gnome/terminal/legacy/profiles:/ < gnome-terminal-profiles.dconf
```
if you get `error: Key file does not start with a group` replace/add leading line of your dump with `[/]`

### vscode
#### clangd
g++-12 package on ubuntu derivatives fixes the inability of clangd to find basic headers
#### latex
in addition to texlive install these for format to work:
libyaml-tiny-perl
libfile-homedir-perl
