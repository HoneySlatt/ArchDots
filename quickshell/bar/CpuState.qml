pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int usage: 0
    property bool blinkState: false
    property var prevIdle: 0
    property var prevTotal: 0

    readonly property var _blinkTimer: Timer {
        interval: 500
        running: root.usage >= 95
        repeat: true
        onTriggered: root.blinkState = !root.blinkState
        onRunningChanged: if (!running) root.blinkState = false
    }

    readonly property var _proc: Process {
        command: ["cat", "/proc/stat"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.split("\n");
                let parts = lines[0].split(/\s+/);
                let idle = parseInt(parts[4]) + parseInt(parts[5]);
                let total = 0;
                for (let i = 1; i < parts.length && i <= 8; i++) {
                    total += parseInt(parts[i]);
                }

                if (root.prevTotal > 0) {
                    let diffIdle = idle - root.prevIdle;
                    let diffTotal = total - root.prevTotal;
                    if (diffTotal > 0) {
                        root.usage = Math.round((1 - diffIdle / diffTotal) * 100);
                    }
                }

                root.prevIdle = idle;
                root.prevTotal = total;
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
