// StatRow.qml — label + value row for stats section
import QtQuick

Item {
    property string label: ""
    property string value: "—"
    property color valueColor: "#e5e7eb"

    implicitHeight: 18
    implicitWidth: parent ? parent.width : 200

    Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: label
        color: "#8a9ab5"
        font.pixelSize: 12
    }
    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: value
        color: valueColor
        font.pixelSize: 12
        font.bold: true
    }
}
