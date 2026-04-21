import QtQuick
import Quickshell.Io
import ".."

Item {
    id: root

    property bool powered:   false
    property int  connected: 0

    implicitWidth:  Settings.leftBarWidth - Settings.padding * 2
    implicitHeight: implicitWidth

    SystemPalette { id: palette }

    function poll() {
        proc.exec(["sh", "-c",
            "powered=$(bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2}'); " +
            "count=$(bluetoothctl devices Connected 2>/dev/null | wc -l); " +
            "echo \"$powered $count\""
        ])
    }

    Process {
        id: proc
        stdout: SplitParser {
            onRead: line => {
                var p = line.trim().split(" ")
                root.powered   = (p[0] === "yes")
                root.connected = parseInt(p[1]) || 0
            }
        }
    }

    Process { id: toggleProc; onRunningChanged: if (!running) root.poll() }

    Process {
        id: watchProc
        command: ["sh", "-c",
            "dbus-monitor --system \"type='signal',interface='org.freedesktop.DBus.Properties',sender='org.bluez'\" 2>/dev/null " +
            "| grep --line-buffered 'PropertiesChanged'"
        ]
        Component.onCompleted: running = true
        stdout: SplitParser { onRead: _ => root.poll() }
        onExited: restartTimer.start()
    }

    Timer { id: restartTimer; interval: 3000; repeat: false; onTriggered: watchProc.running = true }
    Timer { interval: 15000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.poll() }

    Text {
        anchors.centerIn: parent
        text:           "\uf293"
        font.pixelSize: Settings.fontSize
        color: !root.powered      ? palette.placeholderText
             : root.connected > 0 ? palette.highlight
             :                      palette.text
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.powered = !root.powered
            toggleProc.exec(["bluetoothctl", "power", root.powered ? "on" : "off"])
        }
    }
}
