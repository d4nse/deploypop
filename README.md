# Deploy POP!

## Notes
Some notes on how to do automation in Gnome

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
