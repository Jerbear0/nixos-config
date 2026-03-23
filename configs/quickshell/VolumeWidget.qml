// VolumeWidget.qml
import Quickshell.Io
import QtQuick

Item {
    implicitHeight: 26
    implicitWidth: row.implicitWidth + 12

    property string volDisplay: "—"
    property bool muted: false

    function refresh() { volProc.running = true }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: refresh() }
    Component.onCompleted: refresh()

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: (line) => {
                muted = line.includes("[MUTED]")
                var m = line.match(/Volume:\s*([\d.]+)/)
                if (m) volDisplay = Math.round(parseFloat(m[1]) * 100) + "%"
            }
        }
    }

    Process { id: muteProc;   command: ["wpctl", "set-mute",   "@DEFAULT_AUDIO_SINK@", "toggle"]; onRunningChanged: if (!running) refresh() }
    Process { id: pavuProc;   command: ["pavucontrol"] }
    Process { id: volUpProc;  command: ["wpctl", "set-volume", "-l", "1.5", "@DEFAULT_AUDIO_SINK@", "5%+"]; onRunningChanged: if (!running) refresh() }
    Process { id: volDnProc;  command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"];               onRunningChanged: if (!running) refresh() }

    HoverHandler { id: volHover }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#182545"
        opacity: volHover.hovered ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 100 } }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: parent.parent.muted ? "󰖁" : "󰕾"
            color: "#3fc4de"
            font.pixelSize: 11
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: parent.parent.muted ? "—" : parent.parent.volDisplay
            color: parent.parent.muted ? "#4b5563" : "#e5e7eb"
            font.pixelSize: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (e) => e.button === Qt.RightButton ? muteProc.running = true : pavuProc.running = true
        onWheel: (e) => e.angleDelta.y > 0 ? volUpProc.running = true : volDnProc.running = true
    }
}
