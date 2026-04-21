import QtQuick
import Quickshell.Io
import ".."

Item {
    id: root

    property int  signal:    0
    property bool connected: false

    implicitWidth:  Settings.leftBarWidth - Settings.padding * 2
    implicitHeight: col.implicitHeight

    SystemPalette { id: palette }

    function poll() {
        proc.exec(["sh", "-c",
            "s=$(awk 'NR>2{print int($3)}' /proc/net/wireless 2>/dev/null || echo 0); " +
            "c=$(ip addr show wlan0 2>/dev/null | grep -c ' inet ' || echo 0); " +
            "echo $s $c"
        ])
    }

    Process {
        id: proc
        stdout: SplitParser {
            onRead: line => {
                var p = line.trim().split(" ")
                root.signal    = parseInt(p[0]) || 0
                root.connected = (parseInt(p[1]) || 0) > 0
            }
        }
    }

    Process {
        id: watchProc
        command: ["ip", "monitor", "link"]
        Component.onCompleted: running = true
        stdout: SplitParser { onRead: line => { if (line.indexOf("wlan0") !== -1) root.poll() } }
        onExited: restartTimer.start()
    }

    Timer { id: restartTimer; interval: 3000; repeat: false; onTriggered: watchProc.running = true }
    Timer { interval: 15000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.poll() }

    Column {
        id: col
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           "\uf1eb"
            font.pixelSize: Settings.fontSize
            color: !root.connected  ? "#e05050"
                 : root.signal < 20 ? "#e09050"
                 :                    palette.text
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.connected
                ? Math.min(100, Math.round(root.signal / 70 * 100)) + "%"
                : "off"
            font.pixelSize: Settings.fontSize - 6
            color:          palette.placeholderText
        }
    }
}
