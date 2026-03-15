import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: VolumePopupState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            color: "transparent"

            WlrLayershell.namespace: "quickshell:volumepopup"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            // ── Focus grab ──

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                active: false
                onCleared: () => {
                    if (!active)
                        VolumePopupState.close();
                }
            }

            Connections {
                target: VolumePopupState
                function onVisibleChanged() {
                    if (VolumePopupState.visible) {
                        grabTimer.start();
                    } else {
                        grabTimer.stop();
                        grab.active = false;
                    }
                }
            }

            Timer {
                id: grabTimer
                interval: 50
                repeat: false
                onTriggered: grab.active = VolumePopupState.visible
            }

            // ── Click outside to close ──

            MouseArea {
                anchors.fill: parent
                onClicked: VolumePopupState.close()
            }

            // ── Keyboard handling ──

            FocusScope {
                anchors.fill: parent
                focus: VolumePopupState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        VolumePopupState.close();
                        event.accepted = true;
                    }
                }

                // ── Popup panel ──

                // Clip container for bottom-only rounded corners
                Item {
                    id: popupClip
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 0
                    anchors.rightMargin: 130
                    width: 210
                    height: contentCol.height + 24
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: -radius
                        height: parent.height + radius
                        color: Theme.background
                        radius: 10
                        border.color: Theme.separator
                        border.width: 1
                    }

                    // Block clicks inside from closing
                    MouseArea { anchors.fill: parent }

                    Column {
                        id: contentCol
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 12
                        spacing: 8

                        // ── Header ──

                        RowLayout {
                            width: parent.width
                            spacing: 6

                            Text {
                                text: {
                                    if (VolumeState.muted) return "\uf026";
                                    if (VolumeState.volume <= 30) return "\uf027";
                                    return "\uf028";
                                }
                                color: VolumeState.muted ? Theme.caution : Theme.misc
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize + 2
                                font.weight: Theme.fontWeight
                            }

                            Text {
                                text: "Volume"
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.weight: Font.Bold
                                Layout.fillWidth: true
                            }

                            Text {
                                text: VolumeState.volume + "%"
                                color: Theme.caution
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                font.weight: Theme.fontWeight
                            }
                        }

                        // ── Volume slider ──

                        Item {
                            width: parent.width
                            height: 20

                            Rectangle {
                                id: sliderTrack
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: 6
                                radius: 3
                                color: Theme.separator

                                Rectangle {
                                    width: parent.width * (VolumeState.volume / 100)
                                    height: parent.height
                                    radius: parent.radius
                                    color: VolumeState.muted ? Theme.separator : Theme.misc
                                    Behavior on width { NumberAnimation { duration: 60 } }
                                }

                                // Slider handle
                                Rectangle {
                                    x: parent.width * (VolumeState.volume / 100) - width / 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: VolumeState.muted ? Theme.separator : Theme.misc
                                    Behavior on x { NumberAnimation { duration: 60 } }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                preventStealing: true
                                onClicked: function(mouse) {
                                    let pct = Math.max(0, Math.min(100, Math.round(mouse.x / width * 100)));
                                    VolumeState.setVolume(pct);
                                }
                                onPositionChanged: function(mouse) {
                                    if (pressed) {
                                        let pct = Math.max(0, Math.min(100, Math.round(mouse.x / width * 100)));
                                        VolumeState.setVolume(pct);
                                    }
                                }
                            }
                        }

                        // ── Mute button ──

                        Rectangle {
                            width: parent.width
                            height: 28
                            radius: 6
                            color: muteMa.containsMouse ? Theme.separator : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: VolumeState.muted ? "\uf026  Unmute" : "\uf028  Mute"
                                color: VolumeState.muted ? Theme.caution : Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                font.weight: Theme.fontWeight
                            }

                            MouseArea {
                                id: muteMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: VolumeState.toggleMute()
                            }
                        }
                    }
                }
            }
        }
    }
}
