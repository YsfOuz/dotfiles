import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import ".."

Column {
    spacing: 6

    SystemPalette { id: palette }

    Repeater {
        model: SystemTray.items
        delegate: Item {
            id: trayItem
            required property var modelData
            width:  Settings.leftBarWidth - Settings.padding * 2
            height: Settings.leftBarWidth - Settings.padding * 2

            // icon.toString() yields "image://icon/name?path=/dir" for custom-path icons
            readonly property string _iconStr:  modelData.icon ? modelData.icon.toString() : ""
            readonly property int    _pathIdx:  _iconStr.indexOf("?path=")
            readonly property bool   _hasCustomPath: _pathIdx !== -1
            readonly property string _iconDir:  _hasCustomPath ? _iconStr.substring(_pathIdx + 6) : ""
            readonly property string _iconName: {
                if (!_hasCustomPath) return ""
                var full = _iconStr.substring(0, _pathIdx)   // "image://icon/spotify-linux-32"
                var slash = full.lastIndexOf("/")
                return slash !== -1 ? full.substring(slash + 1) : full
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: modelData.menu
                anchor.item: trayItem
            }

            // Standard theme icons — skip for custom-path icons to avoid Quickshell's path warning
            IconImage {
                id: iconImg
                anchors.centerIn: parent
                source: trayItem._hasCustomPath ? "" : modelData.icon
                implicitSize: Settings.leftBarWidth - Settings.padding * 2 - 8
                visible: !trayItem._hasCustomPath
            }

            // Custom-path icons (e.g. Spotify) — load directly from the app's icon directory
            Image {
                anchors.centerIn: parent
                width:  Settings.leftBarWidth - Settings.padding * 2 - 8
                height: Settings.leftBarWidth - Settings.padding * 2 - 8
                source: trayItem._hasCustomPath
                    ? "file://" + trayItem._iconDir + "/" + trayItem._iconName + ".png"
                    : ""
                fillMode: Image.PreserveAspectFit
                smooth: true
                visible: trayItem._hasCustomPath
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton && modelData.hasMenu)
                        menuAnchor.open()
                    else
                        modelData.activate()
                }
            }
        }
    }
}
