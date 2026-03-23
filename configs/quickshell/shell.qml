import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

ShellRoot {
    Variants {
        model: Quickshell.screens

        Item {
            property var modelData

            // Frame — handles top strip, all edges, corners, dashboard trigger
            ScreenFrame {
                id: frame
		screen: modelData
		onTopHoverSignal: barWin.visible = true
            }

            // Bar pill — appears below the top frame edge on hover
            PanelWindow {
                id: barWin
                screen: modelData
                anchors { top: true; left: true; right: true }
                implicitHeight: 56   // T(12) + gap + pill(44)
                color: "transparent"
                visible: false
                WlrLayershell.exclusiveZone: 0
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "quickshell-bar"
                margins { left: 60; right: 60 }

                // Trigger: hover the frame top edge (exclusiveZone=T reserves space)
                // barWin sits above, so hovering the top 12px of screen triggers both
		HoverHandler {
		    id: barHover
		    onHoveredChanged: if (!hovered) hideTimer.restart()
                }

		Timer {
                    id: hideTimer
                    interval: 800
                    onTriggered: if (!barHover.hovered) barWin.visible = false
                }

                Rectangle {
                    x: 8; y: 0   // start below the frame top edge
                    width: parent.width - 16
                    height: 44
                    topLeftRadius: 0
                    topRightRadius: 0
                    bottomLeftRadius: 12
                    bottomRightRadius: 12
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: "#82dccc" }
                        GradientStop { position: 0.15; color: Qt.rgba(0.067, 0.094, 0.149, 1.0) }
                        GradientStop { position: 0.4; color: "#111826" }
                    }

                    Item {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            WorkspacePills { barScreen: modelData }
                            WindowTitle { }
                        }

                        ClockWidget { anchors.centerIn: parent }

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6
                            VolumeWidget { }
                            TrayWidget { }
                            PowerButton { }
                        }
                    }
                }
            }

            // Dashboard — triggered by frame left edge hover
            DashboardPanel {
                screen: modelData
                triggerHovered: frame.leftHovered
            }
        }
    }
}
