// CpuWidget.qml — CPU freq + usage via /proc/stat polling
// Uses: Quickshell.Io.Process with running+stdout to poll a shell snippet
import Quickshell.Io
import QtQuick

Item {
    implicitWidth: cpuText.implicitWidth + 8
    implicitHeight: 26

    property string cpuText_: "—"

    // Poll every 2 seconds via a repeating Timer + Process
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: cpuProc.running = true
    }

    Process {
        id: cpuProc
        command: ["bash", "-c",
            // Read two /proc/stat samples 200ms apart, compute usage %
            "read a b c d e f g h < /proc/stat; " +
            "sleep 0.2; " +
            "read A B C D E F G H < /proc/stat; " +
            "idle1=$((d+h)); total1=$((a+b+c+d+e+f+g+h)); " +
            "idle2=$((D+H)); total2=$((A+B+C+D+E+F+G+H)); " +
            "dtotal=$((total2-total1)); didle=$((idle2-idle1)); " +
            "if [ $dtotal -gt 0 ]; then " +
            "  usage=$(( (dtotal-didle)*100/dtotal )); " +
            "else usage=0; fi; " +
            // Max freq from /sys
            "freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo 0); " +
            "ghz=$(echo \"scale=2; $freq/1000000\" | bc 2>/dev/null || echo '?'); " +
            "echo \"${ghz}GHz | ${usage}%\""
        ]

        stdout: SplitParser {
            onRead: (line) => cpuText_ = line.trim()
        }
    }

    Component.onCompleted: cpuProc.running = true

    Text {
        id: cpuText
        anchors.centerIn: parent
        text: cpuText_
        color: "#fb958b"
        font.pixelSize: 12
    }
}
