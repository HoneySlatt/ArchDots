pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // Current connection state
    property string netType: "offline"
    property int signalStrength: 0
    property string connectionName: ""

    // Available networks list
    property var availableNetworks: []
    property bool scanning: false
    property bool connecting: false

    // ── Current connection polling ──

    readonly property var _netProc: Process {
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.trim().split("\n");
                let found = false;

                for (let i = 0; i < lines.length; i++) {
                    let parts = lines[i].split(":");
                    if (parts.length >= 3 && parts[1] === "connected") {
                        if (parts[0] === "wifi") {
                            root.netType = "wifi";
                            root.connectionName = parts[2];
                            found = true;
                            root._signalProc.running = true;
                            break;
                        } else if (parts[0] === "ethernet") {
                            root.netType = "ethernet";
                            root.connectionName = parts[2];
                            found = true;
                            break;
                        }
                    }
                }

                if (!found) {
                    root.netType = "offline";
                    root.connectionName = "";
                    root.signalStrength = 0;
                }
            }
        }
    }

    readonly property var _signalProc: Process {
        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL", "dev", "wifi", "list"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.trim().split("\n");
                let active = lines.find(l => l.startsWith("*:"));
                if (active) {
                    let val = parseInt(active.split(":")[1]);
                    if (!isNaN(val)) root.signalStrength = val;
                }
            }
        }
    }

    readonly property var _pollTimer: Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._netProc.running = true
    }

    // ── Network scanning ──

    function _parseNetworks(text) {
        let lines = text.trim().split("\n");
        let networks = {};

        for (let i = 0; i < lines.length; i++) {
            let parts = lines[i].split(":");
            if (parts.length < 4) continue;

            let inUse = parts[0] === "*";
            let signal = parseInt(parts[1]);
            let security = parts[2];
            // SSID is last field, rejoin in case it contains colons
            let ssid = parts.slice(3).join(":").replace(/\\:/g, ":");

            if (!ssid || ssid === "--") continue;

            // Deduplicate by SSID, keep strongest signal
            if (!networks[ssid] || signal > networks[ssid].signal) {
                networks[ssid] = {
                    ssid: ssid,
                    signal: signal,
                    security: security,
                    connected: inUse
                };
            }
        }

        return Object.values(networks)
            .sort((a, b) => b.signal - a.signal)
            .slice(0, 8);
    }

    // Fast cached scan (instant results)
    readonly property var _cachedScanProc: Process {
        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SECURITY,SSID", "dev", "wifi", "list", "--rescan", "no"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.availableNetworks = root._parseNetworks(this.text);
                // Then trigger a real rescan to update the list
                root._scanProc.running = true;
            }
        }
    }

    // Full rescan (slower, updates list after)
    readonly property var _scanProc: Process {
        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SECURITY,SSID", "dev", "wifi", "list", "--rescan", "yes"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.scanning = false;
                root.availableNetworks = root._parseNetworks(this.text);
            }
        }
    }

    // ── Connect / Disconnect ──

    readonly property var _connectProc: Process {
        command: ["true"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.connecting = false;
                root._refreshTimer.start();
            }
        }
    }

    readonly property var _disconnectProc: Process {
        command: ["true"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root._refreshTimer.start();
            }
        }
    }

    // Delay refresh to let NetworkManager stabilize
    readonly property var _refreshTimer: Timer {
        interval: 1500
        repeat: false
        onTriggered: {
            root._netProc.running = true;
            root.scan();
        }
    }

    // ── Public API ──

    function scan() {
        root.scanning = true;
        root._cachedScanProc.running = true;
    }

    function connectToNetwork(ssid: string, password: string) {
        root.connecting = true;
        if (password) {
            root._connectProc.command = ["nmcli", "dev", "wifi", "connect", ssid, "password", password];
        } else {
            root._connectProc.command = ["nmcli", "dev", "wifi", "connect", ssid];
        }
        root._connectProc.running = true;
    }

    function disconnectNetwork() {
        if (root.connectionName) {
            root._disconnectProc.command = ["nmcli", "con", "down", root.connectionName];
            root._disconnectProc.running = true;
        }
    }
}
