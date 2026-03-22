import Quickshell.Io
import QtQuick

Item {
    implicitHeight: 26
    implicitWidth: volText.implicitWidth + 8

    property string volDisplay: "?%"
    property bool muted: false

    function refresh() { volProc.running = true }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: refresh()
    }

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: (line) => {
                var isMuted = line.includes("[MUTED]")
                var match = line.match(/Volume:\s*([\d.]+)/)
                if (match) {
                    volDisplay = Math.round(parseFloat(match[1]) * 100) + "%"
                    muted = isMuted
                }
            }
        }
    }

    Process {
        id: muteProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        onRunningChanged: if (!running) refresh()
    }

    Process {
        id: volumeChangeProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"]
        onRunningChanged: if (!running) refresh()
    }

    Process {
        id: pavuProc
        command: ["pavucontrol"]
    }

    Component.onCompleted: refresh()

    Text {
        id: volText
        anchors.centerIn: parent
        text: " " + (parent.muted ? " —" : parent.volDisplay)
        color: parent.muted ? "#6b7280" : "#fab387"
        font.pixelSize: 12
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true

        onClicked: (event) => {
            if (event.button === Qt.RightButton) {
                muteProc.running = true
            } else {
                pavuProc.running = true
            }
        }

        onWheel: (event) => {
            var arg = event.angleDelta.y > 0 ? "5%+" : "5%-"
            volumeChangeProc.command = ["wpctl", "set-volume", "-l", "1.5", "@DEFAULT_AUDIO_SINK@", arg]
            volumeChangeProc.running = true
        }
    }
}
