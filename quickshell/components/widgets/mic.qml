import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../.."

Rectangle {
    implicitWidth: Settings.widgetSize
    implicitHeight: Settings.widgetSize
    radius: Settings.borderRadius

    color: Settings.surfaceT

    PwObjectTracker { objects: [Pipewire.defaultAudioSource] }

    property var audio: Pipewire.defaultAudioSource ? Pipewire.defaultAudioSource.audio : null
    property bool muted: audio ? audio.muted : false

    Text {
        anchors.centerIn: parent
        text: muted ? "󰍭" : "󰍬"
        color: Settings.text
        font.pixelSize: Settings.iconFont
    }

    MouseArea {
        anchors.fill: parent
        onClicked: if (audio) audio.muted = !audio.muted
    }
}
