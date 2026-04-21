import QtQuick
import Quickshell.Io
import ".."

Item {
    implicitWidth:  Settings.leftBarWidth - Settings.padding * 2
    implicitHeight: implicitWidth

    SystemPalette { id: palette }

    Process {
        command: [
            "systemd-inhibit",
            "--what=idle", "--who=Quickshell",
            "--why=User requested", "--mode=block",
            "sleep", "infinity"
        ]
        running: IdleInhibitorState.inhibiting
    }

    Text {
        anchors.centerIn: parent
        text:           IdleInhibitorState.inhibiting ? "\uf0f4" : "\uf186"
        font.pixelSize: Settings.fontSize
        color: IdleInhibitorState.inhibiting ? palette.highlight : palette.placeholderText
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: IdleInhibitorState.toggle()
    }
}
