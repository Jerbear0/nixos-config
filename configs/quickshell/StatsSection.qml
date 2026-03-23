import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    implicitHeight: col.implicitHeight
    property string _cpu: "—"
    property string _ram: "—"
    property var _disks: []

    Timer { interval: 4000; running: true; repeat: true; onTriggered: { cpuProc.running = true; ramProc.running = true } }
    Timer { interval: 30000; running: true; repeat: true; onTriggered: diskProc.running = true }

    Process {
        id: cpuProc
        command: ["bash", "-c", [
            "read cpu a b c idle e f g h < /proc/stat",
            "sleep 1",
            "read cpu A B C IDLE E F G H < /proc/stat",
            "echo $(( (A+B+C+IDLE+E+F+G+H) - (a+b+c+idle+e+f+g+h) )) $(( IDLE - idle ))"
        ].join("; ")]
        stdout: SplitParser {
            onRead: (line) => {
                var parts = line.trim().split(" ")
                if (parts.length >= 2) {
                    var total = parseInt(parts[0])
                    var idle = parseInt(parts[1])
                    if (total > 0) _cpu = Math.round((total - idle) * 100 / total) + "%"
                }
            }
        }
    }

    Process {
        id: ramProc
        command: ["bash", "-c",
            "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf \"%.1f / %.0f GB\", (t-a)/1048576, t/1048576}' /proc/meminfo"
        ]
        stdout: SplitParser { onRead: (line) => _ram = line.trim() }
    }

    Process {
        id: diskProc
        command: ["bash", "-c",
            "df -h | awk '$1 ~ /^\\/dev\\/(sd|nvme|vd)/ {print $1, $4, $5, $6}'"
        ]
        stdout: SplitParser {
            onRead: (line) => {
                var parts = line.trim().split(/\s+/)
                if (parts.length >= 4) {
                    var newDisks = _disks.slice()
                    newDisks.push({
                        avail: parts[1],
                        use:   parts[2],
                        mount: parts[3]
                    })
                    _disks = newDisks
                }
            }
        }
        onRunningChanged: if (running) _disks = []
    }

    Component.onCompleted: { cpuProc.running = true; ramProc.running = true; diskProc.running = true }

    Column {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 6

        Text {
            text: "SYSTEM"
            color: "#3fc4de"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 1.5
        }

        StatRow { label: "CPU"; value: _cpu; valueColor: "#fb958b" }
        StatRow { label: "RAM"; value: _ram; valueColor: "#ebcb8b" }

        Repeater {
            model: _disks
            StatRow {
                label: modelData.mount === "/" ? "root" : modelData.mount.split("/").pop()
                value: modelData.avail + " free"
                valueColor: parseInt(modelData.use) > 90 ? "#ef4444"
                           : parseInt(modelData.use) > 75 ? "#ebcb8b"
                           : "#8a9ab5"
            }
        }
    }
}
