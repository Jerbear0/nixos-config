// WindowTitle.qml — shows active window title, fades if none
import Quickshell.Hyprland
import QtQuick

Item {
    implicitWidth: titleText.implicitWidth + 8
    implicitHeight: 26

    readonly property var win: Hyprland.activeToplevel
    readonly property string title: win ? (win.title.length > 40
        ? win.title.substring(0, 40) + "…"
        : win.title) : ""

    Text {
        id: titleText
        anchors.centerIn: parent
        text: parent.title
        color: "#8a9ab5"
        font.pixelSize: 12
        opacity: parent.title !== "" ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
}
