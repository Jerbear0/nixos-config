// ClockWidget.qml — date + time using SystemClock
// SystemClock updates on the interval you set; format via Qt.formatDateTime
import Quickshell
import QtQuick

Item {
    implicitWidth: clockCol.implicitWidth + 16
    implicitHeight: 36

    SystemClock {
        id: clock
        precision: SystemClock.Minutes  // update every minute
    }

    Column {
        id: clockCol
        anchors.centerIn: parent
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.now, "HH:mm")
            color: "#c8d2e0"
            font.pixelSize: 14
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.now, "d MMM")
            color: "#8a9ab5"
            font.pixelSize: 10
        }
    }
}
