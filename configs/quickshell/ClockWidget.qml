// ClockWidget.qml
import Quickshell
import QtQuick

Item {
    implicitWidth: col.implicitWidth + 16
    implicitHeight: 36

    SystemClock { id: clock; precision: SystemClock.Minutes }

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(clock.date, "HH:mm")
            color: "#e5e7eb"
            font.pixelSize: 14
            font.bold: true
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(clock.date, "d MMM")
            color: "#82dccc"
            font.pixelSize: 10
        }
    }
}
