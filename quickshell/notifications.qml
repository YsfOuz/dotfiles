import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts
import Quickshell.Services.Notifications

import "config.js" as Config
Scope {
    NotificationServer {
        id: server
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
        actionIconsSupported: true

        onNotification: n => n.tracked = true
    }

    PanelWindow {
        anchors { top: true; right: true }
        implicitWidth: Config.notifications.width
        implicitHeight: column.implicitHeight
        color: "transparent"

        ColumnLayout {
            id: column
            width: parent.width

            Repeater {
                model: server.trackedNotifications
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: layoutContainer.implicitHeight
                    color: Config.colors.bg
                    border {
                        width: 2
                        color: modelData.urgency === NotificationUrgency.Critical
                            ? Config.colors.urgent : Config.colors.bgLight
                    }

                    Timer {
                        running: modelData.urgency !== NotificationUrgency.Critical
                        interval: Config.notifications.timeout
                        onTriggered: modelData.dismiss()
                    }

                    ColumnLayout {
                        id: layoutContainer
                        width: parent.width
                        spacing: 8

                        RowLayout {
                            id: layout
                            width: parent.width
                            Layout.fillWidth: true
                            
                            Image {
                                Layout.preferredHeight: 48
                                Layout.preferredWidth: 48

                                visible: source.toString() !== ""
                                source: modelData.appIcon || modelData.image || ""
                            }

                        ColumnLayout {
                            Layout.fillWidth: true

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: modelData.summary
                                color: Config.colors.fgDark
                                font.family: Config.font.family
                                font.pixelSize: Config.font.size
                                wrapMode: Text.Wrap
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: modelData.body
                                color: Config.colors.fgDark
                                font.family: Config.font.family
                                font.pixelSize: Config.font.size
                                wrapMode: Text.Wrap
                            }
                        }
                    }

                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.maximumWidth: parent.width
                            Layout.maximumHeight: parent.width/2

                            visible: source.toString() !== ""
                            source: modelData.image || ""
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: modelData.dismiss()
                    }
                }
            }
        }
    }
}
