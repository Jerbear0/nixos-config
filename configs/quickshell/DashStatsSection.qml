import Quickshell.Io
import QtQuick

Item {
    implicitHeight: col.implicitHeight
    property string _cpu: "—"
    property string _ram: "—"
    property var _disks: []

    Timer { interval: 4000; running: true; repeat: true; onTriggered: { cpuProc.running = true; ramProc.running = true } }
    Timer { interval: 30000; running: true; repeat: true; onTriggered: diskProc.running = true }

    Process {
        id: cpuProc
        command: ["python3", "-c", [
            "import time",
            "f=open('/proc/stat')",
            "v1=list(map(int,f.readline().split()[1:]))",
            "f.close()",
            "time.sleep(1)",
            "f=open('/proc/stat')",
            "v2=list(map(int,f.readline().split()[1:]))",
            "f.close()",
            "i1,i2=v1[3]+v1[4],v2[3]+v2[4]",
            "t1,t2=sum(v1),sum(v2)",
            "dt=t2-t1",
            "print(str(round((1-(i2-i1)/dt)*100))+'%' if dt>0 else '0%')"
        ].join(";")]
        stdout: SplitParser { onRead: (line) => _cpu = line.trim() }
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
            "df -h | awk '$1 ~ /^\\/dev\\/(sd|nvme|vd)/ {print $4, $5, $6}'"
        ]
        stdout: SplitParser {
            onRead: (line) => {
                var p = line.trim().split(/\s+/)
                if (p.length >= 3) {
                    var d = _disks.slice()
                    d.push({ avail: p[0], use: p[1], mount: p[2] })
                    _disks = d
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

        Text { text: "SYSTEM"; color: "#3fc4de"; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.5 }
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
