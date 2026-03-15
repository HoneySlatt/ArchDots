pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int volume: 0
    property bool muted: false

    function volUp() { root._volUpProc.running = true; }
    function volDown() { root._volDownProc.running = true; }
    function toggleMute() { root._muteProc.running = true; }
    function setVolume(percent) {
        root._setVolProc.command = ["wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", (Math.max(0, Math.min(100, percent)) / 100).toFixed(2)];
        root._setVolProc.running = true;
    }

    readonly property var _volumeProc: Process {
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                let line = this.text.trim();
                root.muted = line.indexOf("[MUTED]") !== -1;
                let match = line.match(/Volume:\s+([\d.]+)/);
                if (match) {
                    root.volume = Math.round(parseFloat(match[1]) * 100);
                }
            }
        }
    }

    readonly property var _volUpProc: Process {
        command: ["wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", "5%+"]
        running: false
        onExited: root._volumeProc.running = true
    }

    readonly property var _volDownProc: Process {
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]
        running: false
        onExited: root._volumeProc.running = true
    }

    readonly property var _muteProc: Process {
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        running: false
        onExited: root._volumeProc.running = true
    }

    readonly property var _setVolProc: Process {
        running: false
        onExited: root._volumeProc.running = true
    }

    readonly property var _subscribeProc: Process {
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("sink") && data.includes("'change'"))
                    root._volumeProc.running = true
            }
        }
    }

    // Initial fetch + fallback poll (in case pactl subscribe dies)
    readonly property var _pollTimer: Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._volumeProc.running = true
    }
}
