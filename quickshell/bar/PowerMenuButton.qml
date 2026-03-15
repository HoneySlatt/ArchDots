import QtQuick
import QtQuick.Layouts

Rectangle {
    id: btn

    property string label: ""
    property string iconGlyph: ""
    signal activated()

    Layout.preferredWidth: 260
    Layout.preferredHeight: 420
    radius: 20
    color: mouseArea.containsMouse
        ? Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.85)
        : Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.85)
    border.width: 2
    border.color: mouseArea.containsMouse
        ? Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.4)
        : Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.6)

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    Column {
        anchors.centerIn: parent
        spacing: 16

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: btn.iconGlyph
            color: mouseArea.containsMouse ? Theme.accent : Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 80

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: btn.label
            color: mouseArea.containsMouse ? Theme.accent : Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 20

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.activated()
    }
}
