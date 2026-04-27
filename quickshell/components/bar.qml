import Quickshell
import QtQuick
import QtQuick.Layouts
import "widgets"

PanelWindow {
    id: barWindow
    implicitWidth: 48
    color: "transparent"
    anchors {
        left: true
        top: true
        bottom: true
    }
    margins {
        left: 8
        top: 8
        bottom: 8
    }
    Rectangle {
        color: palette.window 
        anchors.fill: parent
        radius: 8
        border {
            width: 2 
            color: palette.alternateBase
        }
    }

    ColumnLayout {
        spacing: 0
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        Workspaces {}
    }

    ColumnLayout {
        spacing: 0
        anchors.centerIn: parent
        Clock {}
    }

    ColumnLayout {
        spacing: 0
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        SystemTray { window: barWindow }
        Mic{}
        Volume{}
        Brightness{}
        PowerProfile {}
        Battery {}
    }
}
