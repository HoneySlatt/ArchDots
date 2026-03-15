pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int percentage: 0
    property bool blinkState: false

    readonly property var _blinkTimer: Timer {
        interval: 500
        running: root.percentage >= 95
        repeat: true
        onTriggered: root.blinkState = !root.blinkState
        onRunningChanged: if (!running) root.blinkState = false
    }

    readonly property var _proc: Process {
        command: ["cat", "/proc/meminfo"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.split("\n");
                let memTotal = 0;
                let memAvailable = 0;

                for (let i = 0; i < lines.length; i++) {
                    if (lines[i].startsWith("MemTotal:")) {
                        memTotal = parseInt(lines[i].split(/\s+/)[1]);
                    } else if (lines[i].startsWith("MemAvailable:")) {
                        memAvailable = parseInt(lines[i].split(/\s+/)[1]);
                    }
                }

                if (memTotal > 0) {
                    root.percentage = Math.round((memTotal - memAvailable) / memTotal * 100);
                }
            }
        }
    }

    readonly property var _pollTimer: Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._proc.running = true
    }
}
