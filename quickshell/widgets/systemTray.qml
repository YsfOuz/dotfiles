import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "widgets"
import "../config.js" as Config

Rectangle {
    implicitWidth: Config.bar.width - Layout.margins*2
    implicitHeight: tray.height
    color: Config.colors.bgLight
    Layout.margins: 8
    ColumnLayout {
        id: tray
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        Repeater {
            model: SystemTray.items

            Item {
                implicitWidth: 24
                implicitHeight: 24

                required property var modelData
                Image {
                    anchors.fill: parent
                    source: modelData.icon
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onClicked: m => {
                        if(m.button === Qt.LeftButton && !modelData.onlyMenu) {
                            modelData.activate()
                        }else if(m.button === Qt.RightButton && modelData.hasMenu) {
                            const p = mapToItem(QsWindow.window.contentItem, width, 0)
                            modelData.display(QsWindow.window, p.x, p.y)
                        }else if(m.button === Qt.MiddleButton) {
                            modelData.secondaryActivate()
                        }
                    }
                }
            }
        }
    }
}
