import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import ".."

PanelWindow {
    id: root
    visible: agent.isActive
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    PolkitAgent {
        id: agent
        path: "/org/quickshell/polkit"

        onFlowChanged: {
            if (!flow) return
            if (flow.identities.length > 0)
                flow.selectedIdentity = flow.identities[0]
            passwordInput.text = ""
            focusTimer.start()
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: passwordInput.forceActiveFocus()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: if (agent.flow) agent.flow.cancelAuthenticationRequest()
    }

    Rectangle {
        anchors.centerIn: parent
        width: Settings.polkitWidth
        height: dialogLayout.implicitHeight + 32
        color: Settings.bgT
        radius: Settings.borderRadius
        border { width: Settings.borderWidth; color: Settings.borderColor }

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: dialogLayout
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Authentication Required"
                color: Settings.text
                font.pixelSize: 24
                font.weight: Font.Bold
            }

            Text {
                Layout.fillWidth: true
                visible: agent.flow && agent.flow.message !== ""
                text: agent.flow ? agent.flow.message : ""
                color: Settings.text
                font.pixelSize: 16
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                visible: agent.flow && agent.flow.supplementaryMessage !== ""
                text: agent.flow ? agent.flow.supplementaryMessage : ""
                color: agent.flow && agent.flow.supplementaryIsError ? Settings.danger : Settings.subtext
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                visible: agent.flow && agent.flow.isResponseRequired && agent.flow.inputPrompt !== ""
                text: agent.flow ? agent.flow.inputPrompt : ""
                color: Settings.text
                font.pixelSize: 16
            }

            Rectangle {
                Layout.fillWidth: true
                visible: agent.flow && agent.flow.isResponseRequired
                height: 32
                radius: Settings.borderRadius
                color: Settings.surfaceT
                border {
                    width: Settings.borderWidth
                    color: passwordInput.activeFocus ? Settings.accent : Settings.borderColor
                }

                TextInput {
                    id: passwordInput
                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 10 }
                    echoMode: agent.flow && agent.flow.responseVisible ? TextInput.Normal : TextInput.Password
                    color: Settings.text
                    font.pixelSize: 16
                    Keys.onReturnPressed: { agent.flow.submit(text); text = "" }
                    Keys.onEscapePressed: if (agent.flow) agent.flow.cancelAuthenticationRequest()
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    implicitWidth: 100; implicitHeight: 32
                    radius: Settings.borderRadius
                    color: cancelMa.containsMouse ? Settings.accent : Settings.surfaceT

                    MouseArea {
                        id: cancelMa
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: if (agent.flow) agent.flow.cancelAuthenticationRequest()
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: cancelMa.containsMouse ? Settings.accentText : Settings.text
                        font.pixelSize: 16
                    }
                }

                Rectangle {
                    implicitWidth: 128; implicitHeight: 32
                    radius: Settings.borderRadius
                    visible: agent.flow && agent.flow.isResponseRequired
                    color: authMa.containsMouse ? Settings.accent : Settings.surfaceT

                    MouseArea {
                        id: authMa
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: { agent.flow.submit(passwordInput.text); passwordInput.text = "" }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Authenticate"
                        color: authMa.containsMouse ? Settings.accentText : Settings.text
                        font.pixelSize: 16
                    }
                }
            }
        }
    }
}
