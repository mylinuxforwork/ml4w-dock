# ML4W Dock

A dock for Hyprland built with [Quickshell](https://quickshell.org). Part of 
[ML4W OS](https://github.com/mylinuxforwork/dotfiles), but it also runs on its own.

## Installation

```bash
curl -sSL https://raw.githubusercontent.com/mylinuxforwork/ml4w-dock/main/install.sh | bash
```

The script clones ml4w-dock into `$HOME/.local/share/ml4w-dock`, or pulls the
latest version if the folder already exists. Run it again to update.

Requires `git` and `quickshell`.

## Start

```bash
qs -p ~/.local/share/ml4w-dock
```

To start the dock with Hyprland, add this line to your Hyprland config (the ML4W
Dotfiles start it from `ml4w-autostart`):

```
exec-once = qs -p ~/.local/share/ml4w-dock
```

## IPC

```bash
qs -p ~/.local/share/ml4w-dock ipc call dock <function>
```

| Function | Description |
|---|---|
| `toggle` / `enable` / `disable` | Show or hide the dock |
| `autohideToggle` / `autohideOn` / `autohideOff` | Toggle autohide |
| `reload` | Re-read `config.json` and apply it |
| `settings` | Open the settings dialog |
| `edit` | Open `config.json` in the configured editor |

## Configuration

The dock reads `~/.config/ml4w-dock/config.json`. It is created on first start
and merged over the built-in defaults, so it only needs the values you want to
change. [`DockApp/config.json`](DockApp/config.json) lists every setting with
its default value.

- `dock.launcherCommand` runs when you left-click the launcher button.
- `dock.editorCommand` opens `config.json` ("Edit configuration" in the dock
  menu). The file path is appended as the last argument. If the command is empty
  or its program is not found, `xdg-open` is used.
- `theme.colorsFile` is a JSON file of Material color roles (matugen's
  `colors.json` format). The dock watches it and recolors when it changes.

Both commands are run through bash, so `~`, arguments and pipes work.

## Uninstall

```bash
curl -sSL https://raw.githubusercontent.com/mylinuxforwork/ml4w-dock/main/uninstall.sh | bash
```

Stops the dock and removes `$HOME/.local/share/ml4w-dock`. Your configuration in
`~/.config/ml4w-dock` is kept.
