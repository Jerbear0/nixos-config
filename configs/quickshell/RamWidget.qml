import Quickshell.Io
import QtQuick

Item {
    implicitHeight: 26
    implicitWidth: row.implicitWidth + 12
    property string _val: "—"

    Timer { interval: 10000; running: true; repeat: true; onTriggered: proc.running = true }
    Process {
        id: proc
        command: ["bash", "-c",
            "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf \"%.1fG\", (t-a)/1048576}' /proc/meminfo"
        ]
        stdout: SplitParser { onRead: (line) => _val = line.trim() }
    }
    Component.onCompleted: proc.running = true

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4
        Text { text: ""; color: "#3fc4de"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
        Text { text: _val; color: "#ebcb8b"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
    }
}
