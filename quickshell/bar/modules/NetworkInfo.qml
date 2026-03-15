import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: netText.implicitWidth + 10
    implicitHeight: Theme.barHeight

    // Wifi signal icons: U+F092B, U+F091F, U+F0922, U+F0925, U+F0928
    readonly property var wifiIcons: ["\u{f092b}", "\u{f091f}", "\u{f0922}", "\u{f0925}", "\u{f0928}"]

    Text {
        id: netText
        anchors.centerIn: parent
        text: {
            if (NetworkState.netType === "ethernet") return "\u{f0200}";
            if (NetworkState.netType === "wifi") {
                let idx = Math.min(Math.floor(NetworkState.signalStrength / 20), 4);
                return wifiIcons[idx];
            }
            return "\u{f1616}  Offline";
        }
        color: {
            if (NetworkState.netType === "offline") return Theme.caution;
            if (NetworkState.netType === "wifi" && NetworkState.signalStrength < 25) return Theme.warning;
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
        onClicked: NetworkPopupState.toggle()
    }
}
