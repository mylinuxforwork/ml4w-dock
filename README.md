# ML4W Dock

A dock for Hyprland built with [Quickshell](https://quickshell.org). Part of 
[ML4W OS](https://github.com/mylinuxforwork/dotfiles), but it also runs on its own.

![ML4W Dock](screenshots/dock.png)

## Installation

```bash
curl -sSL https://raw.githubusercontent.com/mylinuxforwork/ml4w-dock/main/install.sh | bash
```

The script clones ml4w-dock into `$HOME/.local/share/ml4w-dock`, or pulls the
latest version if the folder already exists, and links the `ml4w-dock` command
into `$HOME/.local/bin`. Run it again to update.

Requires `git` and `quickshell`.

`$HOME/.local/bin` must be in your `$PATH` to run `ml4w-dock`. Most
distributions add it by default. If yours does not, add this line to your shell
configuration (e.g. `~/.bashrc` or `~/.zshrc`):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Start

```bash
ml4w-dock
```

This runs `qs -p ~/.local/share/ml4w-dock`. If the dock is already running,
nothing happens. `ml4w-dock stop` stops it and `ml4w-dock restart` restarts it.

To start the dock with Hyprland, add this line to your Hyprland config (the ML4W
Dotfiles start it from `ml4w-autostart`):

```
hl.on("hyprland.start", function ()
  hl.exec_cmd("~/.local/bin/ml4w-dock")
end)
```

## IPC

```bash
ml4w-dock <function>
```

This is a shortcut for `qs -p ~/.local/share/ml4w-dock ipc call dock <function>`.

| Function | Description |
|---|---|
| `toggle` / `enable` / `disable` | Show or hide the dock |
| `autohideToggle` / `autohideOn` / `autohideOff` | Toggle autohide |
| `reload` | Re-read `config.json` and apply it |
| `settings` | Open the settings dialog |
| `edit` | Open `config.json` in the configured editor |

Run `ml4w-dock help` to list all commands.

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

## Wallpaper colors with matugen

To make the dock follow your wallpaper, have [matugen](https://github.com/InioX/matugen)
write its colors to `theme.colorsFile`. Add a template to
`~/.config/matugen/config.toml`:

```toml
[templates.ml4w_dock]
input_path  = "./templates/colors.json"
output_path = "~/.config/ml4w-dock/colors.json"
```

`templates/colors.json` maps each Material color role to its matugen value, e.g.
`"primary": "{{colors.primary.default.hex}}"`. The dock watches the file, so no
`post_hook` is needed. ML4W OS ships a complete
[config and template](https://github.com/mylinuxforwork/dotfiles/tree/main/dotfiles/.config/matugen).

## Uninstall

```bash
curl -sSL https://raw.githubusercontent.com/mylinuxforwork/ml4w-dock/main/uninstall.sh | bash
```

Stops the dock and removes `$HOME/.local/share/ml4w-dock` and the
`ml4w-dock` command in `$HOME/.local/bin`. Your configuration in
`~/.config/ml4w-dock` is kept.
