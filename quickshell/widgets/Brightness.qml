import QtQuick
import Quickshell.Io
import ".."

Item {
    id: root

    property int brightness: 0

    implicitWidth:  Settings.leftBarWidth - Settings.padding * 2
    implicitHeight: col.implicitHeight

    SystemPalette { id: palette }

    ProcessWatcher {
        id: proc
        command: "sh"
        processArgs: ["-c", "while true; do brightnessctl -m; sleep 0.1; done"]
        onRead: line => {
            var parts = line.split(",")
            if (parts.length >= 4) {
                var pct = parseInt(parts[3])
                if (!isNaN(pct)) root.brightness = pct
            }
        }
    }

    Process { id: setProc; onRunningChanged: if (!running) proc.exec(["brightnessctl", "-m"]) }

    Timer { interval: 1000; running: true; repeat: true; onTriggered: proc.exec(["brightnessctl", "-m"]) }

    Column {
        id: col
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           "󰃠"
            font.pixelSize: Settings.fontSize
            color: root.brightness < 10 ? palette.placeholderText : palette.text
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           root.brightness + "%"
            font.pixelSize: Settings.fontSize - 6
            color:          palette.placeholderText
        }
    }

    MouseArea {
        anchors.fill: parent
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
                setProc.exec(["brightnessctl", "set", "5%+"])
            else if (root.brightness > 5)
                setProc.exec(["brightnessctl", "set", "5%-"])
        }
    }
}
