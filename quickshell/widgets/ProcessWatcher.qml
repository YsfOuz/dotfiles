import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string command: ""
    property var processArgs: []
    property int restartDelay: 3000
    property var onRead: (line) => {}

    Process {
        id: proc
        command: [root.command, ...root.processArgs]

        stdout: SplitParser {
            onRead: line => {
                root.onRead(line)
            }
        }

        onExited: (exitCode) => {
            if (root.active) {
                restartTimer.start()
            }
        }
    }

    property bool active: true

    Timer {
        id: restartTimer
        interval: root.restartDelay
        running: false
        repeat: false
        onTriggered: proc.exec([root.command, ...root.processArgs])
    }

    Component.onCompleted: {
        if (root.active) {
            proc.exec([root.command, ...root.processArgs])
        }
    }

    function stop() {
        active = false
        proc.running = false
    }

    function start() {
        active = true
        proc.exec([root.command, ...root.processArgs])
    }

    function exec(args) {
        proc.exec(args)
    }
}
