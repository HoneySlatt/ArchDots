import QtQuick
import QtQuick.Layouts
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: powerText.implicitWidth + 18
    implicitHeight: Theme.barHeight

    Text {
        id: powerText
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -3
        text: "\u23fb"
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.weight: Theme.fontWeight
    }

    opacity: mouseArea.containsMouse ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 80 } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: PowerLauncherState.toggle()
    }
}
