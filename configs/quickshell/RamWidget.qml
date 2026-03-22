// RamWidget.qml — used / total RAM from /proc/meminfo
import Quickshell.Io
import QtQuick

Item {
    implicitWidth: ramText.implicitWidth + 8
    implicitHeight: 26

    property string display: "—"

    Timer {
        interval: 10000  // refresh every 10s — RAM changes slowly
        running: true
        repeat: true
        onTriggered: ramProc.running = true
    }

    Process {
        id: ramProc
        command: ["bash", "-c",
            "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{" +
            "used=(t-a)/1048576; total=t/1048576; " +
            "printf \"%.2f / %.0f GB\", used, total}' /proc/meminfo"
        ]
        stdout: SplitParser {
            onRead: (line) => display = line.trim()
        }
    }

    Component.onCompleted: ramProc.running = true

    Text {
        id: ramText
        anchors.centerIn: parent
        text: " " + display
        color: "#ebcb8b"
        font.pixelSize: 12
    }
}
