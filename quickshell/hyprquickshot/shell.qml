import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import QtCore

import "src"
import "."

FreezeScreen {
    id: root
    visible: false

    property var activeScreen: null
    property bool recordMode: false

    Connections {
        target: Hyprland
        enabled: activeScreen === null

        function onFocusedMonitorChanged() {
            const monitor = Hyprland.focusedMonitor
            if(!monitor) return

            for (const screen of Quickshell.screens) {
                if (screen.name === monitor.name) {
                    activeScreen = screen

                    const timestamp = Date.now()
                    const path = Quickshell.cachePath(`screenshot-${timestamp}.png`)
                    tempPath = path
                    Quickshell.execDetached(["grim", "-g", `${screen.x},${screen.y} ${screen.width}x${screen.height}`, path])
                    showTimer.start()
                }
            }
        }
    }

    targetScreen: activeScreen

    property var hyprlandMonitor: Hyprland.focusedMonitor
    property string tempPath

    property string mode: "region"

    Shortcut {
        sequence: "Escape"
        onActivated: () => {
            Quickshell.execDetached(["rm", tempPath])
            Qt.quit()
        }
    }

    Timer {
        id: showTimer
        interval: 50
        running: false
        repeat: false
        onTriggered: root.visible = true
    }

    Process {
        id: screenshotProcess
        running: false

        onExited: () => {
            Qt.quit()
        }

        stdout: StdioCollector {
            onStreamFinished: console.log(this.text)
        }
        stderr: StdioCollector {
            onStreamFinished: console.log(this.text)
        }
    }

    function processScreenshot(x, y, width, height) {
        const scale = hyprlandMonitor.scale
        const scaledX = Math.round(x * scale)
        const scaledY = Math.round(y * scale)
        const scaledWidth = Math.round(width * scale)
        const scaledHeight = Math.round(height * scale)

        const picturesDir = Quickshell.env("HQS_DIR") || Quickshell.env("XDG_SCREENSHOTS_DIR") || Quickshell.env("XDG_PICTURES_DIR") || (Quickshell.env("HOME") + "/Pictures")

        const now = new Date()
        const timestamp = Qt.formatDateTime(now, "yyyy-MM-dd_hh-mm-ss")
        const outputPath = `${picturesDir}/Screenshots/Screenshot_${timestamp}.png`

        screenshotProcess.command = ["sh", "-c",
            `mkdir -p "$(dirname "${outputPath}")" && ` +
            `magick "${tempPath}" -crop ${scaledWidth}x${scaledHeight}+${scaledX}+${scaledY} "${outputPath}" && ` +
            `wl-copy < "${outputPath}" && ` +
            `rm "${tempPath}"`
        ]

        screenshotProcess.running = true
        root.visible = false
    }

    function processRecording(x, y, width, height) {
        const videosDir = Quickshell.env("XDG_VIDEOS_DIR") || (Quickshell.env("HOME") + "/Videos")
        const now = new Date()
        const timestamp = Qt.formatDateTime(now, "yyyy-MM-dd_hh-mm-ss")
        const outputPath = `${videosDir}/Screencasts/Screencast_${timestamp}.mp4`

        const screenX = activeScreen ? activeScreen.x : 0
        const screenY = activeScreen ? activeScreen.y : 0

        const baseCmd = `AUDIO=$(pactl get-default-sink).monitor; mkdir -p "$(dirname '${outputPath}')" && `
        const wfFlags = `--audio="$AUDIO" -c libx264rgb -x bgr0 -p crf=15 -p preset=ultrafast`
        const cmd = mode === "screen"
            ? ["sh", "-c", baseCmd + `wf-recorder -o '${hyprlandMonitor.name}' ${wfFlags} -f '${outputPath}'`]
            : ["sh", "-c", baseCmd + `wf-recorder -g '${screenX + x},${screenY + y} ${width}x${height}' ${wfFlags} -f '${outputPath}'`]

        Quickshell.execDetached(["rm", "-f", tempPath])
        Quickshell.execDetached(cmd)
        root.visible = false
        Qt.quit()
    }

    RegionSelector {
        visible: mode === "region"
        id: regionSelector
        anchors.fill: parent

        dimOpacity: 0.6
        borderRadius: 10.0
        outlineThickness: 2.0

        onRegionSelected: (x, y, width, height) => {
            if (root.recordMode)
                processRecording(x, y, width, height)
            else
                processScreenshot(x, y, width, height)
        }
    }

    WindowSelector {
        visible: mode === "window"
        id: windowSelector
        anchors.fill: parent

        monitor: root.hyprlandMonitor
        dimOpacity: 0.6
        borderRadius: 10.0
        outlineThickness: 2.0

        onRegionSelected: (x, y, width, height) => {
            if (root.recordMode)
                processRecording(x, y, width, height)
            else
                processScreenshot(x, y, width, height)
        }
    }

    WrapperRectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40

        color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.85)
        radius: 12
        margin: 8

        Row {
            id: settingRow
            spacing: 25

            Row {
                id: buttonRow
                spacing: 8

                Repeater {
                    model: [
                        { mode: "region", icon: "region" },
                        { mode: "window", icon: "window" },
                        { mode: "screen", icon: "screen" }
                    ]

                    Button {
                        id: modeButton
                        implicitWidth: 48
                        implicitHeight: 48

                        background: Rectangle {
                            radius: 8
                            color: {
                                if (mode === modelData.mode) return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.45)
                                if (modeButton.hovered) return Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.7)
                                return Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.4)
                            }

                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        contentItem: Item {
                            anchors.fill: parent

                            Image {
                                anchors.centerIn: parent
                                width: 24
                                height: 24
                                source: Quickshell.shellPath(`icons/${modelData.icon}.svg`)
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        onClicked: {
                            root.mode = modelData.mode
                            if (modelData.mode === "screen") {
                                if (root.recordMode)
                                    processRecording(0, 0, root.targetScreen.width, root.targetScreen.height)
                                else
                                    processScreenshot(0, 0, root.targetScreen.width, root.targetScreen.height)
                            }
                        }
                    }
                }
            }

            Row {
                id: switchRow
                spacing: 8
                anchors.verticalCenter: buttonRow.verticalCenter

                Text {
                    text: "Record Screen"
                    color: root.recordMode ? Theme.warning : Theme.text
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Switch {
                    id: recordSwitch
                    checked: root.recordMode
                    onCheckedChanged: root.recordMode = checked

                    indicator: Rectangle {
                        width: 40
                        height: 22
                        radius: 11
                        color: recordSwitch.checked
                            ? Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.8)
                            : Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.8)
                        anchors.verticalCenter: parent.verticalCenter

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            x: recordSwitch.checked ? parent.width - width - 3 : 3
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16
                            height: 16
                            radius: 8
                            color: Theme.text

                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                        }
                    }
                }
            }
        }
    }
}
