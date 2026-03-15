import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: launcherScope

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: LauncherState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            color: "transparent"

            WlrLayershell.namespace: "quickshell:applauncher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                property bool canBeActive: root.monitorIsFocused
                active: false
                onCleared: () => {
                    if (!active)
                        LauncherState.close();
                }
            }

            Connections {
                target: LauncherState
                function onVisibleChanged() {
                    if (LauncherState.visible) {
                        delayedGrabTimer.start();
                        searchField.text = "";
                        selectedIndex = 0;
                        rebuildList();
                    } else {
                        delayedGrabTimer.stop();
                        grab.active = false;
                    }
                }
            }

            Timer {
                id: delayedGrabTimer
                interval: 50
                repeat: false
                onTriggered: {
                    if (!grab.canBeActive)
                        return;
                    grab.active = LauncherState.visible;
                }
            }

            property string searchQuery: ""
            property int selectedIndex: 0
            property var sortedApps: []
            property var filteredApps: []
            property int columns: 2

            onSelectedIndexChanged: {
                const item = appGrid.itemAt(root.selectedIndex)
                if (!item) return
                const itemTop = item.y
                const itemBottom = itemTop + item.height
                if (itemTop < flickable.contentY)
                    flickable.contentY = Math.max(0, itemTop - 10)
                else if (itemBottom > flickable.contentY + flickable.height)
                    flickable.contentY = itemBottom - flickable.height + 10
            }

            function rebuildList() {
                let apps = [];
                for (let i = 0; i < sourceRepeater.count; i++) {
                    let item = sourceRepeater.itemAt(i);
                    if (item) apps.push(item.modelData);
                }
                apps.sort((a, b) => (a.name ?? "").localeCompare(b.name ?? ""));
                sortedApps = apps;
                filterList();
            }

            function filterList() {
                if (searchQuery.length === 0) {
                    filteredApps = sortedApps;
                } else {
                    filteredApps = sortedApps.filter(app =>
                        app.name?.toLowerCase().indexOf(searchQuery) !== -1
                    );
                }
                selectedIndex = 0;
            }

            onSearchQueryChanged: filterList()

            // Hidden repeater to enumerate DesktopEntries
            Item {
                visible: false
                Repeater {
                    id: sourceRepeater
                    model: DesktopEntries.applications
                    Item { required property var modelData }
                    Component.onCompleted: root.rebuildList()
                    onCountChanged: root.rebuildList()
                }
            }

            // Close on outside click
            MouseArea {
                anchors.fill: parent
                onClicked: LauncherState.close()
            }

            // Dropdown panel from top-left (below DistroIcon)
            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: Theme.margin
                width: 340
                height: contentArea.implicitHeight + 24
                radius: Theme.borderRadius
                color: Theme.background
                border.color: Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.4)
                border.width: 1

                MouseArea { anchors.fill: parent }

                Item {
                    id: contentArea
                    anchors.fill: parent
                    anchors.margins: 12
                    implicitHeight: searchBar.height + 12 + flickable.height
                    focus: LauncherState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        LauncherState.close();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (root.filteredApps.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.filteredApps.length) {
                            root.filteredApps[root.selectedIndex].execute();
                            LauncherState.close();
                        }
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Down) {
                        root.selectedIndex = Math.min(root.selectedIndex + root.columns, root.filteredApps.length - 1)
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Up) {
                        root.selectedIndex = Math.max(root.selectedIndex - root.columns, 0)
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Right) {
                        root.selectedIndex = Math.min(root.selectedIndex + 1, root.filteredApps.length - 1)
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Left) {
                        root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Backspace) {
                        searchField.text = searchField.text.slice(0, -1);
                        event.accepted = true;
                        return;
                    }
                    // Forward printable characters to search field
                    if (event.text.length > 0 && !event.modifiers) {
                        searchField.text += event.text;
                        event.accepted = true;
                    }
                }

                // Search bar
                Rectangle {
                    id: searchBar
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 44
                    radius: 10
                    color: Theme.separator

                    TextInput {
                        id: searchField
                        anchors.fill: parent
                        anchors.leftMargin: 24
                        anchors.rightMargin: 24
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pointSize: 12
                        clip: true

                        onTextChanged: {
                            root.searchQuery = text.toLowerCase();
                        }

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: "> Search..."
                            color: Theme.text
                            opacity: 0.4
                            font: searchField.font
                            visible: searchField.text.length === 0
                        }
                    }
                }

                // App grid
                Flickable {
                    id: flickable
                    anchors.top: searchBar.bottom
                    anchors.topMargin: 12
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Math.min(flow.height, 700)
                    clip: true
                    contentHeight: flow.height
                    contentWidth: width
                    interactive: false

                    MouseArea {
                        anchors.fill: parent
                        propagateComposedEvents: true
                        onWheel: event => {
                            flickable.contentY = Math.max(0, Math.min(
                                flickable.contentY - event.angleDelta.y * 0.2,
                                flickable.contentHeight - flickable.height
                            ))
                        }
                        onClicked: mouse => mouse.accepted = false
                        onPressed: mouse => mouse.accepted = false
                        onReleased: mouse => mouse.accepted = false
                    }

                    Flow {
                        id: flow
                        width: parent.width
                        spacing: 15

                        Repeater {
                            id: appGrid
                            model: root.filteredApps

                            delegate: Item {
                                id: delegateRoot
                                width: (flickable.width - 15) / 2
                                height: 64

                                required property var modelData
                                required property int index

                                function launchApp() {
                                    modelData.execute();
                                    LauncherState.close();
                                }

                                property bool isSelected: index === root.selectedIndex
                                property bool isHovered: delegateMouseArea.containsMouse

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 30
                                    color: delegateRoot.isSelected || delegateRoot.isHovered
                                        ? Theme.separator : Theme.background


                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 10

                                        Item {
                                            width: 36
                                            height: 36
                                            anchors.verticalCenter: parent.verticalCenter

                                            Image {
                                                id: appIcon
                                                anchors.fill: parent
                                                source: Quickshell.iconPath(
                                                    delegateRoot.modelData.icon ?? "",
                                                    "application-x-executable"
                                                )
                                                sourceSize: Qt.size(36, 36)
                                                smooth: true
                                                visible: status === Image.Ready
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                visible: appIcon.status !== Image.Ready
                                                text: "\uf17a"
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 20
                                                color: Theme.accent
                                            }
                                        }

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: delegateRoot.modelData.name ?? ""
                                            color: Theme.text
                                            font.family: Theme.fontFamily
                                            font.pointSize: 11
                                            width: parent.width - 36 - 10
                                            elide: Text.ElideRight
                                        }
                                    }
                                }

                                MouseArea {
                                    id: delegateMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: delegateRoot.launchApp()
                                }
                            }
                        }
                    }
                }
                } // Item contentArea
            } // Rectangle panel
        }
    }
}
