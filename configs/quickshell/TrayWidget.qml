// TrayWidget.qml — system tray using Quickshell.Services.SystemTray
// Uses: SystemTray.items (ObjectModel<SystemTrayItem>)
//       item.icon (url/name), item.tooltip, item.activate()
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

            // Use IconImage for proper icon theme resolution
            IconImage {
                anchors.fill: parent
                source: modelData.icon
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: (event) => {
                    if (event.button === Qt.LeftButton) {
                        modelData.activate()
                    } else {
                        modelData.secondaryActivate()
                    }
                }

                ToolTip.visible: containsMouse
                ToolTip.text: modelData.tooltip || modelData.title || ""
                hoverEnabled: true
            }
        }
    }
}
