import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property var screen
    property bool triggerHovered: false

    onTriggerHoveredChanged: {
        if (triggerHovered) {
            panel.visible = true
        } else {
            autoClose.restart()
        }
    }

    PanelWindow {
        id: panel
        screen: root.screen
        anchors { left: true; top: true; bottom: true }
        implicitWidth: 340
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: 0
        WlrLayershell.namespace: "quickshell-dashboard"
        visible: root.triggerHovered || panelHover.hovered

        Timer {
            id: autoClose
            interval: 800
            onTriggered: if (!panelHover.hovered && !root.triggerHovered) panel.visible = false
        }

        Process { id: launchProc; command: ["true"] }

        Rectangle {
            id: dashRect
            x: panel.visible ? 0 : -(width + 16)
            anchors.verticalCenter: parent.verticalCenter
            width: 300
            height: dashCol.implicitHeight + 32
            topLeftRadius: 0
            bottomLeftRadius: 0
            topRightRadius: 12
            bottomRightRadius: 12
            gradient: Gradient {
               orientation: Gradient.Horizontal
               GradientStop { position: 0.0; color: "#82dccc" }
               GradientStop { position: 0.12; color: Qt.rgba(0.067, 0.094, 0.149, 1.0) }
               GradientStop { position: 0.3; color: "#111826" }
            }

            HoverHandler {
                id: panelHover
                onHoveredChanged: if (!hovered && !root.triggerHovered) autoClose.restart()
            }

            Behavior on x {
                NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
            }

            ColumnLayout {
                id: dashCol
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 18
                anchors.leftMargin: 42
                spacing: 12

                SystemClock { id: dashClock; precision: SystemClock.Minutes }

                Column {
                    spacing: 2
                    Layout.fillWidth: true
                    Text { text: Qt.formatTime(dashClock.date, "HH:mm"); color: "#e5e7eb"; font.pixelSize: 40; font.bold: true }
                    Text { text: Qt.formatDate(dashClock.date, "dddd, d MMMM"); color: "#82dccc"; font.pixelSize: 11 }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#182545" }
                MediaSection { Layout.fillWidth: true }
                Rectangle { Layout.fillWidth: true; height: 1; color: "#182545" }
                DashStatsSection { Layout.fillWidth: true }
                Rectangle { Layout.fillWidth: true; height: 1; color: "#182545" }

                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10
                    DashButton { label: "term";  onClicked: { launchProc.command = ["alacritty", "--config-file", "/etc/nixos/configs/alacritty.toml"]; launchProc.running = true; panel.visible = false } }
                    DashButton { label: "web";   onClicked: { launchProc.command = ["firefox"]; launchProc.running = true; panel.visible = false } }
                    DashButton { label: "files"; onClicked: { launchProc.command = ["dolphin"]; launchProc.running = true; panel.visible = false } }
                    DashButton { label: "audio"; onClicked: { launchProc.command = ["pavucontrol"]; launchProc.running = true; panel.visible = false } }
                }

                Item { height: 4 }
	    }
        }
    }
}
