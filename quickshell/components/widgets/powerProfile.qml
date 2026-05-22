import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../.."

Rectangle {
    implicitWidth: Settings.widgetSize
    implicitHeight: Settings.widgetSize
    radius: Settings.borderRadius

    color: Settings.surface

    Text {
        anchors.centerIn: parent
        text: ["󰌪", "󰗑", "󰑣"][PowerProfiles.profile] ?? "N/A"
        color: Settings.text
        font.pixelSize: Settings.iconFont
    }

    MouseArea {
        anchors.fill: parent
        onClicked: PowerProfiles.profile = (PowerProfiles.profile + 1) % 3
    }
}
