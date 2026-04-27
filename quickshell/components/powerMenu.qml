import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root
    visible: false
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    IpcHandler {
        target: "powerMenu"
        function toggle(): void { root.visible = !root.visible }
    }

    Process { id: proc }

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        anchors.centerIn: parent
        width: btnRow.width + 16
        height: btnRow.height + 16
        color: palette.window
        radius: 8
        border { width: 2; color: palette.alternateBase }

        MouseArea { anchors.fill: parent }

        Row {
            id: btnRow
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: [
                    ["󰌾", "Lock",      "qs ipc call lockScreen lock"],
                    ["󰍃", "Logout",    "loginctl kill-session $XDG_SESSION_ID"],
                    ["󰤄", "Suspend",   "zzz"],
                    ["󰒲", "Hibernate", "ZZZ"],
                    ["󰑓", "Reboot",    "loginctl reboot"],
                    ["󰐥", "Shutdown",  "loginctl poweroff"],
                ]

                delegate: Rectangle {
                    required property var modelData
                    width: 128
                    height: 128
                    radius: 8
                    color: ma.containsMouse ? palette.highlight : palette.mid

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.visible = false
                            proc.command = ["sh", "-c", modelData[2]]
                            proc.running = false
                            proc.running = true
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData[0]
                            color: ma.containsMouse ? palette.highlightedText : palette.windowText
                            font.pixelSize: 64
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData[1]
                            color: ma.containsMouse ? palette.highlightedText : palette.windowText
                            font.pixelSize: 16
                        }
                    }
                }
            }
        }
    }
}
