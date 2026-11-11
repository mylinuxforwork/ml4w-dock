pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.DockApp

// The dock's colors, read from a JSON file of Material color roles — the format
// matugen writes with templates/colors.json:
//
//   { "background": "#1a1110", "primary": "#ffb4a5", ... }
//
// The file is theme.colorsFile in the dock's config.json, by default
//
//   ~/.config/ml4w-dock/colors.json
//
// which ML4W's matugen config generates (see the ml4w_dock rule in
// matugen/config.toml). Pointing it elsewhere lets any other generator (pywal,
// wallust, a hand-written file) theme the dock, as long as it uses the same
// key names.
//
// This is the dock's own copy of the shared CustomTheme, so the dock does not
// depend on the rest of the shell. The file is watched: the dock recolors as
// soon as matugen rewrites it, without a reload call. Keys missing from the
// file, or a missing file, keep the built-in colors below.
Singleton {
    id: root

    readonly property string fontFamily: "Fira Sans Semibold"

    // Built-in colors, used until (and unless) the colors file provides them.
    // Only the roles the dock draws with are listed; other keys in the file are
    // ignored.
    readonly property var defaultColors: ({
        "background": "#0e1514",
        "on_primary": "#003734",
        "on_surface": "#dde4e2",
        "on_surface_variant": "#bec9c6",
        "outline_variant": "#3f4947",
        "primary": "#81d5cd",
        "shadow": "#000000",
        "surface_container_high": "#252b2a"
    })

    property color background: defaultColors.background
    property color on_primary: defaultColors.on_primary
    property color on_surface: defaultColors.on_surface
    property color on_surface_variant: defaultColors.on_surface_variant
    property color outline_variant: defaultColors.outline_variant
    property color primary: defaultColors.primary
    property color shadow: defaultColors.shadow
    property color surface_container_high: defaultColors.surface_container_high

    // theme.colorsFile with a leading "~" or "$HOME" expanded — FileView takes
    // a plain path. Empty (nothing loaded) until the dock's config.json has
    // been read, so a custom path is never preceded by a load of the default.
    readonly property string defaultColorsFile: Quickshell.env("HOME")
        + "/.config/ml4w-dock/colors.json"
    readonly property string colorsFile: {
        if (!DockSettings.ready)
            return ""
        const raw = `${DockSettings.settings.theme.colorsFile ?? ""}`.trim()
        if (raw === "")
            return root.defaultColorsFile
        return raw.replace(/^(~|\$HOME)(?=\/|$)/, Quickshell.env("HOME"))
    }

    // Apply the file's colors over the built-in ones. Every role is reset
    // first, so a key removed from the file falls back instead of keeping the
    // previous theme's value.
    function applyColors(text): void {
        let parsed = ({})
        if (text && text.trim() !== "") {
            try {
                parsed = JSON.parse(text)
            } catch (e) {
                console.warn("dock theme: could not parse " + root.colorsFile
                    + ", using the built-in colors:", e)
            }
        }
        for (let key in root.defaultColors)
            root[key] = (typeof parsed[key] === "string" && parsed[key] !== "")
                ? parsed[key] : root.defaultColors[key]
    }

    // Re-read the colors file. It is watched, so this is only needed when the
    // file did not exist yet when the dock started (a watch cannot follow a
    // file that is created later). Part of "Reload Dock" / the reload IPC.
    function reload(): void {
        colorsView.reload()
        if (root.opacityFile !== "")
            opacityView.reload()
        if (root.transparentBorderFile !== "")
            transparentBorderView.reload()
        if (root.blurFile !== "")
            blurView.reload()
    }

    // --- SHARED BACKGROUND OPACITY ---
    // theme.opacityFile holds a background opacity in percent (0-100), shared
    // with the rest of the shell — on ML4W the sidebar's Opacity slider writes
    // ~/.config/ml4w/settings/quickshell-opacity. -1 while the file is not set,
    // missing or invalid: the dock then uses opacity.normal. The file is
    // watched; one created after the dock started is picked up by reload().
    property int globalOpacity: -1

    readonly property string opacityFile: {
        if (!DockSettings.ready)
            return ""
        const raw = `${DockSettings.settings.theme.opacityFile ?? ""}`.trim()
        return raw.replace(/^(~|\$HOME)(?=\/|$)/, Quickshell.env("HOME"))
    }

    onOpacityFileChanged: if (root.opacityFile === "") root.globalOpacity = -1

    FileView {
        id: opacityView
        path: root.opacityFile
        watchChanges: true
        printErrors: false
        onFileChanged: opacityView.reload()
        onLoaded: {
            const v = parseInt(opacityView.text().trim())
            root.globalOpacity = isNaN(v) ? -1 : Math.max(0, Math.min(100, v))
        }
        onLoadFailed: root.globalOpacity = -1
    }

    // --- TRANSPARENT BORDER ---
    // theme.transparentBorderFile holds "on" or "off", shared with the rest of
    // the shell — on ML4W the sidebar's Transparent Border switch writes
    // ~/.config/ml4w/settings/quickshell-transparent-border. On (also when the
    // setting is empty or the file is missing): the border follows the
    // background opacity. Off: it stays at fixedBorderOpacity.
    property bool transparentBorder: true
    readonly property real fixedBorderOpacity: 0.8

    // Opacity (0-1) for the border, given the background opacity.
    function borderOpacity(fillOpacity) {
        return root.transparentBorder ? fillOpacity : root.fixedBorderOpacity
    }

    readonly property string transparentBorderFile: {
        if (!DockSettings.ready)
            return ""
        const raw = `${DockSettings.settings.theme.transparentBorderFile ?? ""}`.trim()
        return raw.replace(/^(~|\$HOME)(?=\/|$)/, Quickshell.env("HOME"))
    }

    onTransparentBorderFileChanged: if (root.transparentBorderFile === "") root.transparentBorder = true

    FileView {
        id: transparentBorderView
        path: root.transparentBorderFile
        watchChanges: true
        printErrors: false
        onFileChanged: transparentBorderView.reload()
        onLoaded: root.transparentBorder = transparentBorderView.text().trim() !== "off"
        onLoadFailed: root.transparentBorder = true
    }

    // --- BLUR ---
    // theme.blurFile holds "on" or "off" — on ML4W the sidebar's Blur switch
    // writes ~/.config/ml4w/settings/quickshell-blur, and a Hyprland layer
    // rule blurs behind the surface while it is on. That rule uses
    // ignore_alpha, so it also blurs the denser part of the drop shadow and
    // ends in a hard edge around the background; the shadow is hidden while
    // blurEnabled is set. Missing file or "" = off.
    property bool blurEnabled: false

    readonly property string blurFile: {
        if (!DockSettings.ready)
            return ""
        const raw = `${DockSettings.settings.theme.blurFile ?? ""}`.trim()
        return raw.replace(/^(~|\$HOME)(?=\/|$)/, Quickshell.env("HOME"))
    }

    onBlurFileChanged: if (root.blurFile === "") root.blurEnabled = false

    FileView {
        id: blurView
        path: root.blurFile
        watchChanges: true
        printErrors: false
        onFileChanged: blurView.reload()
        onLoaded: root.blurEnabled = blurView.text().trim() === "on"
        onLoadFailed: root.blurEnabled = false
    }

    // Guards the one-time seeding below.
    property bool seeded: false

    FileView {
        id: colorsView
        path: root.colorsFile
        watchChanges: true
        printErrors: false
        onFileChanged: colorsView.reload()
        onLoaded: root.applyColors(colorsView.text())
        onLoadFailed: {
            root.applyColors("")
            // The default file does not exist before the next matugen run. On
            // ML4W, start from the shell's current colors instead of the
            // built-in ones, so the dock matches the theme right away.
            if (!root.seeded && root.colorsFile === root.defaultColorsFile) {
                root.seeded = true
                Qt.callLater(function() { seedProc.running = true })
            }
        }
    }

    // Copies ML4W's generated colors into the dock's default colors file when
    // that is missing. Does nothing without ML4W; the built-in colors stay.
    Process {
        id: seedProc
        command: ["bash", "-c",
            'f="$HOME/.config/ml4w-dock/colors.json";'
            + ' o="$HOME/.config/ml4w/colors/colors.json";'
            + ' [ -f "$f" ] && exit 0;'
            + ' [ -f "$o" ] || exit 1;'
            + ' mkdir -p "$(dirname "$f")" && cp "$o" "$f"']
        onExited: (code) => { if (code === 0) colorsView.reload() }
    }
}
