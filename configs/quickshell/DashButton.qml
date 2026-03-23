import Quickshell.Io
import QtQuick

Rectangle {
    property string icon: ""
    property string label: ""
    signal clicked()

    width: 52; height: 52
    radius: 10
    color: "#182545"

    HoverHandler { id: h }
    Rectangle {
        anchors.fill: parent; radius: parent.radius
        color: "#82dccc"
        opacity: h.hovered ? 0.15 : 0
        Behavior on opacity { NumberAnimation { duration: 100 } }
    }

    // Try icon first, fall back to label
    Text {
        anchors.centerIn: parent
        text: parent.icon !== "" ? parent.icon : parent.label
        color: h.hovered ? "#82dccc" : "#8a9ab5"
        font.pixelSize: parent.icon !== "" ? 20 : 12
        font.bold: parent.label !== ""
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    MouseArea { anchors.fill: parent; onClicked: parent.clicked() }
}
