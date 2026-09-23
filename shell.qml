//@ pragma UseQApplication

import Quickshell
import qs.DockApp

// Entry point of the ML4W Dock. Start it with:
//
//   qs -p ~/.local/share/ml4w-dock
//
// and control it over IPC (qs ipc show lists the functions):
//
//   qs -p ~/.local/share/ml4w-dock ipc call dock toggle
ShellRoot {
    // Creates the dock window only while the dock is enabled in its config.json.
    DockLoader {}
}
