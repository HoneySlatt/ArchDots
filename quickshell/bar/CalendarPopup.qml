import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris

Item {
    id: calendarPopup

    // ── Helper: format seconds to mm:ss ──
    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) return "0:00";
        let m = Math.floor(seconds / 60);
        let s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    // ── MPRIS player reference ──
    readonly property MprisPlayer player: Mpris.players.values.length > 0
        ? Mpris.players.values[0] : null

    // ── Wallpaper state ──
    property var wallpaperList: []
    property int wallpaperPage: 0
    readonly property int wallpapersPerPage: 12 // 4x3 grid
    readonly property int wallpaperTotalPages: Math.max(1, Math.ceil(wallpaperList.length / wallpapersPerPage))
    property string selectedWallpaper: ""

    readonly property var _wallpaperScanProc: Process {
        command: ["find", Theme.wallpaperDir, "-type", "f",
                  "(", "-iname", "*.jpg", "-o", "-iname", "*.png", "-o",
                  "-iname", "*.jpeg", "-o", "-iname", "*.webp", ")", "-printf", "%f\n"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let files = this.text.trim().split("\n").filter(f => f.length > 0).sort();
                calendarPopup.wallpaperList = files;
            }
        }
    }

    readonly property var _wallpaperApplyProc: Process {
        property string wallpaperPath: ""
        command: ["awww", "img", wallpaperPath, "--transition-type", "wave", "--transition-duration", "2"]
        running: false
    }

    function applyWallpaper(filename) {
        selectedWallpaper = filename;
        _wallpaperApplyProc.wallpaperPath = Theme.wallpaperDir + "/" + filename;
        _wallpaperApplyProc.running = true;
    }

    // Rescan wallpapers when theme changes
    Connections {
        target: Theme
        function onCurrentThemeChanged() {
            calendarPopup.wallpaperList = [];
            calendarPopup.wallpaperPage = 0;
            calendarPopup.selectedWallpaper = "";
            calendarPopup._wallpaperScanProc.running = true;
        }
    }

    // Scan wallpapers when popup opens on Wallpapers tab
    Connections {
        target: CalendarPopupState
        function onVisibleChanged() {
            if (CalendarPopupState.visible && calendarPopup.wallpaperList.length === 0) {
                calendarPopup._wallpaperScanProc.running = true;
            }
        }
    }

    // ── Uptime state ──
    property string uptimeText: ""

    readonly property var _uptimeProc: Process {
        command: ["uptime", "-p"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let raw = this.text.trim().replace("up ", "");
                calendarPopup.uptimeText = raw;
            }
        }
    }

    readonly property var _uptimeTimer: Timer {
        interval: 60000
        running: CalendarPopupState.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: calendarPopup._uptimeProc.running = true
    }

    // ── Position polling for media ──
    property real currentPosition: player ? player.position : 0

    readonly property var _posTimer: Timer {
        interval: 1000
        running: CalendarPopupState.visible && calendarPopup.player !== null
            && calendarPopup.player.playbackState === MprisPlaybackState.Playing
        repeat: true
        onTriggered: {
            if (calendarPopup.player)
                calendarPopup.currentPosition = calendarPopup.player.position;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: CalendarPopupState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            color: "transparent"

            WlrLayershell.namespace: "quickshell:calendarpopup"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            // ── Focus grab ──
            HyprlandFocusGrab {
                id: grab
                windows: [root]
                active: false
                onCleared: () => {
                    if (!active)
                        CalendarPopupState.close();
                }
            }

            Connections {
                target: CalendarPopupState
                function onVisibleChanged() {
                    if (CalendarPopupState.visible) {
                        grabTimer.start();
                    } else {
                        grabTimer.stop();
                        grab.active = false;
                    }
                }
            }

            Timer {
                id: grabTimer
                interval: 50
                repeat: false
                onTriggered: grab.active = CalendarPopupState.visible
            }

            // Click outside to close
            MouseArea {
                anchors.fill: parent
                onClicked: CalendarPopupState.close()
            }

            // ── Keyboard ──
            FocusScope {
                anchors.fill: parent
                focus: CalendarPopupState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        CalendarPopupState.close();
                        event.accepted = true;
                    }
                }

                // ── Main popup panel ──
                Rectangle {
                    id: popup
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    width: 880
                    height: 520
                    color: Theme.background
                    radius: 16
                    border.color: Theme.separator
                    border.width: 1

                    // Block clicks inside
                    MouseArea { anchors.fill: parent }

                    Column {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        // ── Tab header ──
                        Row {
                            id: tabBar
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 32

                            Repeater {
                                model: [
                                    { label: "\u{f009}  Dashboard", idx: 0 },
                                    { label: "\u{f001}  Media",    idx: 1 },
                                    { label: "\u{f03e}  Wallpapers", idx: 2 },
                                    { label: "\u{f1fc}  Themes", idx: 3 }
                                ]

                                delegate: Item {
                                    required property var modelData
                                    width: tabLabel.implicitWidth + 16
                                    height: tabLabel.implicitHeight + 12

                                    Text {
                                        id: tabLabel
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        color: CalendarPopupState.activeTab === modelData.idx
                                            ? Theme.text : Theme.caution
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize + 2
                                        font.weight: Font.Bold
                                    }

                                    // Underline for active tab
                                    Rectangle {
                                        visible: CalendarPopupState.activeTab === modelData.idx
                                        anchors.bottom: parent.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: parent.width - 8
                                        height: 2
                                        color: Theme.text
                                        radius: 1
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: CalendarPopupState.activeTab = modelData.idx
                                    }
                                }
                            }
                        }

                        // Separator
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.separator
                        }

                        // ── Tab content ──
                        Item {
                            id: tabContent
                            width: parent.width
                            height: parent.height - tabBar.height - 25

                            // ════════════════════════════
                            // ══ OVERVIEW TAB ════════════
                            // ════════════════════════════
                            Loader {
                                active: CalendarPopupState.activeTab === 0
                                anchors.fill: parent
                                sourceComponent: RowLayout {
                                anchors.fill: parent
                                spacing: 12

                                // ── Left column: Clock + Volume ──
                                Column {
                                    Layout.preferredWidth: 140
                                    Layout.fillHeight: true
                                    spacing: 10

                                    // Clock module
                                    Rectangle {
                                        width: parent.width
                                        height: parent.height * 0.45 - 5
                                        color: Theme.separator
                                        radius: 12

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: Qt.formatDateTime(new Date(), "HH")
                                                color: Theme.text
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 52
                                                font.weight: Font.Bold
                                            }

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: Qt.formatDateTime(new Date(), "mm")
                                                color: Theme.text
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 52
                                                font.weight: Font.Bold
                                            }

                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: Qt.formatDateTime(new Date(), "MMM dd")
                                                color: Theme.caution
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize
                                                font.weight: Theme.fontWeight
                                            }
                                        }

                                        Timer {
                                            interval: 60000
                                            running: CalendarPopupState.visible && CalendarPopupState.activeTab === 0
                                            repeat: true
                                        }
                                    }

                                    // Performance module (vertical bars)
                                    Rectangle {
                                        width: parent.width
                                        height: parent.height * 0.55 - 5
                                        color: Theme.separator
                                        radius: 12

                                        Row {
                                            anchors.fill: parent
                                            anchors.margins: 12
                                            spacing: 10

                                            // CPU bar
                                            Column {
                                                width: (parent.width - 20) / 3
                                                height: parent.height
                                                spacing: 6

                                                Item { width: 1; height: 4 }

                                                Rectangle {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    width: 8
                                                    height: parent.height - 50
                                                    radius: 4
                                                    color: Theme.caution

                                                    Rectangle {
                                                        anchors.bottom: parent.bottom
                                                        width: parent.width
                                                        height: parent.height * (CpuState.usage / 100)
                                                        radius: 4
                                                        color: CpuState.usage >= 90 ? Theme.warning : Theme.process
                                                    }
                                                }

                                                Text {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: "\uf2db"
                                                    color: Theme.text
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: Theme.fontSize
                                                }
                                            }

                                            // GPU bar
                                            Column {
                                                width: (parent.width - 20) / 3
                                                height: parent.height
                                                spacing: 6

                                                Item { width: 1; height: 4 }

                                                Rectangle {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    width: 8
                                                    height: parent.height - 50
                                                    radius: 4
                                                    color: Theme.caution

                                                    Rectangle {
                                                        anchors.bottom: parent.bottom
                                                        width: parent.width
                                                        height: parent.height * Math.min(GpuState.tempC / 100, 1)
                                                        radius: 4
                                                        color: GpuState.tempC >= 80 ? Theme.warning : Theme.misc
                                                    }
                                                }

                                                Text {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: "\uf2c8"
                                                    color: Theme.text
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: Theme.fontSize
                                                }
                                            }

                                            // RAM bar
                                            Column {
                                                width: (parent.width - 20) / 3
                                                height: parent.height
                                                spacing: 6

                                                Item { width: 1; height: 4 }

                                                Rectangle {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    width: 8
                                                    height: parent.height - 50
                                                    radius: 4
                                                    color: Theme.caution

                                                    Rectangle {
                                                        anchors.bottom: parent.bottom
                                                        width: parent.width
                                                        height: parent.height * (RamState.percentage / 100)
                                                        radius: 4
                                                        color: RamState.percentage >= 90 ? Theme.warning : Theme.text
                                                    }
                                                }

                                                Text {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: "\uefc5"
                                                    color: Theme.text
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: Theme.fontSize
                                                }
                                            }
                                        }
                                    }
                                }

                                // ── Right section: Weather/User row + Calendar/Media ──
                                Column {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 10

                                    // Top row: Weather + User info (full width)
                                    RowLayout {
                                        width: parent.width
                                        spacing: 10

                                        // Weather card
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 70
                                            color: Theme.separator
                                            radius: 12

                                            RowLayout {
                                                anchors.centerIn: parent
                                                spacing: 12

                                                Text {
                                                    text: WeatherState.icon
                                                    color: Theme.text
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: 28
                                                }

                                                Column {
                                                    Text {
                                                        text: WeatherState.temperature
                                                        color: Theme.text
                                                        font.family: Theme.fontFamily
                                                        font.pixelSize: Theme.fontSize + 6
                                                        font.weight: Font.Bold
                                                    }
                                                    Text {
                                                        text: WeatherState.description
                                                        color: Theme.caution
                                                        font.family: Theme.fontFamily
                                                        font.pixelSize: Theme.fontSize - 1
                                                        font.weight: Theme.fontWeight
                                                    }
                                                }
                                            }
                                        }

                                        // User info card
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 70
                                            color: Theme.separator
                                            radius: 12

                                            RowLayout {
                                                anchors.centerIn: parent
                                                anchors.horizontalCenterOffset: -20
                                                spacing: 18

                                                // User avatar
                                                Rectangle {
                                                    width: 54
                                                    height: 54
                                                    radius: 27
                                                    color: Theme.caution
                                                    border.color: Theme.text
                                                    border.width: 2

                                                    Canvas {
                                                        id: avatarCanvas
                                                        anchors.fill: parent
                                                        anchors.margins: 2
                                                        renderTarget: Canvas.FramebufferObject
                                                        smooth: true
                                                        property string artUrl: "file:///home/honey/Pictures/Others/Honey.png"

                                                        onImageLoaded: requestPaint()

                                                        onPaint: {
                                                            var ctx = getContext("2d");
                                                            ctx.reset();
                                                            var r = width / 2;
                                                            ctx.beginPath();
                                                            ctx.arc(r, r, r, 0, 2 * Math.PI);
                                                            ctx.clip();
                                                            if (isImageLoaded(artUrl)) {
                                                                ctx.drawImage(artUrl, 0, 0, width, height);
                                                            }
                                                        }

                                                        Component.onCompleted: loadImage(artUrl)
                                                    }
                                                }

                                                Column {
                                                    Text {
                                                        text: "Honey"
                                                        color: Theme.text
                                                        font.family: Theme.fontFamily
                                                        font.pixelSize: Theme.fontSize + 4
                                                        font.weight: Font.Bold
                                                    }
                                                    Text {
                                                        text: DistroState.icon + " on " + DistroState.wmName
                                                        color: Theme.caution
                                                        font.family: Theme.fontFamily
                                                        font.pixelSize: Theme.fontSize
                                                        font.weight: Theme.fontWeight
                                                    }
                                                    Text {
                                                        text: "\u{f0954} " + calendarPopup.uptimeText
                                                        color: Theme.caution
                                                        font.family: Theme.fontFamily
                                                        font.pixelSize: Theme.fontSize
                                                        font.weight: Theme.fontWeight
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // ── Bottom row: Calendar + Media player ──
                                    RowLayout {
                                        width: parent.width
                                        height: parent.height - 80
                                        spacing: 12

                                    // ── Calendar ──
                                    Rectangle {
                                        id: calendarRect
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: Theme.separator
                                        radius: 12

                                        property int displayMonth: new Date().getMonth()
                                        property int displayYear: new Date().getFullYear()

                                        function prevMonth() {
                                            if (displayMonth === 0) {
                                                displayMonth = 11;
                                                displayYear--;
                                            } else {
                                                displayMonth--;
                                            }
                                        }

                                        function nextMonth() {
                                            if (displayMonth === 11) {
                                                displayMonth = 0;
                                                displayYear++;
                                            } else {
                                                displayMonth++;
                                            }
                                        }

                                        // Get days for the calendar grid
                                        function calendarDays() {
                                            let days = [];
                                            let first = new Date(displayYear, displayMonth, 1);
                                            let startDay = first.getDay(); // 0=Sun
                                            let daysInMonth = new Date(displayYear, displayMonth + 1, 0).getDate();
                                            let prevMonthDays = new Date(displayYear, displayMonth, 0).getDate();

                                            // Previous month padding
                                            for (let i = startDay - 1; i >= 0; i--) {
                                                days.push({ day: prevMonthDays - i, current: false });
                                            }

                                            // Current month
                                            for (let i = 1; i <= daysInMonth; i++) {
                                                days.push({ day: i, current: true });
                                            }

                                            // Next month padding (fill to 42 = 6 rows)
                                            let remaining = 42 - days.length;
                                            for (let i = 1; i <= remaining; i++) {
                                                days.push({ day: i, current: false });
                                            }

                                            return days;
                                        }

                                        readonly property var monthNames: [
                                            "January", "February", "March", "April",
                                            "May", "June", "July", "August",
                                            "September", "October", "November", "December"
                                        ]

                                        Column {
                                            id: calendarCol
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            anchors.rightMargin: 12
                                            anchors.topMargin: 6
                                            anchors.bottomMargin: 6
                                            spacing: 2

                                            // Month navigation
                                            RowLayout {
                                                width: parent.width
                                                height: 24

                                                Text {
                                                    text: "\u{f0141}"
                                                    color: prevMa.containsMouse ? Theme.text : Theme.caution
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: Theme.fontSize + 4
                                                    MouseArea {
                                                        id: prevMa
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: calendarRect.prevMonth()
                                                    }
                                                }

                                                Item { Layout.fillWidth: true }

                                                Text {
                                                    text: calendarRect.monthNames[calendarRect.displayMonth]
                                                        + " " + calendarRect.displayYear
                                                    color: Theme.text
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: Theme.fontSize + 3
                                                    font.weight: Font.Bold
                                                }

                                                Item { Layout.fillWidth: true }

                                                Text {
                                                    text: "\u{f0142}"
                                                    color: nextMa.containsMouse ? Theme.text : Theme.caution
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: Theme.fontSize + 4
                                                    MouseArea {
                                                        id: nextMa
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: calendarRect.nextMonth()
                                                    }
                                                }
                                            }

                                            // Day headers
                                            Row {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                spacing: 0

                                                Repeater {
                                                    model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

                                                    Text {
                                                        required property var modelData
                                                        width: (calendarCol.width) / 7
                                                        horizontalAlignment: Text.AlignHCenter
                                                        text: modelData
                                                        color: Theme.caution
                                                        font.family: Theme.fontFamily
                                                        font.pixelSize: Theme.fontSize - 1
                                                        font.weight: Theme.fontWeight
                                                    }
                                                }
                                            }

                                            // Separator
                                            Rectangle {
                                                width: parent.width
                                                height: 1
                                                color: Theme.background
                                            }

                                            // Day grid
                                            Grid {
                                                id: dayGrid
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                columns: 7
                                                spacing: 0

                                                readonly property var calDays: calendarRect.calendarDays()
                                                readonly property int todayDay: new Date().getDate()
                                                readonly property int todayMonth: new Date().getMonth()
                                                readonly property int todayYear: new Date().getFullYear()
                                                readonly property int dispMonth: calendarRect.displayMonth
                                                readonly property int dispYear: calendarRect.displayYear

                                                Repeater {
                                                    model: dayGrid.calDays

                                                    Item {
                                                        required property var modelData
                                                        required property int index
                                                        width: (calendarCol.width) / 7
                                                        height: (calendarCol.height - 48) / 7

                                                        readonly property bool isToday: modelData.current
                                                            && modelData.day === dayGrid.todayDay
                                                            && dayGrid.dispMonth === dayGrid.todayMonth
                                                            && dayGrid.dispYear === dayGrid.todayYear

                                                        Rectangle {
                                                            anchors.centerIn: parent
                                                            width: 28
                                                            height: 28
                                                            radius: 14
                                                            color: isToday ? Theme.text : "transparent"
                                                        }

                                                        Text {
                                                            anchors.centerIn: parent
                                                            text: modelData.day
                                                            color: isToday ? Theme.background
                                                                : modelData.current ? Theme.text
                                                                : Theme.caution
                                                            font.family: Theme.fontFamily
                                                            font.pixelSize: Theme.fontSize
                                                            font.weight: isToday ? Font.Bold : Theme.fontWeight
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                // ── Mini media player ──
                                Rectangle {
                                    Layout.preferredWidth: 200
                                    Layout.fillHeight: true
                                    color: Theme.separator
                                    radius: 12

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 8

                                        Item { width: 1; height: 8 }

                                        // Album art circle
                                        Rectangle {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            width: 120
                                            height: 120
                                            radius: 60
                                            color: Theme.caution
                                            border.color: Theme.text
                                            border.width: 3

                                            Canvas {
                                                id: overviewArtCanvas
                                                anchors.fill: parent
                                                anchors.margins: 3
                                                renderTarget: Canvas.FramebufferObject
                                                smooth: true
                                                property string artUrl: calendarPopup.player
                                                    ? calendarPopup.player.trackArtUrl : ""

                                                onArtUrlChanged: {
                                                    if (artUrl !== "") loadImage(artUrl);
                                                    requestPaint();
                                                }

                                                onImageLoaded: requestPaint()

                                                onPaint: {
                                                    var ctx = getContext("2d");
                                                    ctx.reset();
                                                    var r = width / 2;
                                                    ctx.beginPath();
                                                    ctx.arc(r, r, r, 0, 2 * Math.PI);
                                                    ctx.clip();
                                                    if (artUrl !== "" && isImageLoaded(artUrl)) {
                                                        ctx.drawImage(artUrl, 0, 0, width, height);
                                                    }
                                                }

                                                Component.onCompleted: {
                                                    if (artUrl !== "") loadImage(artUrl);
                                                }
                                            }

                                            // Fallback icon when no art
                                            Text {
                                                anchors.centerIn: parent
                                                visible: !calendarPopup.player
                                                    || calendarPopup.player.trackArtUrl === ""
                                                text: "\u{f001}"
                                                color: Theme.text
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 32
                                            }
                                        }

                                        Item { width: 1; height: 4 }

                                        // Track title
                                        Text {
                                            width: parent.width
                                            horizontalAlignment: Text.AlignHCenter
                                            text: calendarPopup.player
                                                ? calendarPopup.player.trackTitle : "No media"
                                            color: Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                        }

                                        // Artist
                                        Text {
                                            width: parent.width
                                            horizontalAlignment: Text.AlignHCenter
                                            text: calendarPopup.player
                                                ? calendarPopup.player.trackArtist : ""
                                            color: Theme.caution
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize - 1
                                            font.weight: Theme.fontWeight
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                        }

                                        Item { Layout.fillHeight: true; width: 1; height: 8 }

                                        // Controls
                                        Row {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            spacing: 20

                                            Item {
                                                width: 32
                                                height: 32

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "\u{f04a}"
                                                    color: prevBtnMa.containsMouse ? Theme.text : Theme.caution
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: Theme.fontSize + 2
                                                }

                                                MouseArea {
                                                    id: prevBtnMa
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (calendarPopup.player) calendarPopup.player.previous();
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                width: 32
                                                height: 32
                                                radius: 16
                                                color: Theme.text

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: calendarPopup.player
                                                        && calendarPopup.player.playbackState === MprisPlaybackState.Playing
                                                        ? "\u{f04c}" : "\u{f04b}"
                                                    color: Theme.background
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: Theme.fontSize
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (calendarPopup.player) calendarPopup.player.togglePlaying();
                                                    }
                                                }
                                            }

                                            Item {
                                                width: 32
                                                height: 32

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "\u{f04e}"
                                                    color: nextBtnMa.containsMouse ? Theme.text : Theme.caution
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: Theme.fontSize + 2
                                                }

                                                MouseArea {
                                                    id: nextBtnMa
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (calendarPopup.player) calendarPopup.player.next();
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                    } // close bottom RowLayout
                                } // close right section Column
                            } // close sourceComponent RowLayout
                            } // close Loader

                            // ════════════════════════════
                            // ══ MEDIA TAB ═══════════════
                            // ════════════════════════════
                            Loader {
                                active: CalendarPopupState.activeTab === 1
                                anchors.fill: parent
                                sourceComponent: Item {
                                anchors.fill: parent

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 16
                                    width: parent.width * 0.6

                                    // Big album art circle
                                    Rectangle {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 200
                                        height: 200
                                        radius: 100
                                        color: Theme.caution
                                        border.color: Theme.text
                                        border.width: 4

                                        Canvas {
                                            id: mediaArtCanvas
                                            anchors.fill: parent
                                            anchors.margins: 4
                                            renderTarget: Canvas.FramebufferObject
                                            smooth: true
                                            property string artUrl: calendarPopup.player
                                                ? calendarPopup.player.trackArtUrl : ""

                                            onArtUrlChanged: {
                                                if (artUrl !== "") loadImage(artUrl);
                                                requestPaint();
                                            }

                                            onImageLoaded: requestPaint()

                                            onPaint: {
                                                var ctx = getContext("2d");
                                                ctx.reset();
                                                var r = width / 2;
                                                ctx.beginPath();
                                                ctx.arc(r, r, r, 0, 2 * Math.PI);
                                                ctx.clip();
                                                if (artUrl !== "" && isImageLoaded(artUrl)) {
                                                    ctx.drawImage(artUrl, 0, 0, width, height);
                                                }
                                            }

                                            Component.onCompleted: {
                                                if (artUrl !== "") loadImage(artUrl);
                                            }
                                        }

                                        // Fallback icon
                                        Text {
                                            anchors.centerIn: parent
                                            visible: !calendarPopup.player
                                                || calendarPopup.player.trackArtUrl === ""
                                            text: "\u{f001}"
                                            color: Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 48
                                            }
                                        }

                                    // Track title
                                    Text {
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                        text: calendarPopup.player
                                            ? calendarPopup.player.trackTitle : "No media playing"
                                        color: Theme.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize + 4
                                        font.weight: Font.Bold
                                        elide: Text.ElideRight
                                        maximumLineCount: 2
                                        wrapMode: Text.WordWrap
                                    }

                                    // Artist
                                    Text {
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                        text: calendarPopup.player
                                            ? calendarPopup.player.trackArtist : ""
                                        color: Theme.caution
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize + 1
                                        font.weight: Theme.fontWeight
                                        elide: Text.ElideRight
                                    }

                                    // ── Progress bar ──
                                    Column {
                                        width: parent.width
                                        spacing: 4

                                        // Bar
                                        Rectangle {
                                            width: parent.width
                                            height: 4
                                            radius: 2
                                            color: Theme.caution

                                            Rectangle {
                                                width: {
                                                    if (!calendarPopup.player || calendarPopup.player.length <= 0)
                                                        return 0;
                                                    return parent.width * Math.min(
                                                        calendarPopup.currentPosition / calendarPopup.player.length, 1);
                                                }
                                                height: parent.height
                                                radius: 2
                                                color: Theme.text
                                            }

                                            // Seek on click
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: mouse => {
                                                    if (calendarPopup.player && calendarPopup.player.canSeek) {
                                                        let ratio = mouse.x / parent.width;
                                                        calendarPopup.player.position = ratio * calendarPopup.player.length;
                                                    }
                                                }
                                            }
                                        }

                                        // Timestamps
                                        RowLayout {
                                            width: parent.width

                                            Text {
                                                text: calendarPopup.formatTime(calendarPopup.currentPosition)
                                                color: Theme.caution
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize - 2
                                                font.weight: Theme.fontWeight
                                            }

                                            Item { Layout.fillWidth: true }

                                            Text {
                                                text: calendarPopup.player
                                                    ? calendarPopup.formatTime(calendarPopup.player.length) : "0:00"
                                                color: Theme.caution
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize - 2
                                                font.weight: Theme.fontWeight
                                            }
                                        }
                                    }

                                    // ── Controls ──
                                    Row {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 32

                                        Text {
                                            text: "\u{f04a}"
                                            color: mediaPrevMa.containsMouse ? Theme.text : Theme.caution
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize + 6
                                            anchors.verticalCenter: parent.verticalCenter
                                            MouseArea {
                                                id: mediaPrevMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (calendarPopup.player) calendarPopup.player.previous();
                                                }
                                            }
                                        }

                                        Rectangle {
                                            width: 48
                                            height: 48
                                            radius: 24
                                            color: Theme.text
                                            anchors.verticalCenter: parent.verticalCenter

                                            Text {
                                                anchors.centerIn: parent
                                                text: calendarPopup.player
                                                    && calendarPopup.player.playbackState === MprisPlaybackState.Playing
                                                    ? "\u{f04c}" : "\u{f04b}"
                                                color: Theme.background
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize + 4
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (calendarPopup.player) calendarPopup.player.togglePlaying();
                                                }
                                            }
                                        }

                                        Text {
                                            text: "\u{f04e}"
                                            color: mediaNextMa.containsMouse ? Theme.text : Theme.caution
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize + 6
                                            anchors.verticalCenter: parent.verticalCenter
                                            MouseArea {
                                                id: mediaNextMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (calendarPopup.player) calendarPopup.player.next();
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            }

                            // ════════════════════════════
                            // ══ WALLPAPERS TAB ══════════
                            // ════════════════════════════
                            Loader {
                                active: CalendarPopupState.activeTab === 2
                                anchors.fill: parent
                                sourceComponent: Item {
                                anchors.fill: parent

                                Component.onCompleted: {
                                    if (calendarPopup.wallpaperList.length === 0)
                                        calendarPopup._wallpaperScanProc.running = true;
                                }

                                Column {
                                    anchors.fill: parent
                                    spacing: 8

                                    // Wallpaper grid
                                    Grid {
                                        id: wallpaperGrid
                                        columns: 4
                                        rows: 3
                                        spacing: 8
                                        width: parent.width

                                        readonly property real cellWidth: (width - (columns - 1) * spacing) / columns
                                        readonly property real cellHeight: (parent.height - footerRow.height - parent.spacing - 8) / rows

                                        Repeater {
                                            model: {
                                                let start = calendarPopup.wallpaperPage * calendarPopup.wallpapersPerPage;
                                                let end = Math.min(start + calendarPopup.wallpapersPerPage, calendarPopup.wallpaperList.length);
                                                let items = [];
                                                for (let i = start; i < end; i++)
                                                    items.push(calendarPopup.wallpaperList[i]);
                                                return items;
                                            }

                                            delegate: Rectangle {
                                                required property var modelData
                                                required property int index
                                                width: wallpaperGrid.cellWidth
                                                height: wallpaperGrid.cellHeight
                                                radius: 8
                                                color: Theme.caution
                                                border.color: calendarPopup.selectedWallpaper === modelData
                                                    ? Theme.text : wpMa.containsMouse ? Theme.misc : "transparent"
                                                border.width: 2
                                                clip: true

                                                Image {
                                                    anchors.fill: parent
                                                    anchors.margins: 2
                                                    source: "file://" + Theme.wallpaperDir + "/" + modelData
                                                    fillMode: Image.PreserveAspectCrop
                                                    asynchronous: true
                                                    smooth: true
                                                    sourceSize.width: wallpaperGrid.cellWidth * 2
                                                    sourceSize.height: wallpaperGrid.cellHeight * 2

                                                }

                                                // Rounded mask overlay
                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: 8
                                                    color: "transparent"
                                                    border.color: calendarPopup.selectedWallpaper === modelData
                                                        ? Theme.text : wpMa.containsMouse ? Theme.misc : "transparent"
                                                    border.width: 2
                                                }

                                                // Filename tooltip on hover
                                                Rectangle {
                                                    visible: wpMa.containsMouse
                                                    anchors.bottom: parent.bottom
                                                    anchors.left: parent.left
                                                    anchors.right: parent.right
                                                    height: wpFilename.implicitHeight + 6
                                                    color: Qt.rgba(0, 0, 0, 0.7)
                                                    radius: 0

                                                    // Bottom corners only
                                                    Rectangle {
                                                        anchors.top: parent.top
                                                        width: parent.width
                                                        height: parent.radius
                                                        color: parent.color
                                                    }

                                                    Text {
                                                        id: wpFilename
                                                        anchors.centerIn: parent
                                                        width: parent.width - 8
                                                        text: modelData
                                                        color: Theme.text
                                                        font.family: Theme.fontFamily
                                                        font.pixelSize: Theme.fontSize - 2
                                                        font.weight: Theme.fontWeight
                                                        elide: Text.ElideMiddle
                                                        horizontalAlignment: Text.AlignHCenter
                                                    }
                                                }

                                                MouseArea {
                                                    id: wpMa
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: calendarPopup.applyWallpaper(modelData)
                                                }
                                            }
                                        }
                                    }

                                    // Footer: pagination
                                    Row {
                                        id: footerRow
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 16

                                        // First page
                                        Text {
                                            text: "\u{f04a}\u{f04a}"
                                            color: wpFirstMa.containsMouse ? Theme.text : Theme.caution
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                            font.weight: Font.Bold
                                            visible: calendarPopup.wallpaperPage > 0
                                            anchors.verticalCenter: parent.verticalCenter
                                            MouseArea {
                                                id: wpFirstMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: calendarPopup.wallpaperPage = 0
                                            }
                                        }

                                        // Previous page
                                        Text {
                                            text: "\u{f04a}"
                                            color: wpPrevMa.containsMouse ? Theme.text : Theme.caution
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                            font.weight: Font.Bold
                                            visible: calendarPopup.wallpaperPage > 0
                                            anchors.verticalCenter: parent.verticalCenter
                                            MouseArea {
                                                id: wpPrevMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: calendarPopup.wallpaperPage = Math.max(0, calendarPopup.wallpaperPage - 1)
                                            }
                                        }

                                        // Counter text
                                        Text {
                                            text: calendarPopup.wallpaperList.length + " wallpapers  \u{2022}  "
                                                + (calendarPopup.wallpaperPage + 1) + " / " + calendarPopup.wallpaperTotalPages
                                            color: Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                            font.weight: Theme.fontWeight
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        // Next page
                                        Text {
                                            text: "\u{f04e}"
                                            color: wpNextMa.containsMouse ? Theme.text : Theme.caution
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                            font.weight: Font.Bold
                                            visible: calendarPopup.wallpaperPage < calendarPopup.wallpaperTotalPages - 1
                                            anchors.verticalCenter: parent.verticalCenter
                                            MouseArea {
                                                id: wpNextMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: calendarPopup.wallpaperPage = Math.min(
                                                    calendarPopup.wallpaperTotalPages - 1, calendarPopup.wallpaperPage + 1)
                                            }
                                        }

                                        // Last page
                                        Text {
                                            text: "\u{f04e}\u{f04e}"
                                            color: wpLastMa.containsMouse ? Theme.text : Theme.caution
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                            font.weight: Font.Bold
                                            visible: calendarPopup.wallpaperPage < calendarPopup.wallpaperTotalPages - 1
                                            anchors.verticalCenter: parent.verticalCenter
                                            MouseArea {
                                                id: wpLastMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: calendarPopup.wallpaperPage = calendarPopup.wallpaperTotalPages - 1
                                            }
                                        }
                                    }
                                }
                            }

                            }

                            // ════════════════════════════
                            // ══ THEMES TAB ═════════════
                            // ════════════════════════════
                            Loader {
                                active: CalendarPopupState.activeTab === 3
                                anchors.fill: parent
                                sourceComponent: Item {
                                anchors.fill: parent

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    // Section title
                                    Text {
                                        text: "\u{f1fc}  Color Themes"
                                        color: Theme.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize + 4
                                        font.weight: Font.Bold
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    // Theme cards grid
                                    Grid {
                                        id: themeGrid
                                        columns: 2
                                        spacing: 10
                                        width: parent.width
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        readonly property real cellWidth: (width - spacing) / columns

                                        Repeater {
                                            model: Theme.themeKeys

                                            delegate: Rectangle {
                                                required property string modelData
                                                required property int index
                                                width: themeGrid.cellWidth
                                                height: 120
                                                radius: 12
                                                color: Theme.themes[modelData].separator
                                                border.color: Theme.currentTheme === modelData
                                                    ? Theme.themes[modelData].text : "transparent"
                                                border.width: Theme.currentTheme === modelData ? 2 : 0

                                                Column {
                                                    anchors.fill: parent
                                                    anchors.margins: 10
                                                    spacing: 8

                                                    // Theme name + active badge
                                                    Row {
                                                        spacing: 8
                                                        width: parent.width

                                                        Text {
                                                            text: Theme.themes[modelData].name
                                                            color: Theme.themes[modelData].text
                                                            font.family: Theme.fontFamily
                                                            font.pixelSize: Theme.fontSize + 1
                                                            font.weight: Font.Bold
                                                        }

                                                        Rectangle {
                                                            visible: Theme.currentTheme === modelData
                                                            width: activeLabel.implicitWidth + 10
                                                            height: activeLabel.implicitHeight + 4
                                                            radius: 8
                                                            color: Theme.themes[modelData].accent
                                                            anchors.verticalCenter: parent.verticalCenter

                                                            Text {
                                                                id: activeLabel
                                                                anchors.centerIn: parent
                                                                text: "active"
                                                                color: Theme.themes[modelData].background
                                                                font.family: Theme.fontFamily
                                                                font.pixelSize: Theme.fontSize - 3
                                                                font.weight: Font.Bold
                                                            }
                                                        }
                                                    }

                                                    // Color palette preview
                                                    Row {
                                                        spacing: 4
                                                        width: parent.width

                                                        Repeater {
                                                            model: [
                                                                Theme.themes[modelData].background,
                                                                Theme.themes[modelData].separator,
                                                                Theme.themes[modelData].caution,
                                                                Theme.themes[modelData].text,
                                                                Theme.themes[modelData].accent,
                                                                Theme.themes[modelData].process,
                                                                Theme.themes[modelData].misc,
                                                                Theme.themes[modelData].warning
                                                            ]

                                                            delegate: Rectangle {
                                                                required property var modelData
                                                                width: (parent.width - 7 * parent.spacing) / 8
                                                                height: 16
                                                                radius: 4
                                                                color: modelData
                                                            }
                                                        }
                                                    }

                                                    // Preview bar mockup
                                                    Rectangle {
                                                        width: parent.width
                                                        height: 32
                                                        radius: 8
                                                        color: Theme.themes[modelData].background

                                                        Row {
                                                            anchors.centerIn: parent
                                                            spacing: 12

                                                            Text {
                                                                text: "Aa"
                                                                color: Theme.themes[modelData].text
                                                                font.family: Theme.fontFamily
                                                                font.pixelSize: Theme.fontSize
                                                                font.weight: Font.Bold
                                                            }

                                                            Rectangle {
                                                                width: 20; height: 12; radius: 3
                                                                color: Theme.themes[modelData].process
                                                                anchors.verticalCenter: parent.verticalCenter
                                                            }

                                                            Rectangle {
                                                                width: 20; height: 12; radius: 3
                                                                color: Theme.themes[modelData].misc
                                                                anchors.verticalCenter: parent.verticalCenter
                                                            }

                                                            Rectangle {
                                                                width: 20; height: 12; radius: 3
                                                                color: Theme.themes[modelData].warning
                                                                anchors.verticalCenter: parent.verticalCenter
                                                            }

                                                            Rectangle {
                                                                width: 20; height: 12; radius: 3
                                                                color: Theme.themes[modelData].accent
                                                                anchors.verticalCenter: parent.verticalCenter
                                                            }
                                                        }
                                                    }
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: Theme.setTheme(modelData)
                                                }

                                                Behavior on border.color { ColorAnimation { duration: 200 } }
                                            }
                                        }
                                    }

                                    // Current theme info
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Current: " + Theme.themes[Theme.currentTheme].name
                                        color: Theme.caution
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize
                                        font.weight: Theme.fontWeight
                                    }
                                }
                            }

                            }
                        }
                    }
                }
            }
        }
    }
}
