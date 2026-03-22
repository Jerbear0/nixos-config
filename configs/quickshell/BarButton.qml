// BarButton.qml — small pill button used throughout the bar
import QtQuick

Rectangle {
    id: root

    property string label: ""
    signal clicked()

    implicitWidth:  btnLabel.implicitWidth + 14
    implicitHeight: 26
    radius: 6

    color: hover.containsMouse ? "#1e2d45" : "transparent"

    Behavior on color { ColorAnimation { duration: 100 } }

    Text {
        id: btnLabel
        anchors.centerIn: parent
        text: root.label
        color: "#e5e7eb"
        font.pixelSize: 13
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
