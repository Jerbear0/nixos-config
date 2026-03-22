// ClockWidget.qml — date + time using SystemClock
// API: clock.date (QML date object), clock.hours, clock.minutes
import Quickshell
import QtQuick

Item {
    implicitWidth: clockCol.implicitWidth + 16
    implicitHeight: 36

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Column {
        id: clockCol
        anchors.centerIn: parent
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            // Use hours/minutes directly to avoid formatDateTime issues
            text: Qt.formatTime(clock.date, "HH:mm")
            color: "#c8d2e0"
            font.pixelSize: 14
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(clock.date, "d MMM")
            color: "#8a9ab5"
            font.pixelSize: 10
        }
    }
}
