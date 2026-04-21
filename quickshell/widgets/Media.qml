import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Item {
    id: root

    readonly property int btnSize: Settings.leftBarWidth - Settings.padding * 2

    implicitWidth:  btnSize
    implicitHeight: btnSize * 3 + Settings.spacing * 2
    visible: MediaState.active

    SystemPalette { id: palette }

    Process { id: ctlProc }

    Column {
        width: parent.width
        spacing: Settings.spacing

        Item {
            width: parent.width
            height: root.btnSize
            Text {
                anchors.centerIn: parent
                text:           "\u23ee"
                font.pixelSize: Settings.fontSize
                color:          palette.text
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: ctlProc.exec(["playerctl", "previous"])
            }
        }

        Item {
            width: parent.width
            height: root.btnSize
            Text {
                anchors.centerIn: parent
                text:           MediaState.playing ? "\u23f8" : "\u25b6"
                font.pixelSize: Settings.fontSize
                color:          palette.highlight
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: ctlProc.exec(["playerctl", "play-pause"])
            }
        }

        Item {
            width: parent.width
            height: root.btnSize
            Text {
                anchors.centerIn: parent
                text:           "\u23ed"
                font.pixelSize: Settings.fontSize
                color:          palette.text
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: ctlProc.exec(["playerctl", "next"])
            }
        }
    }
}
