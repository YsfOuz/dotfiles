import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Rectangle {
    Layout.alignment: Qt.AlignHCenter
    Layout.margins: 8
    implicitWidth: 32
    implicitHeight: 32
    radius: 8
    color: palette.mid

    PwObjectTracker { objects: [Pipewire.defaultAudioSource] }

    property var audio: Pipewire.defaultAudioSource ? Pipewire.defaultAudioSource.audio : null
    property bool muted: audio ? audio.muted : false

    Text {
        anchors.centerIn: parent
        text: muted ? "󰍭" : "󰍬"
        color: palette.windowText
        font.pixelSize: 16
    }

    MouseArea {
        anchors.fill: parent
        onClicked: if (audio) audio.muted = !audio.muted
    }
}
