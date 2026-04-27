import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string pamError: ""
    property string fullName: Quickshell.env("USER")

    Process {
        command: ["sh", "-c", "getent passwd " + Quickshell.env("USER") + " | cut -d: -f5 | cut -d, -f1"]
        running: true
        stdout: SplitParser {
            onRead: data => { if (data.trim() !== "") root.fullName = data.trim() }
        }
    }

    PamContext {
        id: pam
        config: "system-auth"
        user: Quickshell.env("USER")

        onCompleted: result => {
            if (result === PamResult.Success) {
                sessionLock.locked = false
            } else {
                root.pamError = "Wrong password"
                pam.start()
            }
        }

        onError: err => { root.pamError = "PAM error: " + err }
    }

    IpcHandler {
        target: "lockScreen"
        function lock(): void {
            if (sessionLock.locked) return
            root.pamError = ""
            sessionLock.locked = true
            pam.start()
        }
    }

    WlSessionLock {
        id: sessionLock

        WlSessionLockSurface {
            color: palette.window

            MouseArea { anchors.fill: parent }

            Timer {
                interval: 50
                running: sessionLock.locked
                onTriggered: passwordField.forceActiveFocus()
            }

            Column {
                anchors.centerIn: parent
                spacing: 24

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatTime(new Date(), "HH:mm")
                        color: palette.windowText
                        font.pixelSize: 96
                        font.weight: Font.Bold

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            triggeredOnStart: true
                            onTriggered: parent.text = Qt.formatTime(new Date(), "HH:mm")
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDate(new Date(), "dddd, MMMM d")
                        color: palette.windowText
                        font.pixelSize: 24
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 480
                    height: dialogLayout.implicitHeight + 32
                    radius: 8
                    color: palette.base
                    border { width: 2; color: palette.alternateBase }

                    MouseArea { anchors.fill: parent }

                    ColumnLayout {
                        id: dialogLayout
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
                        spacing: 16

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.fullName
                            color: palette.windowText
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 32
                            radius: 8
                            color: palette.alternateBase
                            border {
                                width: 2
                                color: passwordField.activeFocus ? palette.highlight : palette.mid
                            }

                            TextInput {
                                id: passwordField
                                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 10 }
                                echoMode: TextInput.Password
                                color: palette.windowText
                                font.pixelSize: 16
                                focus: true
                                onTextChanged: root.pamError = ""
                                Keys.onReturnPressed: { pam.respond(text); text = "" }
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.pamError
                            color: "#e74c3c"
                            font.pixelSize: 12
                            visible: root.pamError !== ""
                        }
                    }
                }
            }
        }
    }
}
