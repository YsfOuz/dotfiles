import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam

WlSessionLock {
    id: root

    locked: active
    property bool active: false

    function lock() {
        active = true
        pam.start()
    }

    WlSessionLockSurface {
        color: "#000000"

        PamContext {
            id: pam
            config: "login"

            onPamMessage: {
                if (responseRequired) {
                    passwordField.placeholderText = message
                    passwordField.forceActiveFocus()
                }
            }

            onCompleted: result => {
                if (result === PamResult.Success) {
                    root.active = false
                } else {
                    passwordField.text = ""
                    passwordField.placeholderText = "Incorrect — try again"
                    pam.start()
                }
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 24

            Text {
                id: clockText
                anchors.horizontalCenter: parent.horizontalCenter
                text:           Qt.formatDateTime(new Date(), "hh:mm")
                color:          "white"
                font.pixelSize: 96
                font.bold:      true

                Timer {
                    interval: 1000
                    running:  true
                    repeat:   true
                    onTriggered: clockText.text = Qt.formatDateTime(new Date(), "hh:mm")
                }
            }

            TextField {
                id: passwordField
                anchors.horizontalCenter: parent.horizontalCenter
                width:           320
                echoMode:        TextInput.Password
                placeholderText: "Password"
                color:           "white"
                horizontalAlignment: TextInput.AlignHCenter

                background: Rectangle {
                    radius:       8
                    color:        Qt.rgba(1, 1, 1, 0.1)
                    border.color: Qt.rgba(1, 1, 1, 0.3)
                    border.width: 1
                }

                Keys.onReturnPressed: {
                    if (text.length > 0) {
                        pam.respond(text)
                        text = ""
                    }
                }
            }
        }
    }
}
