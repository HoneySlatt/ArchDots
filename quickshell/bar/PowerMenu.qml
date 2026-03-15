import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: powerMenuScope

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: PowerMenuState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.85)

            WlrLayershell.namespace: "quickshell:powermenu"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                property bool canBeActive: root.monitorIsFocused
                active: false
                onCleared: () => {
                    if (!active)
                        PowerMenuState.close();
                }
            }

            Connections {
                target: PowerMenuState
                function onVisibleChanged() {
                    if (PowerMenuState.visible) {
                        delayedGrabTimer.start();
                    } else {
                        delayedGrabTimer.stop();
                        grab.active = false;
                    }
                }
            }

            Timer {
                id: delayedGrabTimer
                interval: 50
                repeat: false
                onTriggered: {
                    if (!grab.canBeActive) return;
                    grab.active = PowerMenuState.visible;
                }
            }

            Item {
                anchors.fill: parent
                focus: PowerMenuState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        PowerMenuState.close();
                        event.accepted = true;
                        return;
                    }
                    const key = event.text.toLowerCase();
                    if (key === "l")      executeAction("hyprlock");
                    else if (key === "e") executeAction("hyprctl dispatch exit");
                    else if (key === "s") executeAction("systemctl poweroff");
                    else if (key === "r") executeAction("systemctl reboot");
                }
            }

            function executeAction(command) {
                PowerMenuState.close();
                Quickshell.execDetached(["sh", "-c", command]);
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                PowerMenuButton {
                    label: "Lock";     iconGlyph: "\uf023"
                    onActivated: root.executeAction("hyprlock")
                }
                PowerMenuButton {
                    label: "Logout";   iconGlyph: "\uf2f5"
                    onActivated: root.executeAction("hyprctl dispatch exit")
                }
                PowerMenuButton {
                    label: "Shutdown"; iconGlyph: "\uf011"
                    onActivated: root.executeAction("systemctl poweroff")
                }
                PowerMenuButton {
                    label: "Reboot";   iconGlyph: "\uf021"
                    onActivated: root.executeAction("systemctl reboot")
                }
            }
        }
    }
}
