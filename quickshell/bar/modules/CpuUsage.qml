import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: cpuText.implicitWidth + Theme.modulePadding * 2
    implicitHeight: Theme.barHeight

    Text {
        id: cpuText
        anchors.centerIn: parent
        text: "\uf2db " + CpuState.usage + "%"
        color: {
            if (CpuState.usage >= 95) return CpuState.blinkState ? Theme.warning : Theme.separator;
            return Theme.text;
        }
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }

    opacity: mouseArea.containsMouse ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 80 } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: Quickshell.execDetached(["kitty", "-e", "btop"])
    }
}
