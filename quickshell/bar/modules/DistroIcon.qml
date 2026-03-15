import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: distroText.implicitWidth + 12
    implicitHeight: Theme.barHeight

    Text {
        id: distroText
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 6
        text: DistroState.icon
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 18
        font.weight: Theme.fontWeight
    }

    opacity: mouseArea.containsMouse ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 80 } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: LauncherState.toggle()
    }
}
