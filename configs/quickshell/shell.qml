import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            height: 46
            color: "#111827"

            WlrLayershell.exclusiveZone: 46
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: "quickshell-bar"

            // Three-column layout: left | center | right
            // Left and right each fill half the remaining space
            // Center is fixed-width and truly centered
            Item {
                x: 0; y: 0
                width: parent.width
                height: parent.height

                // LEFT group — anchored left
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    WorkspacePills { barScreen: modelData }
                    MediaWidget { }
                }

                // CENTER group — truly centered
                ClockWidget {
                    anchors.centerIn: parent
                }

                // RIGHT group — anchored right
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    CpuWidget { }
                    RamWidget { }
                    StorageWidget { }
                    VolumeWidget { }
                    TrayWidget { }
                    PowerButton { }
                }
            }
        }
    }
}
