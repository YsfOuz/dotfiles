import Quickshell
import Quickshell.Wayland
import QtQuick
import "config.js" as Config
import QtQuick.Layouts
import "widgets"

PanelWindow {
    anchors {
        left: true
        top: true
        bottom: true
    }

    implicitWidth: Config.bar.width
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Config.colors.bg
        border {
            color: Config.colors.bgLight
            width: 2
        }

        ColumnLayout {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            Workspaces {}
        }
        ColumnLayout {
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            Clock {}
        }
        ColumnLayout {
            Layout.fillWidth: true
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            SystemTray {}
            Battery {}
        }
    }
}
