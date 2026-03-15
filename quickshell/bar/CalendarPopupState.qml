pragma Singleton

import QtQuick

QtObject {
    property bool visible: false
    property int activeTab: 0 // 0 = Overview, 1 = Media

    function toggle() {
        visible = !visible;
    }

    function close() {
        visible = false;
        activeTab = 0;
    }
}
