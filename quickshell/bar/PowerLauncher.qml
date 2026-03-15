import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: scope

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: PowerLauncherState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            color: "transparent"

            WlrLayershell.namespace: "quickshell:powerlauncher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                active: false
                onCleared: () => { if (!active) PowerLauncherState.close() }
            }

            Connections {
                target: PowerLauncherState
                function onVisibleChanged() {
                    if (PowerLauncherState.visible) {
                        grabTimer.start()
                    } else {
                        grabTimer.stop()
                        grab.active = false
                    }
                }
            }

            Timer {
                id: grabTimer
                interval: 50
                repeat: false
                onTriggered: grab.active = PowerLauncherState.visible
            }

            MouseArea {
                anchors.fill: parent
                onClicked: PowerLauncherState.close()
            }

            Item {
                anchors.fill: parent
                focus: PowerLauncherState.visible
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        PowerLauncherState.close()
                        event.accepted = true
                    }
                }
            }

            function executeAction(command) {
                PowerLauncherState.close()
                Quickshell.execDetached(["sh", "-c", command])
            }

            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 0
                anchors.rightMargin: Theme.margin

                width: col.implicitWidth + 24
                height: col.implicitHeight + 24
                radius: Theme.borderRadius
                color: Theme.background
                border.color: Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.6)
                border.width: 1

                MouseArea { anchors.fill: parent }

                ColumnLayout {
                    id: col
                    anchors.centerIn: parent
                    spacing: 4

                    Repeater {
                        model: [
                            { label: "Lock",     icon: "\uf023", cmd: "hyprlock" },
                            { label: "Logout",   icon: "\uf2f5", cmd: "hyprctl dispatch exit" },
                            { label: "Shutdown", icon: "\uf011", cmd: "systemctl poweroff" },
                            { label: "Reboot",   icon: "\uf021", cmd: "systemctl reboot" },
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 48
                            radius: 10
                            color: area.containsMouse
                                ? Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.8)
                                : "transparent"

                            Behavior on color { ColorAnimation { duration: 100 } }

                            Row {
                                anchors.centerIn: parent
                                spacing: 12

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.icon
                                    color: area.containsMouse ? Theme.accent : Theme.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 18
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.label
                                    color: area.containsMouse ? Theme.accent : Theme.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }
                            }

                            MouseArea {
                                id: area
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.executeAction(modelData.cmd)
                            }
                        }
                    }
                }
            }
        }
    }
}
