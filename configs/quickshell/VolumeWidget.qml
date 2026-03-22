// VolumeWidget.qml — WirePlumber/Pipewire volume
// Uses: Pipewire singleton, PwNode, PwNodeAudio
//       audio.volume (0.0-1.0), audio.muted
//       Pipewire.defaultAudioSink
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 4

    readonly property var sink:  Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null

    readonly property int volPct: audio ? Math.round(audio.volume * 100) : 0
    readonly property bool muted: audio ? audio.muted : false

    Text {
        text: {
            if (!parent.audio) return "  —"
            if (parent.muted)  return "  —"
            var v = parent.volPct
            if (v === 0) return " 0%"
            if (v < 30)  return " " + v + "%"
            if (v < 70)  return " " + v + "%"
            return " " + v + "%"
        }
        color: parent.muted ? "#6b7280" : "#fab387"
        font.pixelSize: 12
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Toggle mute via pactl (same as your Waybar config)
            Qt.openUrlExternally("exec:pactl set-mute @DEFAULT_SINK@ toggle")
        }
        // Scroll to adjust volume
        onWheel: (event) => {
            if (!parent.audio) return
            var delta = event.angleDelta.y > 0 ? 0.05 : -0.05
            parent.audio.volume = Math.max(0, Math.min(1.5, parent.audio.volume + delta))
        }
    }
}
