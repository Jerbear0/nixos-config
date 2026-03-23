import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

Item {
    implicitHeight: mediaCol.implicitHeight

    property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    property bool isPlaying: player !== null && player.playbackState === MprisPlaybackState.Playing

    Connections {
        target: Mpris.players
        function onObjectInsertedPost() {
            player = Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
        }
        function onObjectRemovedPost() {
            player = Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
        }
    }

    readonly property bool hasPlayer: player !== null

    Column {
        id: mediaCol
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        Text {
            text: "NOW PLAYING"
            color: "#3fc4de"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 1.5
        }

        Text {
            width: parent.width
            text: hasPlayer ? (player.trackTitle || "Unknown") : "Nothing playing"
            color: hasPlayer ? "#e5e7eb" : "#4b5563"
            font.pixelSize: 13
            font.bold: true
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: {
                if (!hasPlayer || !player.trackArtists) return ""
                var a = player.trackArtists
                return Array.isArray(a) ? a.join(", ") : String(a)
            }
            color: "#8a9ab5"
            font.pixelSize: 11
            elide: Text.ElideRight
            visible: text !== ""
        }

        Row {
            spacing: 8
            anchors.horizontalCenter: parent.horizontalCenter
            MediaButton { icon: "⏮"; onClicked: if (player) player.previous() }
            MediaButton {
                icon: isPlaying ? "⏸" : "▶"
                accent: true
                onClicked: if (player) player.togglePlaying()
            }
            MediaButton { icon: "⏭"; onClicked: if (player) player.next() }
        }
    }
}
