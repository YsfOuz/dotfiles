import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import ".."

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
        focus: true
        Keys.onEscapePressed: root.visible = false
        onClicked: root.visible = false
    }

    Rectangle {
        anchors.centerIn: parent
        width: btnRow.width + 16
        height: btnRow.height + 16
        color: Settings.bg
        radius: Settings.borderRadius
        border { width: Settings.borderWidth; color: Settings.borderColor }

        MouseArea { anchors.fill: parent }

        Row {
            id: btnRow
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: [
                    { icon: "󰌾", label: "Lock",      cmd: "qs ipc call lockScreen lock" },
                    { icon: "󰍃", label: "Logout",    cmd: "loginctl kill-session $XDG_SESSION_ID" },
                    { icon: "󰤄", label: "Suspend",   cmd: "zzz" },
                    { icon: "󰒲", label: "Hibernate", cmd: "ZZZ" },
                    { icon: "󰑓", label: "Reboot",    cmd: "loginctl reboot" },
                    { icon: "󰐥", label: "Shutdown",  cmd: "loginctl poweroff" },
                ]

                delegate: Rectangle {
                    required property var modelData
                    width: Settings.powerMenuBtnSize
                    height: Settings.powerMenuBtnSize
                    radius: Settings.borderRadius
                    color: ma.containsMouse ? Settings.accent : Settings.surface

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.visible = false
                            proc.command = ["sh", "-c", modelData.cmd]
                            proc.running = false
                            proc.running = true
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.icon
                            color: ma.containsMouse ? Settings.accentText : Settings.text
                            font.pixelSize: Math.round(Settings.powerMenuBtnSize * 0.5)
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.label
                            color: ma.containsMouse ? Settings.accentText : Settings.text
                            font.pixelSize: Math.round(Settings.powerMenuBtnSize * 0.125)
                        }
                    }
                }
            }
        }
    }
}
