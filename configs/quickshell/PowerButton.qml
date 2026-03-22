// PowerButton.qml — launches wlogout, same as your Waybar config
import Quickshell.Io
import QtQuick

BarButton {
    label: "󰐥"
    onClicked: {
        var proc = Qt.createQmlObject(
            'import Quickshell.Io; Process { command: ["wlogout"] }',
            parent
        )
        proc.running = true
    }
}
