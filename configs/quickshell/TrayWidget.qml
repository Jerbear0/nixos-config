// TrayWidget.qml — system tray using Quickshell.Services.SystemTray
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 4

    Repeater {
        model: SystemTray.items

        delegate: Item {
            required property var modelData  // SystemTrayItem

            width: 20
            height: 20

            IconImage {
                anchors.fill: parent
                source: modelData.icon
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                hoverEnabled: true

                onClicked: (event) => {
                    if (event.button === Qt.LeftButton) {
                        modelData.activate()
                    } else {
                        modelData.secondaryActivate()
                    }
                }
            }
        }
    }
}
