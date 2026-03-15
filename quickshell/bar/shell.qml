//@ pragma UseQApplication
//@ pragma IconTheme Papirus

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "modules" as Modules

ShellRoot {
    Loader {
        active: LauncherState.visible
        source: "AppLauncher.qml"
    }
    Loader {
        active: PowerMenuState.visible
        source: "PowerMenu.qml"
    }
    Loader {
        active: PowerLauncherState.visible
        source: "PowerLauncher.qml"
    }
    Loader {
        active: SmallLauncherState.visible
        source: "SmallLauncher.qml"
    }
    Loader {
        active: VolumePopupState.visible
        source: "VolumePopup.qml"
    }
    Loader {
        active: NetworkPopupState.visible
        source: "NetworkPopup.qml"
    }
    Loader {
        active: CalendarPopupState.visible
        source: "CalendarPopup.qml"
    }

    Variants {
        id: barVariants
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }

    IpcHandler {
        target: "toggleLauncher"

        function call() {
            SmallLauncherState.toggle();
        }
    }

    IpcHandler {
        target: "togglePosition"

        function call() {
            for (let i = 0; i < barVariants.instances.length; i++) {
                let bar = barVariants.instances[i];
                if (Hyprland.monitorFor(bar.screen)?.id === Hyprland.focusedMonitor?.id) {
                    bar.isTop = !bar.isTop;
                }
            }
        }
    }

    IpcHandler {
        target: "togglePowerMenu"

        function call() {
            PowerMenuState.toggle();
        }
    }

    IpcHandler {
        target: "toggleVisibility"

        function call() {
            for (let i = 0; i < barVariants.instances.length; i++) {
                let bar = barVariants.instances[i];
                if (Hyprland.monitorFor(bar.screen)?.id === Hyprland.focusedMonitor?.id) {
                    bar.visible = !bar.visible;
                }
            }
        }
    }
}
