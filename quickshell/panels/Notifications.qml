import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import ".."

PanelWindow {
    id: root

    anchors.top:    Settings.notifAnchorTop
    anchors.bottom: Settings.notifAnchorBottom
    anchors.left:   Settings.notifAnchorLeft
    anchors.right:  Settings.notifAnchorRight
    margins.top:    Settings.notifAnchorTop    ? Settings.margin : 0
    margins.bottom: Settings.notifAnchorBottom ? Settings.margin : 0
    margins.left:   Settings.notifAnchorLeft   ? Settings.margin : 0
    margins.right:  Settings.notifAnchorRight  ? Settings.margin : 0

    implicitWidth:  Settings.notifWidth
    implicitHeight: Math.max(1, column.implicitHeight + Settings.padding * 2)

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusiveZone: 0
    color: "transparent"

    visible: notifModel.count > 0

    SystemPalette { id: palette }

    ListModel { id: notifModel }

    function add(notif) {
        notifModel.append({
            "summary": notif.summary  ?? "",
            "body":    notif.body     ?? "",
            "appName": notif.appName  ?? "",
            "appIcon": notif.appIcon  ?? "",
            "urgency": notif.urgency,
            "timeout": notif.expireTimeout > 0
                       ? notif.expireTimeout
                       : Settings.notifDefaultTimeout
        })
        notif.tracked = false
    }

    Column {
        id: column
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: Settings.padding }
        spacing: Settings.notifSpacing

        Repeater {
            model: notifModel

            delegate: Rectangle {
                width:          column.width
                implicitHeight: inner.implicitHeight + Settings.padding * 2
                radius:         Settings.cornerRadius
                color:          Qt.rgba(palette.window.r, palette.window.g, palette.window.b, Settings.opacity)
                border.width:   model.urgency === 2 ? 1.5 : Settings.borderWidth
                border.color:   model.urgency === 2
                                ? "#e05050"
                                : Qt.rgba(palette.mid.r, palette.mid.g, palette.mid.b, 0.5)

                Timer {
                    interval: model.timeout
                    running:  model.urgency !== 2
                    onTriggered: notifModel.remove(index)
                }

                RowLayout {
                    id: inner
                    anchors { top: parent.top; left: parent.left; right: parent.right; margins: Settings.padding }
                    spacing: 10

                    IconImage {
                        source: model.appIcon.startsWith("/") ? "file://" + model.appIcon
                              : model.appIcon !== ""          ? "image://icon/" + model.appIcon
                              :                                 ""
                        implicitSize: Settings.iconSize
                        smooth:  true
                        visible: model.appIcon !== "" && status === Image.Ready
                        Layout.alignment: Qt.AlignTop
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text:           model.summary
                                font.pixelSize: Settings.fontSize
                                font.bold:      true
                                color:          palette.text
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text:           model.appName
                                font.pixelSize: Settings.fontSize - 3
                                color:          palette.placeholderText
                                visible:        model.appName !== ""
                                elide:          Text.ElideRight
                                Layout.maximumWidth: 80
                            }

                            Button {
                                text:           "\uf00d"
                                flat:           true
                                implicitWidth:  24
                                implicitHeight: 24
                                font.pixelSize: 11
                                padding:        0
                                onClicked:      notifModel.remove(index)
                            }
                        }

                        Text {
                            text:           model.body
                            font.pixelSize: Settings.fontSize - 2
                            color:          palette.placeholderText
                            Layout.fillWidth: true
                            wrapMode:       Text.WordWrap
                            visible:        model.body !== ""
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: notifModel.remove(index)
                    z: -1
                }
            }
        }
    }
}
