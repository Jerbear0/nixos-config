// MediaWidget.qml — Spotify / any MPRIS player
// Uses: Mpris.players (ObjectModel<MprisPlayer>)
//       player.trackTitle, .trackArtists, .playbackState, .identity
//       MprisPlaybackState.Playing / .Paused / .Stopped
//       player.next(), .previous(), .togglePlaying()
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // Find the first active Spotify player, fall back to any player
    readonly property var player: {
        var spotify = null
        var any = null
        for (var i = 0; i < Mpris.players.count; i++) {
            var p = Mpris.players.values[i]
            if (p.identity.toLowerCase().includes("spotify")) spotify = p
            if (any === null) any = p
        }
        return spotify ?? any
    }

    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: hasPlayer && player.playbackState === MprisPlaybackState.Playing

    implicitHeight: 26
    implicitWidth: mediaRow.implicitWidth

    visible: hasPlayer

    RowLayout {
        id: mediaRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        // Prev
        BarButton {
            label: "⏮"
            onClicked: if (root.player) root.player.previous()
        }

        // Play/Pause
        BarButton {
            label: root.isPlaying ? "⏸" : "▶"
            onClicked: if (root.player) root.player.togglePlaying()
        }

        // Next
        BarButton {
            label: "⏭"
            onClicked: if (root.player) root.player.next()
        }

        // Track info — truncated
        Text {
            visible: root.hasPlayer
            Layout.maximumWidth: 220

            text: {
                if (!root.player) return ""
                var artists = root.player.trackArtists.join(", ")
                var title   = root.player.trackTitle
                if (!root.isPlaying) return "⏸  " + title
                if (artists) return artists + " — " + title
                return title
            }

            elide: Text.ElideRight
            color: "#e5e7eb"
            font.pixelSize: 12
        }
    }
}
