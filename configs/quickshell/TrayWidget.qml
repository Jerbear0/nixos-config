// TrayWidget.qml
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

Row {
    spacing: 4

    Repeater {
        model: SystemTray.items

        Item {
            required property var modelData
            width: 20; height: 20

            IconImage { anchors.fill: parent; source: modelData.icon }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (e) => e.button === Qt.LeftButton
                    ? modelData.activate()
                    : modelData.secondaryActivate()
            }
        }
    }
}
