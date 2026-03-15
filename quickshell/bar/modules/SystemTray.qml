import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import ".."

Item {
    id: root

    property var rootWindow

    Layout.alignment: Qt.AlignVCenter
    implicitWidth: hoverZone.containsMouse || innerHover ? trayRow.implicitWidth + Theme.modulePadding : Theme.modulePadding
    implicitHeight: Theme.barHeight

    property bool innerHover: false

    Behavior on implicitWidth { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }

    MouseArea {
        id: hoverZone
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
    }

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 4

        opacity: (hoverZone.containsMouse || root.innerHover) ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: trayItem
                required property SystemTrayItem modelData

                width: 18
                height: 18

                Image {
                    anchors.centerIn: parent
                    source: trayItem.modelData.icon
                    width: 16
                    height: 16
                    smooth: true
                    fillMode: Image.PreserveAspectFit
                }

                opacity: itemMouse.containsMouse ? 0.6 : 1.0
                Behavior on opacity { NumberAnimation { duration: 80 } }

                QsMenuAnchor {
                    id: menuAnchor
                    menu: trayItem.modelData.menu
                    anchor.window: root.rootWindow
                    anchor.rect: Qt.rect(
                        trayItem.mapToItem(null, 0, 0).x,
                        trayItem.mapToItem(null, 0, 0).y,
                        trayItem.width,
                        trayItem.height
                    )
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onContainsMouseChanged: root.innerHover = containsMouse

                    onClicked: function(mouse) {
                        if (mouse.button === Qt.RightButton && trayItem.modelData.hasMenu) {
                            menuAnchor.open();
                        } else if (mouse.button === Qt.MiddleButton) {
                            trayItem.modelData.secondaryActivate();
                        } else if (mouse.button === Qt.LeftButton) {
                            trayItem.modelData.activate();
                        }
                    }
                }
            }
        }
    }
}
