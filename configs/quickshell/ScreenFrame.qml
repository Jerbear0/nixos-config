import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

Item {
    id: root
    required property var screen
    property alias leftHovered: leftEdge.hovered
    signal topHoverSignal()

    PanelWindow {
        screen: root.screen
        anchors { top: true; left: true; right: true }
        implicitHeight: 20
        color: "#82dccc"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: 20
        WlrLayershell.namespace: "quickshell-frame-top"
        HoverHandler { onHoveredChanged: if (hovered) root.topHoverSignal() }
        Row {
            anchors.centerIn: parent
            spacing: 5
            Repeater {
                model: Hyprland.workspaces
                Rectangle {
                    required property var modelData
                    width: modelData.focused ? 20 : 6
                    height: 6; radius: 3
                    color: "#111826"
                    opacity: modelData.focused ? 1.0 : modelData.active ? 0.6 : 0.3
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on width { NumberAnimation { duration: 150 } }
                }
            }
        }
    }

    PanelWindow {
        screen: root.screen
        anchors { bottom: true; left: true; right: true }
        implicitHeight: 20
        color: "#82dccc"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: 20
        WlrLayershell.namespace: "quickshell-frame-bottom"
    }

    PanelWindow {
        id: leftEdge
        screen: root.screen
        anchors { left: true; top: true; bottom: true }
        implicitWidth: 20
        color: "#82dccc"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: 20
        WlrLayershell.namespace: "quickshell-frame-left"
        property bool hovered: lh.hovered
        HoverHandler { id: lh }
    }

    PanelWindow {
        screen: root.screen
        anchors { right: true; top: true; bottom: true }
        implicitWidth: 20
        color: "#82dccc"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: 20
        WlrLayershell.namespace: "quickshell-frame-right"
    }

    PanelWindow {
        screen: root.screen
        anchors { left: true; top: true }
        implicitWidth: 60; implicitHeight: 60
        margins.top: -20; margins.left: -20
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: 0
        WlrLayershell.namespace: "quickshell-frame-corner-tl"
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = "#82dccc"
                ctx.lineWidth = 20
                ctx.lineCap = "butt"
                ctx.beginPath()
                ctx.arc(60, 60, 50, Math.PI, Math.PI * 1.5)
                ctx.stroke()
            }
        }
    }

    PanelWindow {
        screen: root.screen
        anchors { right: true; top: true }
        implicitWidth: 60; implicitHeight: 60
        margins.top: -20; margins.right: -20
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: 0
        WlrLayershell.namespace: "quickshell-frame-corner-tr"
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = "#82dccc"
                ctx.lineWidth = 20
                ctx.lineCap = "butt"
                ctx.beginPath()
                ctx.arc(0, 60, 50, Math.PI * 1.5, 0)
                ctx.stroke()
            }
        }
    }

    PanelWindow {
        screen: root.screen
        anchors { left: true; bottom: true }
        implicitWidth: 60; implicitHeight: 60
        margins.bottom: -20; margins.left: -20
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: 0
        WlrLayershell.namespace: "quickshell-frame-corner-bl"
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = "#82dccc"
                ctx.lineWidth = 20
                ctx.lineCap = "butt"
                ctx.beginPath()
                ctx.arc(60, 0, 50, Math.PI * 0.5, Math.PI)
                ctx.stroke()
            }
        }
    }

    PanelWindow {
        screen: root.screen
        anchors { right: true; bottom: true }
        implicitWidth: 60; implicitHeight: 60
        margins.bottom: -20; margins.right: -20
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: 0
        WlrLayershell.namespace: "quickshell-frame-corner-br"
        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = "#82dccc"
                ctx.lineWidth = 20
                ctx.lineCap = "butt"
                ctx.beginPath()
                ctx.arc(0, 0, 50, 0, Math.PI * 0.5)
                ctx.stroke()
            }
        }
    }
}
