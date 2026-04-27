import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Rectangle {
    Layout.alignment: Qt.AlignHCenter
    Layout.margins: 8
    implicitWidth: 32
    implicitHeight: 48
    radius: 8
    color: palette.mid

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }

    property var audio: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
    property bool muted: audio ? audio.muted : false
    property int pct: audio ? Math.round(audio.volume * 100) : 0

    Column {
        anchors.centerIn: parent

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: muted ? "󰝟" : pct > 50 ? "󰕾" : "󰕿"
            color: palette.windowText
            font.pixelSize: 16
        }

        Text {
            visible: muted ? false : true
            anchors.horizontalCenter: parent.horizontalCenter
            text: pct + "%"
            color: palette.windowText
            font.pixelSize: 12
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: if (audio) audio.muted = !audio.muted
        onWheel: wheel => {
            if (!audio) return
            audio.volume = Math.max(0, Math.min(1.0, audio.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05)))
        }
    }
}
