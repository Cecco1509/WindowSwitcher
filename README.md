# WindowSwitcher

A lightweight macOS daemon that lets you navigate between tiled windows using the keyboard. Jumps focus in the direction you specify and moves the pointer to the center of the newly focused window.

https://github.com/user-attachments/assets/e5ea53eb-0a65-4b71-8e44-7fc52abd152f

## Keybindings

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
> System Settings → Privacy & Security → Accessibility → add `WindowSwitcher` and enable it

Then reload the daemon to pick up the permission:

```bash
./reload.sh
```

## Updating

1. Remove `WindowSwitcher` from System Settings → Privacy & Security → Accessibility
2. Follow the [Installation](#installation) steps again

## Roadmap

- [ ] Tests
- [ ] Menu bar icon with status indicator
- [ ] Wrap into a distributable macOS app
- [ ] Make the keybindings customizable

