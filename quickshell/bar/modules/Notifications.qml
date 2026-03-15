import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: notifText.implicitWidth + Theme.modulePadding * 2
    implicitHeight: Theme.barHeight

    // U+F009A=notification, U+F009C=none, U+F009B=dnd-notification, U+F0A91=dnd-none
    property string notifIcon: "\u{f009c}"

    Text {
        id: notifText
        anchors.centerIn: parent
        text: notifIcon
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }

    opacity: mouseArea.containsMouse ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 80 } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                dndProc.running = true;
            } else {
                toggleProc.running = true;
            }
        }
    }

    Process {
        id: notifProc
        command: ["swaync-client", "-swb"]
        running: true

        stdout: SplitParser {
            onRead: function(data) {
                try {
                    let json = JSON.parse(data);
                    let alt = json.alt || "none";

                    switch (alt) {
                        case "notification":
                        case "inhibited-notification":
                            notifIcon = "\u{f009a}";
                            break;
                        case "dnd-notification":
                        case "dnd-inhibited-notification":
                            notifIcon = "\u{f009b}";
                            break;
                        case "dnd-none":
                        case "dnd-inhibited-none":
                            notifIcon = "\u{f0a91}";
                            break;
                        case "none":
                        case "inhibited-none":
                        default:
                            notifIcon = "\u{f009c}";
                            break;
                    }
                } catch (e) {}
            }
        }
    }

    Process {
        id: toggleProc
        command: ["swaync-client", "-t", "-sw"]
        running: false
    }

    Process {
        id: dndProc
        command: ["swaync-client", "-d", "-sw"]
        running: false
    }
}
