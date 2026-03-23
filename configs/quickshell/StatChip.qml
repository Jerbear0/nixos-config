// StatChip.qml — base for CPU/RAM/Storage widgets, shows icon + value
import QtQuick

Item {
    property string icon: ""
    property string value: "—"
    property color valueColor: "#e5e7eb"

    implicitWidth: row.implicitWidth + 12
    implicitHeight: 26

    HoverHandler { id: chipHover }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#182545"
        opacity: chipHover.hovered ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 100 } }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: parent.parent.icon
            color: "#3fc4de"
            font.pixelSize: 11
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: parent.parent.value
            color: parent.parent.valueColor
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
