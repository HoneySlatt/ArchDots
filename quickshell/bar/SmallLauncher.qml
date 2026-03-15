import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: launcherScope

    Variants {
        model: SmallLauncherState.visible ? Quickshell.screens : []

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: SmallLauncherState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            color: "transparent"

            WlrLayershell.namespace: "quickshell:launcher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Connections {
                target: SmallLauncherState
                function onVisibleChanged() {
                    if (SmallLauncherState.visible) {
                        searchField.text = "";
                        selectedIndex = 0;
                        rebuildList();
                    }
                }
            }

            property string searchQuery: ""
            property int selectedIndex: 0
            property var sortedApps: []
            property var filteredApps: []

            // Build sorted list from the source Repeater
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

            // Filter the sorted list based on search query
            function filterList() {
                if (searchQuery.length === 0) {
                    filteredApps = sortedApps;
                } else {
                    filteredApps = sortedApps.filter(app =>
                        app.name?.toLowerCase().indexOf(searchQuery) !== -1
                    );
                }
                selectedIndex = 0;
                listView.contentY = 0;
            }

            onSearchQueryChanged: filterList()

            onSelectedIndexChanged: {
                listView.positionViewAtIndex(selectedIndex, ListView.Contain);
            }

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

            // Close launcher when clicking outside the panel
            MouseArea {
                anchors.fill: parent
                onClicked: SmallLauncherState.close()
            }

            // Centered launcher panel
            Rectangle {
                id: panel
                width: 800
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                height: searchBar.height + listContainer.height + 20 + 10 + 10
                radius: 15
                color: Theme.background
                visible: SmallLauncherState.visible
                focus: SmallLauncherState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        SmallLauncherState.close();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (root.filteredApps.length > 0 && root.selectedIndex >= 0 && root.selectedIndex < root.filteredApps.length) {
                            root.filteredApps[root.selectedIndex].execute();
                            SmallLauncherState.close();
                        }
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Down) {
                        if (root.selectedIndex < root.filteredApps.length - 1)
                            root.selectedIndex++;
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Up) {
                        if (root.selectedIndex > 0)
                            root.selectedIndex--;
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Backspace) {
                        searchField.text = searchField.text.slice(0, -1);
                        event.accepted = true;
                        return;
                    }
                    if (event.text.length > 0 && !event.modifiers) {
                        searchField.text += event.text;
                        event.accepted = true;
                    }
                }

                // Search bar
                Rectangle {
                    id: searchBar
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    height: 40
                    radius: 10
                    color: Theme.separator

                    TextInput {
                        id: searchField
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pointSize: 13
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

                // List container
                Rectangle {
                    id: listContainer
                    anchors.top: searchBar.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    height: Math.min(root.filteredApps.length, 5) * (36 + 5) + 20
                    radius: 15
                    color: "transparent"

                    ListView {
                        id: listView
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        spacing: 5
                        model: root.filteredApps
                        currentIndex: root.selectedIndex
                        highlightFollowsCurrentItem: false
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: Rectangle {
                            id: delegateRect
                            required property var modelData
                            required property int index
                            width: listView.width
                            height: 36
                            radius: 6
                            color: index === root.selectedIndex ? Theme.highlight : "transparent"

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 6
                                anchors.rightMargin: 6
                                spacing: 10

                                Image {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 24
                                    height: 24
                                    source: Quickshell.iconPath(
                                        delegateRect.modelData.icon ?? "application-x-executable",
                                        "application-x-executable"
                                    )
                                    sourceSize: Qt.size(24, 24)
                                    smooth: true
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: delegateRect.modelData.name ?? ""
                                    color: delegateRect.index === root.selectedIndex
                                        ? Theme.background : Theme.text
                                    font.family: Theme.fontFamily
                                    font.pointSize: 13
                                    elide: Text.ElideRight
                                    width: parent.width - 24 - 10 - 12
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    delegateRect.modelData.execute();
                                    SmallLauncherState.close();
                                }
                                onEntered: root.selectedIndex = delegateRect.index
                            }
                        }
                    }
                }
            }
        }
    }
}
