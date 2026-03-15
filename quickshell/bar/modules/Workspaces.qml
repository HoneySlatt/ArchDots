import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: workspaceRow.implicitWidth + 8
    implicitHeight: Theme.barHeight

    Row {
        id: workspaceRow
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 8
        spacing: 0

        Repeater {
            model: {
                let ws = [];
                if (Hyprland.workspaces) {
                    for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
                        ws.push(Hyprland.workspaces.values[i]);
                    }
                }
                ws.sort((a, b) => a.id - b.id);
                return ws.filter(w => w.id > 0);
            }

            delegate: Item {
                required property var modelData

                width: 32
                height: Theme.barHeight

                Text {
                    anchors.centerIn: parent
                    text: {
                        if (modelData.name === "magic") return "\uf074";
                        if (modelData.name === "zellij") return "\uf120";
                        if (modelData.id === 10) return "\u{f02b4}";
                        if (modelData.name === "lock") return "\uf023";
                        return "\uf111";
                    }
                    color: {
                        if (modelData.id === Hyprland.focusedMonitor?.activeWorkspace?.id)
                            return Theme.text;
                        return Theme.caution;
                    }
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.fontWeight
                    font.italic: true

                    Behavior on color {
                        ColorAnimation { duration: 250 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + modelData.id)
                }
            }
        }

        // Special workspaces
        Repeater {
            model: {
                let ws = [];
                if (Hyprland.workspaces) {
                    for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
                        let w = Hyprland.workspaces.values[i];
                        if (w.id < 0) ws.push(w);
                    }
                }
                return ws;
            }

            delegate: Item {
                required property var modelData

                property bool blinkState: false
                property bool isActive: modelData.id === Hyprland.focusedMonitor?.activeWorkspace?.id

                width: 32
                height: Theme.barHeight

                Text {
                    anchors.centerIn: parent
                    text: {
                        if (modelData.name === "magic") return "\uf074";
                        if (modelData.name === "zellij") return "\uf120";
                        return "\uf111";
                    }
                    color: {
                        if (isActive) return blinkState ? Theme.text : Theme.separator;
                        return Theme.caution;
                    }
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.fontWeight
                    font.italic: true
                }

                Timer {
                    interval: 500
                    running: isActive
                    repeat: true
                    onTriggered: blinkState = !blinkState
                    onRunningChanged: if (!running) blinkState = false
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("togglespecialworkspace " + modelData.name)
                }
            }
        }
    }
}
