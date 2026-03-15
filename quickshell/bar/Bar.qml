import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import Quickshell.Hyprland
import "modules" as Modules

PanelWindow {
    id: bar

    property bool isTop: true

    // Hide bar when launcher is open on this monitor
    readonly property HyprlandMonitor barMonitor: Hyprland.monitorFor(bar.screen)
    property bool powerMenuOnThisScreen: PowerMenuState.visible && (Hyprland.focusedMonitor?.id === barMonitor?.id)
    visible: !powerMenuOnThisScreen


    anchors {
        top: isTop
        bottom: !isTop
        left: true
        right: true
    }

    margins {
        top: isTop ? Theme.margin : 0
        bottom: 0
        left: isTop ? Theme.margin : 0
        right: isTop ? Theme.margin : 0
    }

    implicitHeight: Theme.barHeight
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: isTop ? Theme.barHeight + Theme.margin : Theme.barHeight - 1

    // Rounded background container
    Rectangle {
        id: barBackground
        anchors.fill: parent
        color: Theme.background
        radius: isTop ? Theme.borderRadius : 0
        clip: true

        // Clock anchored to absolute center
        Modules.Clock {
            anchors.centerIn: parent
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // === LEFT SECTION ===
            RowLayout {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                spacing: 0

                Modules.DistroIcon {}
                Modules.Workspaces {}
                Item { implicitWidth: 8 }
                Modules.CpuUsage {}
                Modules.GpuUsage {}
                Modules.RamUsage {}
            }

            Item { Layout.fillWidth: true }

            // === RIGHT SECTION ===
            RowLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                spacing: 0

                Modules.SystemTray { rootWindow: bar }
                Modules.Volume {}
                Modules.NetworkInfo {}
                Text {
                    text: "|"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.fontWeight
                    Layout.alignment: Qt.AlignVCenter
                }
                Modules.Notifications {}
                Modules.PowerButton {}
            }
        }
    }
}
