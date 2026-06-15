import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import "../.."

Rectangle {
    id: root
    property var window

    implicitWidth: Settings.widgetSize
    implicitHeight: Settings.widgetSize
    radius: Settings.borderRadius

    color: inhibitor.enabled ? Settings.accent : Settings.surfaceT

    IdleInhibitor {
        id: inhibitor
        enabled: false
        window: root.window
    }

    Text {
        anchors.centerIn: parent
        text: inhibitor.enabled ? "󰛨" : "󰤄"
        color: inhibitor.enabled ? Settings.accentText : Settings.text
        font.pixelSize: Settings.iconFont
    }

    MouseArea {
        anchors.fill: parent
        onClicked: inhibitor.enabled = !inhibitor.enabled
    }
}
