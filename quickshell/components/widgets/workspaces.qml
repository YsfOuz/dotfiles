import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ColumnLayout {
    Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
    Layout.margins: 8

    property string occupiedTags: "000000000"
    property string focusedTags: "000000000"
    property string urgentTags: "000000000"

    property var wsIdxById: ({})
    property var winWsById: ({})
    property var winCountByWs: ({})
    property int focusedWsId: -1

    function setWindowWorkspace(winId, wsId) {
        const next = (typeof wsId === "number") ? wsId : null
        const prev = winWsById[winId]
        if (prev === next) return
        if (prev !== undefined) {
            winCountByWs[prev] = Math.max(0, (winCountByWs[prev] | 0) - 1)
        }
        if (next === null) {
            delete winWsById[winId]
        } else {
            winWsById[winId] = next
            winCountByWs[next] = (winCountByWs[next] | 0) + 1
        }
    }

    function rebuildBitmaps() {
        let occ = "", foc = ""
        for (let slot = 9; slot >= 1; slot--) {
            let occupied = false, focused = false
            for (const id in wsIdxById) {
                if (wsIdxById[id] !== slot) continue
                if ((winCountByWs[id] | 0) > 0) occupied = true
                if (parseInt(id) === focusedWsId) focused = true
            }
            occ += occupied ? "1" : "0"
            foc += focused  ? "1" : "0"
        }
        occupiedTags = occ
        focusedTags = foc
    }

    Process {
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                let event
                try { event = JSON.parse(line) } catch (_) { return }

                if (event.WorkspacesChanged) {
                    for (const k in wsIdxById) delete wsIdxById[k]
                    for (const ws of event.WorkspacesChanged.workspaces) {
                        wsIdxById[ws.id] = ws.idx
                        if (ws.is_focused) focusedWsId = ws.id
                    }
                    for (const id in winCountByWs) {
                        if (!(id in wsIdxById)) delete winCountByWs[id]
                    }
                    rebuildBitmaps()
                }
                else if (event.WorkspaceActivated && event.WorkspaceActivated.focused) {
                    focusedWsId = event.WorkspaceActivated.id
                    rebuildBitmaps()
                }
                else if (event.WindowsChanged) {
                    for (const k in winWsById) delete winWsById[k]
                    for (const k in winCountByWs) delete winCountByWs[k]
                    for (const w of event.WindowsChanged.windows) {
                        setWindowWorkspace(w.id, w.workspace_id)
                    }
                    rebuildBitmaps()
                }
                else if (event.WindowOpenedOrChanged) {
                    const w = event.WindowOpenedOrChanged.window
                    setWindowWorkspace(w.id, w.workspace_id)
                    rebuildBitmaps()
                }
                else if (event.WindowClosed) {
                    setWindowWorkspace(event.WindowClosed.id, null)
                    rebuildBitmaps()
                }
            }
        }
    }

    Repeater {
        model: 9
        Rectangle {
            implicitWidth: 32
            implicitHeight: 32
            radius: 8

            readonly property int stringIdx: 8 - index
            readonly property bool isOccupied: occupiedTags[stringIdx] === "1"
            readonly property bool isFocused: focusedTags[stringIdx] === "1"

            color: isFocused ? palette.highlight : palette.mid
            visible: isOccupied || isFocused

            Text {
                anchors.centerIn: parent
                text: index + 1
                color: isFocused ? palette.highlightedText : palette.windowText
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    tagSetter.command = ["niri", "msg", "action", "focus-workspace", (index + 1).toString()]
                    tagSetter.running = true
                }
            }
        }
    }
    Process { id: tagSetter; running: false }
}
