// MediaButton.qml
import QtQuick

Rectangle {
    property string icon: ""
    property bool accent: false
    signal clicked()

    width: accent ? 40 : 32
    height: accent ? 40 : 32
    radius: width / 2
    color: accent ? "#007d6f" : "#182545"

    HoverHandler { id: h }
    Rectangle {
        anchors.fill: parent; radius: parent.radius
        color: "white"
        opacity: h.hovered ? 0.12 : 0
        Behavior on opacity { NumberAnimation { duration: 100 } }
    }

    Text {
        anchors.centerIn: parent
        text: parent.icon
        color: "#e5e7eb"
        font.pixelSize: parent.accent ? 16 : 13
    }

    MouseArea { anchors.fill: parent; onClicked: parent.clicked() }
}
