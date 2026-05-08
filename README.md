# WindowSwitcher

A lightweight macOS daemon that lets you navigate between tiled windows using the keyboard. Jumps focus in the direction you specify and moves the pointer to the center of the newly focused window.

https://github.com/user-attachments/assets/e5ea53eb-0a65-4b71-8e44-7fc52abd152f

## Keybindings

The following options are the default ones but they are customizable under ~/.config/WindowSwitcher/config.toml

| Shortcut | Action |
|---|---|
| `Ctrl + Option + ←` | Focus window to the left |
| `Ctrl + Option + →` | Focus window to the right |
| `Ctrl + Option + ↑` | Focus window above |
| `Ctrl + Option + ↓` | Focus window below |


## Requirements

- macOS 13 (Ventura) or later
- Swift 6 or later

## Installation

Make the scripts executable:

```bash
chmod u+x *.sh
```

Run the install script:

```bash
./install.sh
```

Once installed, grant Accessibility permission to the binary:
> System Settings → Privacy & Security → Accessibility → `WindowSwitcher`

Also enable it as a background element in:
> System Settings → Login Items and Extensions → Background Elements → `WindowSwitcher`


Then reload the daemon to pick up the permission:

```bash
./reload.sh
```

## Updating

**!!! Follow the steps in order**

1. Disable `WindowSwitcher` from Login Items -> Background elements
2. Remove `WindowSwitcher` from System Settings → Privacy & Security → Accessibility
3. Follow the [Installation](#installation) steps again

If you didn't follow the order you have to do step one with only the mouse, since keyboard input is temporary blocked. Once step one is done you'll regain the keyboard.


## Uninstall

Run the uninstall script:

```bash
./uninstall.sh
```
Delete WindowSwitcher from the System Settings (the order isn't relevant):
- System Settings → Login Items and Extensions → Background elements
- System Settings → Privacy & Security → Accessibility 

## Roadmap

- [ ] Make the keybindings customizable
- [ ] Extend to multiple displays
- [ ] Wrap into a distributable macOS app
- [ ] Menu bar icon with status indicator

