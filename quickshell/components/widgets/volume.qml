import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../.."

Rectangle {
    implicitWidth: Settings.widgetSize
    implicitHeight: Settings.widgetSize + 16
    radius: Settings.borderRadius

    color: Settings.surface

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    property var audio: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
    property bool muted: audio ? audio.muted : false
    property int pct: audio ? Math.round(audio.volume * 100) : 0

    Column {
        anchors.centerIn: parent

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: muted ? "󰝟" : pct > 50 ? "󰕾" : "󰕿"
            color: Settings.text
            font.pixelSize: Settings.iconFont
        }

        Text {
            visible: !muted
            anchors.horizontalCenter: parent.horizontalCenter
            text: pct + "%"
            color: Settings.text
            font.pixelSize: Settings.labelFont
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: if (audio) audio.muted = !audio.muted
        onWheel: wheel => {
            if (!audio) return
            audio.volume = Math.max(0, Math.min(1.0, audio.volume + (wheel.angleDelta.y > 0 ? Settings.volumeStep : -Settings.volumeStep)))
        }
    }
}
