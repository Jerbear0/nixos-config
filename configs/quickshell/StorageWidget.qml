// StorageWidget.qml — shows all real mounted disks dynamically
import Quickshell.Io
import QtQuick

Row {
    spacing: 8
    property var _disks: []

    Timer { interval: 60000; running: true; repeat: true; onTriggered: proc.running = true }
    Process {
        id: proc
        // Filter to real block devices only (/dev/sd*, /dev/nvme*, /dev/vd*)
        command: ["bash", "-c",
            "df -h | awk '$1 ~ /^\\/dev\\/(sd|nvme|vd)/ {print $1, $4, $5, $6}'"
        ]
        stdout: SplitParser {
            onRead: (line) => {
                var parts = line.trim().split(/\s+/)
                if (parts.length >= 4) {
                    var newDisks = _disks.slice()
                    newDisks.push({
                        dev: parts[0].replace("/dev/", ""),
                        avail: parts[1],
                        use: parts[2],
                        mount: parts[3]
                    })
                    _disks = newDisks
                }
            }
        }
        onRunningChanged: if (running) _disks = []
    }
    Component.onCompleted: proc.running = true

    Repeater {
        model: _disks
        Row {
            spacing: 4
            Text {
                text: ""
                color: "#3fc4de"
                font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                // Show mount point + available space
                text: (modelData.mount === "/" ? "root" : modelData.mount.split("/").pop()) + " " + modelData.avail
                color: parseInt(modelData.use) > 90 ? "#ef4444"
                     : parseInt(modelData.use) > 75 ? "#ebcb8b"
                     : "#e5e7eb"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
