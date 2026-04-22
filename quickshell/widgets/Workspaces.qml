import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Column {
    spacing: 6

    SystemPalette { id: palette }

    property int activeTags:   1
    property int occupiedTags: 0

    function parseTagLine(line) {
        var parts = line.trim().split(/\s+/)
        if (parts.length >= 5 && parts[1] === "tags") {
            // skip binary string lines (e.g. "000000010") — only process numeric bitmasks
            if (/^[01]{9}$/.test(parts[2])) return
            var occ = parseInt(parts[2], 10)
            var sel = parseInt(parts[3], 10)
            if (!isNaN(occ)) occupiedTags = occ
            if (!isNaN(sel)) activeTags   = sel
        }
    }

    // fetch current state once on startup
    Process {
        command: ["mmsg", "-g", "-t"]
        running: true
        stdout: SplitParser { onRead: line => parseTagLine(line) }
    }

    // stream state changes
    Process {
        command: ["mmsg", "-w", "-t"]
        running: true
        stdout: SplitParser { onRead: line => parseTagLine(line) }
    }

    Repeater {
        model: Settings.workspaceCount
        delegate: Rectangle {
            required property int index

            readonly property int  wsId:    index + 1
            readonly property bool focused: (activeTags   & (1 << index)) !== 0
            readonly property bool hasWins: (occupiedTags & (1 << index)) !== 0

            width:  Settings.leftBarWidth - Settings.padding * 2
            height: Settings.leftBarWidth - Settings.padding * 2
            radius: Settings.cornerRadius - 2

            color: focused  ? palette.highlight
                 : hasWins  ? Qt.rgba(palette.highlight.r, palette.highlight.g,
                                      palette.highlight.b, 0.15)
                 :             "transparent"

            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text:           wsId
                color:          focused ? palette.highlightedText : palette.text
                font.pixelSize: Settings.fontSize - 2
                font.bold:      focused
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: switchProc.exec(["mmsg", "-s", "-t", wsId.toString()])

                Process { id: switchProc }
            }
        }
    }
}
