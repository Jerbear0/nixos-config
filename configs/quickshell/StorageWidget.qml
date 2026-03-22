// StorageWidget.qml — root partition free space
// Mirrors your existing storage.sh logic
import Quickshell.Io
import QtQuick

Item {
    implicitWidth: storText.implicitWidth + 8
    implicitHeight: 26

    property string display: "—"

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: storProc.running = true
    }

    Process {
        id: storProc
        command: ["bash", "-c",
            "df -h -P -l / | awk 'NR==2{print \" \" $4}'"
        ]
        stdout: SplitParser {
            onRead: (line) => display = line.trim()
        }
    }

    Component.onCompleted: storProc.running = true

    Text {
        id: storText
        anchors.centerIn: parent
        text: " " + display
        color: "#e5e7eb"
        font.pixelSize: 12
    }
}
