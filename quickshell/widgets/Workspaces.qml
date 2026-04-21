import QtQuick
import Quickshell
import Quickshell.Hyprland
import ".."

Column {
    spacing: 6

    SystemPalette { id: palette }

    Repeater {
        model: Settings.workspaceCount
        delegate: Rectangle {
            required property int index

            readonly property int  wsId:    index + 1
            readonly property bool focused: Hyprland.focusedWorkspace !== null
                                         && Hyprland.focusedWorkspace.id === wsId
            readonly property bool hasWins: {
                var _ = Hyprland.workspaces.count
                return Hyprland.workspaces.values.some(w => w.id === wsId && w.toplevels.count > 0)
            }

            width:  Settings.leftBarWidth - Settings.padding * 2
            height: Settings.leftBarWidth - Settings.padding * 2
            radius: Settings.cornerRadius - 2

            color: focused  ? palette.highlight
                 : hasWins  ? Qt.rgba(palette.highlight.r, palette.highlight.g,
                                      palette.highlight.b, 0.15)
                 :             "transparent"

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
                onClicked: Hyprland.dispatch("workspace " + wsId)
            }
        }
    }
}
