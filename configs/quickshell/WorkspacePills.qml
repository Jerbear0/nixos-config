// WorkspacePills.qml
import Quickshell
import Quickshell.Hyprland
import QtQuick

Row {
    required property var barScreen
    spacing: 4

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            required property var modelData

            color: modelData.focused ? "#82dccc"
                 : modelData.urgent  ? "#ef4444"
                 : modelData.active  ? "#007d6f"
                 : "#182545"

            radius: 6
            height: 26
            width: modelData.focused ? 30 : 22

            Behavior on width  { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            Behavior on color  { ColorAnimation  { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: modelData.name
                color: modelData.focused ? "#0d1117" : "#8a9ab5"
                font.pixelSize: 11
                font.bold: modelData.focused
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: modelData.activate()
            }

            // Hover highlight
            HoverHandler { id: wsHover }
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "white"
                opacity: wsHover.hovered ? 0.08 : 0
                Behavior on opacity { NumberAnimation { duration: 100 } }
            }
        }
    }
}
