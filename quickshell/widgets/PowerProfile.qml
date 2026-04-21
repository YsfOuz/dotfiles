import QtQuick
import Quickshell.Io
import ".."

Item {
    id: root

    implicitWidth:  Settings.leftBarWidth - Settings.padding * 2
    implicitHeight: implicitWidth

    property string ctl:             "powerprofilesctl"
    property var    availableProfiles: []

    SystemPalette { id: palette }

    // Detect backend: tlp-pd takes priority if its service is active
    Process {
        id: detectProc
        stdout: SplitParser {
            onRead: line => { if (line.trim() === "active") root.ctl = "tlpctl" }
        }
        onExited: {
            listProc._tmp = []
            listProc.exec([root.ctl, "list"])
        }
        Component.onCompleted: exec(["systemctl", "is-active", "tlp-pd"])
    }

    Process {
        id: listProc
        property var _tmp: []
        stdout: SplitParser {
            onRead: line => {
                var m = line.match(/^\s*\*?\s*(performance|balanced|power-saver):/)
                if (m) listProc._tmp.push(m[1])
            }
        }
        onExited: {
            root.availableProfiles = listProc._tmp
            getProc.exec([root.ctl, "get"])
        }
    }

    Process {
        id: getProc
        stdout: SplitParser { onRead: line => PowerProfileState.profile = line.trim() }
    }

    Process { id: setProc; onRunningChanged: if (!running) getProc.exec([root.ctl, "get"]) }

    Process {
        id: watchProc
        command: ["sh", "-c",
            "dbus-monitor --system \"type='signal',interface='org.freedesktop.DBus.Properties',sender='net.hadess.PowerProfiles'\" 2>/dev/null " +
            "| grep --line-buffered 'PropertiesChanged'"
        ]
        Component.onCompleted: running = true
        stdout: SplitParser { onRead: _ => getProc.exec([root.ctl, "get"]) }
        onExited: restartTimer.start()
    }

    Timer { id: restartTimer; interval: 3000; repeat: false; onTriggered: watchProc.running = true }
    Timer { interval: 30000; running: true; repeat: true; onTriggered: getProc.exec([root.ctl, "get"]) }

    Text {
        anchors.centerIn: parent
        text: {
            if (PowerProfileState.profile === "performance") return ""
            if (PowerProfileState.profile === "power-saver") return ""
            return ""
        }
        font.pixelSize: Settings.fontSize
        color: {
            if (PowerProfileState.profile === "performance") return "#e05050"
            if (PowerProfileState.profile === "power-saver") return "#50c878"
            return palette.text
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var profiles = root.availableProfiles.length > 0
                ? root.availableProfiles
                : ["power-saver", "balanced", "performance"]
            var next = profiles[(profiles.indexOf(PowerProfileState.profile) + 1) % profiles.length]
            PowerProfileState.profile = next
            setProc.exec([root.ctl, "set", next])
        }
    }
}
