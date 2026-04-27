import QtQuick
import Quickshell.Io
import ".."

Item {
    id: root

    property real volume: 0.0
    property bool muted:  false

    implicitWidth:  Settings.leftBarWidth - Settings.padding * 2
    implicitHeight: col.implicitHeight

    SystemPalette { id: palette }

    ProcessWatcher {
        id: volWatcher
        command: "sh"
        processArgs: ["-c", "while true; do wpctl get-volume @DEFAULT_AUDIO_SINK@; sleep 30; done"]
        onRead: line => {
            var m = line.match(/Volume:\s*([\d.]+)/)
            if (m) {
                root.volume = parseFloat(m[1])
                root.muted  = line.indexOf("[MUTED]") !== -1
            }
        }
    }

    Process {
        id: eventWatch
        command: ["sh", "-c", "pactl subscribe 2>/dev/null | grep --line-buffered \"'change' on sink\""]
        Component.onCompleted: running = true
        stdout: SplitParser { onRead: _ => {
            volWatcher.exec(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"])
        } }
        onExited: restartTimer.start()
    }

    Timer { id: restartTimer; interval: 3000; repeat: false; onTriggered: eventWatch.running = true }

    Process {
        id: setProc
        onRunningChanged: if (!running) {
            volWatcher.exec(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"])
        }
    }

    Column {
        id: col
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.muted || root.volume <= 0 ? "󰝟"
                : root.volume <= 0.5             ? "󰖀"
                :                                  "󰕾"
            font.pixelSize: Settings.fontSize
            color: root.muted ? palette.placeholderText : palette.text
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           root.muted ? "mute" : Math.round(root.volume * 100) + "%"
            font.pixelSize: Settings.fontSize - 6
            color:          palette.placeholderText
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: setProc.exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
                setProc.exec(["wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", "5%+"])
            else
                setProc.exec(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"])
        }
    }
}
