import QtQuick
import Quickshell.Io
import ".."

Item {
    id: root

    property int    capacity:   0
    property string status:     "Unknown"
    property bool   charging:   status === "Charging" || status === "Full"
    property bool   hasBattery: false

    implicitWidth:  Settings.leftBarWidth - Settings.padding * 2
    implicitHeight: col.implicitHeight
    visible: hasBattery

    SystemPalette { id: palette }

    Timer {
        interval: 30000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: proc.exec([
            "sh", "-c",
            "for b in BAT0 BAT1 BAT2; do d=/sys/class/power_supply/$b; " +
            "[ -f $d/capacity ] && printf '%s %s' $(cat $d/capacity) $(cat $d/status) && break; done"
        ])
    }

    Process {
        id: proc
        stdout: SplitParser {
            onRead: line => {
                var p = line.trim().split(" ")
                if (p.length >= 2) {
                    var n = parseInt(p[0])
                    if (!isNaN(n) && n >= 0 && n <= 100) {
                        root.capacity   = n
                        root.status     = p[1]
                        root.hasBattery = true
                    }
                }
            }
        }
    }

    Column {
        id: col
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                if (root.charging)        return "\uf0e7"
                if (root.capacity > 80)   return "\uf240"
                if (root.capacity > 60)   return "\uf241"
                if (root.capacity > 40)   return "\uf242"
                if (root.capacity > 20)   return "\uf243"
                return "\uf244"
            }
            font.pixelSize: Settings.fontSize
            color: root.capacity <= 20 && !root.charging ? "#e05050" : palette.text
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text:           root.capacity + "%"
            font.pixelSize: Settings.fontSize - 6
            color:          palette.placeholderText
        }
    }
}
