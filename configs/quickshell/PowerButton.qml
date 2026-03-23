// PowerButton.qml
import Quickshell.Io
import QtQuick

Item {
    implicitWidth: 30
    implicitHeight: 26

    HoverHandler { id: pwrHover }
    Process { id: wlogoutProc; command: ["wlogout"] }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: pwrHover.hovered ? "#3d1515" : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    Text {
        anchors.centerIn: parent
        text: "󰐥"
        color: pwrHover.hovered ? "#ef4444" : "#8a9ab5"
        font.pixelSize: 14
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: wlogoutProc.running = true
    }
}
