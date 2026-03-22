// Bar.qml — one panel window per monitor
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    // Filled by Variants delegate in shell.qml
    required property var screen

    anchors {
        top: true
        left: true
        right: true
    }

    height: 46
    color: "transparent"

    // Reserve bar height so windows don't overlap it
    WlrLayershell.exclusiveZone: height
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-bar"

    // ── Root background pill ──────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        color: "#111827"
        radius: 10

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 0

            // ── LEFT: workspaces + media ──────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                WorkspacePills {
                    barScreen: root.screen
                }

                MediaWidget { }
            }

            // ── CENTER: clock ─────────────────────────────────────────────
            ClockWidget {
                Layout.alignment: Qt.AlignHCenter
            }

            // ── RIGHT: system stats + tray + power ───────────────────────
            RowLayout {
                Layout.fillWidth: true
                layoutDirection: Qt.RightToLeft
                spacing: 6

                PowerButton { }
                TrayWidget { }
                VolumeWidget { }
                StorageWidget { }
                RamWidget { }
                CpuWidget { }
            }
        }
    }
}
