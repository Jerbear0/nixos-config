// WorkspacePills.qml — Hyprland workspace buttons
// Uses: Hyprland.workspaces (ObjectModel<HyprlandWorkspace>)
//       workspace.id, .name, .active, .focused, .urgent, .activate()
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    // The ShellScreen this bar lives on — used to filter workspaces per monitor
    required property var barScreen

    spacing: 4

    Repeater {
        // All workspaces sorted by id (Hyprland singleton)
        model: Hyprland.workspaces

        delegate: Rectangle {
            required property var modelData  // HyprlandWorkspace

            // Highlight: active on this monitor = green; urgent = red; else dim blue
            color: {
                if (modelData.urgent)  return "#ef4444"
                if (modelData.focused) return "#22c55e"
                if (modelData.active)  return "#3b82f6"
                return "#182545"
            }

            radius: 8
            width:  modelData.focused ? 28 : 22
            height: 26

            Behavior on width  { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Behavior on color  { ColorAnimation  { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: modelData.name
                color: modelData.active ? "#020617" : "#e5e7eb"
                font.pixelSize: 11
                font.bold: modelData.focused
            }

            MouseArea {
                anchors.fill: parent
                onClicked: modelData.activate()
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
