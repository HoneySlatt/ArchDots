pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string icon: "\uf17c"
    property string wmName: "Unknown"

    readonly property var _distroProc: Process {
        command: ["bash", "-c", "grep -m1 '^ID=' /etc/os-release | cut -d= -f2 | tr -d '\"'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const id = text.trim().toLowerCase()
                const icons = {
                    "arch":        "\uf303",
                    "nixos":       "\u{f1105}",
                    "ubuntu":      "\uf31b",
                    "debian":      "\uf306",
                    "fedora":      "\uf30a",
                    "manjaro":     "\uf312",
                    "opensuse":    "\uf314",
                    "gentoo":      "\uf30d",
                    "void":        "\uf32f",
                    "alpine":      "\uf300",
                    "artix":       "\uf31f",
                    "endeavouros": "\uf322",
                    "garuda":      "\uf337",
                    "mint":        "\uf30f",
                    "pop":         "\uf32a",
                    "zorin":       "\uf33f",
                }
                root.icon = icons[id] ?? "\uf17c"
            }
        }
    }

    readonly property var _wmProc: Process {
        command: ["bash", "-c", "echo ${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-Unknown}}"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const name = text.trim()
                root.wmName = name.length > 0 ? name : "Unknown"
            }
        }
    }
}
