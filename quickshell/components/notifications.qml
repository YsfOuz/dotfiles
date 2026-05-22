import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root

    property var activeNotifs: []
    property var notifHeights: []
    property int heightsVersion: 0

    function topOffset(idx) {
        var _ = root.heightsVersion
        var top = 8
        for (var i = 0; i < idx; i++)
            top += (root.notifHeights[i] || 80) + 8
        return top
    }

    function dismiss(notif) {
        var idx = root.activeNotifs.indexOf(notif)
        if (idx < 0) return
        notif.tracked = false
        root.activeNotifs = root.activeNotifs.filter((_, i) => i !== idx)
        root.notifHeights = root.notifHeights.filter((_, i) => i !== idx)
        root.heightsVersion++
    }

    NotificationServer {
        keepOnReload: false
        onNotification: notif => {
            notif.tracked = true
            root.activeNotifs = root.activeNotifs.concat([notif])
            root.notifHeights = root.notifHeights.concat([80])
        }
    }

    Variants {
        model: root.activeNotifs

        delegate: PanelWindow {
            required property var modelData

            property int myIndex: {
                var _ = root.activeNotifs
                return root.activeNotifs.indexOf(modelData)
            }

            color: "transparent"
            anchors { top: true; right: true }
            margins { top: root.topOffset(myIndex); right: 8 }
            implicitWidth: Settings.notifWidth
            implicitHeight: notifCard.height
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            onImplicitHeightChanged: {
                if (myIndex >= 0 && myIndex < root.notifHeights.length) {
                    var h = root.notifHeights.slice()
                    h[myIndex] = implicitHeight
                    root.notifHeights = h
                    root.heightsVersion++
                }
            }

            Rectangle {
                id: notifCard
                width: Settings.notifWidth
                height: cardLayout.implicitHeight + 16
                radius: Settings.borderRadius

                color: Settings.bg
                border {
                    width: Settings.borderWidth
                    color: modelData.urgency === 2 ? Settings.danger : Settings.borderColor
                }

                property var notif: modelData

                property int progressValue: {
                    if (!modelData.hints) return -1
                    var v = modelData.hints["value"]
                    return (v !== undefined && v >= 0 && v <= 100) ? parseInt(v) : -1
                }

                Timer {
                    interval: modelData.expireTimeout > 0 ? modelData.expireTimeout : Settings.notifDefaultTimeout
                    running: modelData.expireTimeout > 0
                    onTriggered: root.dismiss(modelData)
                }

                ColumnLayout {
                    id: cardLayout
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Item {
                            width: 32; height: 32

                            Image {
                                id: iconImg
                                anchors.fill: parent
                                source: {
                                    var icon = modelData.appIcon || ""
                                    if (!icon) return ""
                                    if (icon.startsWith("/") || icon.startsWith("file://")) return icon
                                    return "image://icon/" + icon
                                }
                                fillMode: Image.PreserveAspectFit
                                visible: status === Image.Ready
                            }

                            Rectangle {
                                anchors.fill: parent
                                visible: !iconImg.visible
                                radius: Settings.borderRadius
                                color: Settings.accent
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.appName ? modelData.appName[0].toUpperCase() : "?"
                                    color: Settings.accentText
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        Text {
                            text: modelData.appName
                            color: Settings.subtext
                            font.pixelSize: 12
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "✕"
                            color: Settings.text
                            opacity: closeArea.containsMouse ? 1 : 0.5
                            font.pixelSize: 12
                            MouseArea {
                                id: closeArea
                                anchors { fill: parent; margins: -8 }
                                hoverEnabled: true
                                onClicked: root.dismiss(modelData)
                            }
                        }
                    }

                    Text {
                        text: modelData.summary
                        color: Settings.text
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        visible: text !== ""
                    }

                    Text {
                        text: modelData.body
                        color: Settings.text
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        visible: text !== ""
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        visible: notifCard.progressValue >= 0

                        Rectangle {
                            Layout.fillWidth: true
                            height: 4
                            radius: Settings.borderRadius
                            color: Settings.surface

                            Rectangle {
                                width: parent.width * (notifCard.progressValue / 100)
                                height: parent.height
                                radius: parent.radius
                                color: Settings.accent
                                Behavior on width { NumberAnimation { duration: 100 } }
                            }
                        }

                        Text {
                            text: notifCard.progressValue + "%"
                            color: Settings.text
                            font.pixelSize: 10
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: modelData.actions && modelData.actions.length > 0

                        Repeater {
                            model: modelData.actions

                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                height: 32
                                radius: Settings.borderRadius
                                color: actionArea.containsMouse ? Settings.accent : Settings.surface
                                border { width: 1; color: Settings.borderColor }

                                MouseArea {
                                    id: actionArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        modelData.invoke()
                                        root.dismiss(notifCard.notif)
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.text
                                    color: actionArea.containsMouse ? Settings.accentText : Settings.text
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
