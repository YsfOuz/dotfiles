import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import "../.."

ColumnLayout {
    spacing: 4
    property var window

    readonly property int itemSize: Math.round(Settings.widgetSize * 0.75)

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayItem
            required property var modelData

            implicitWidth: itemSize
            implicitHeight: itemSize

            Image {
                anchors.fill: parent
                source: {
                    var icon = trayItem.modelData.icon
                    if (!icon) return ""
                    var q = icon.indexOf("?")
                    if (q !== -1) icon = icon.substring(0, q)
                    if (icon.startsWith("image://") || icon.startsWith("file://")) return icon
                    if (icon.startsWith("/")) return "file://" + icon
                    return "image://icon/" + icon
                }
                fillMode: Image.PreserveAspectFit
                sourceSize.width: itemSize
                sourceSize.height: itemSize
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton && trayItem.modelData.hasMenu) {
                        var pos = trayItem.mapToItem(null, trayItem.width, 0)
                        trayItem.modelData.display(window, pos.x, pos.y)
                    } else {
                        trayItem.modelData.activate()
                    }
                }
            }
        }
    }
}
