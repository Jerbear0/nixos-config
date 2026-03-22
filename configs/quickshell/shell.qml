// shell.qml — entry point
// Place at: ~/.config/quickshell/shell.qml
// (symlinked via: xdg.configFile."quickshell".source = ./configs/quickshell)

import Quickshell
import Quickshell.Hyprland
import QtQuick

ShellRoot {
    // Spawn one bar per monitor, each scoped to its screen
    Variants {
        model: Quickshell.screens

        delegate: Bar {
            required property var modelData
            screen: modelData
        }
    }
}
