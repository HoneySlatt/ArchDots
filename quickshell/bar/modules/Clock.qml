import QtQuick
import QtQuick.Layouts
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: clockText.implicitWidth
    implicitHeight: Theme.barHeight

    Text {
        id: clockText
        anchors.centerIn: parent
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
        text: Qt.formatDateTime(new Date(), "hh:mm AP\u2009 -\u2009\u2009ddd dd")
    }

    opacity: mouseArea.containsMouse ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 80 } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: CalendarPopupState.toggle()
    }

    // Fire once at the next minute boundary, then every 60s
    Timer {
        id: syncTimer
        interval: {
            let now = new Date();
            return (60 - now.getSeconds()) * 1000 - now.getMilliseconds();
        }
        running: true
        repeat: false
        onTriggered: {
            clockText.text = Qt.formatDateTime(new Date(), "hh:mm AP\u2009 -\u2009\u2009ddd dd");
            minuteTimer.start();
        }
    }

    Timer {
        id: minuteTimer
        interval: 60000
        running: false
        repeat: true
        onTriggered: clockText.text = Qt.formatDateTime(new Date(), "hh:mm AP\u2009 -\u2009\u2009ddd dd")
    }
}
