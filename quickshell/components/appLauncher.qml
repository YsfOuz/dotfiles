import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    visible: false
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "applauncher"

    readonly property var filteredApps: {
        let query = searchInput.text.toLowerCase()
        return DesktopEntries.applications.values.filter(app =>
            !app.noDisplay && (query === "" || app.name.toLowerCase().includes(query))
        )
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { root.visible = !root.visible }
    }

    onVisibleChanged: {
        if (visible) {
            searchInput.text = ""
            appList.currentIndex = 0
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

        Rectangle {
            anchors.centerIn: parent
            width: 480
            height: 640
            color: palette.window
            radius: 8
            border {
                width: 2
                color: palette.alternateBase
            }

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    color: palette.alternateBase
                    radius: 8
                    Layout.margins: 8

                    TextInput {
                        id: searchInput
                        anchors.fill: parent
                        anchors.margins: 8
                        color: palette.windowText
                        verticalAlignment: TextInput.AlignVCenter
                        focus: true

                        Keys.onEscapePressed: root.visible = false
                        Keys.onUpPressed: appList.currentIndex = Math.max(0, appList.currentIndex - 1)
                        Keys.onDownPressed: appList.currentIndex = Math.min(root.filteredApps.length - 1, appList.currentIndex + 1)
                        Keys.onReturnPressed: {
                            if (root.filteredApps.length > 0) {
                                root.filteredApps[appList.currentIndex].execute()
                                root.visible = false
                            }
                        }
                    }
                }

                ListView {
                    id: appList
                    Layout.margins: 8
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: root.filteredApps
                    clip: true
                    spacing: 8

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: parent.width
                        height: 48
                        radius: 8
                        color: ListView.isCurrentItem ? palette.highlight : palette.mid

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            Image {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                sourceSize.width: 32
                                sourceSize.height: 32
                                source: "image://icon/" + modelData.icon
                                fillMode: Image.PreserveAspectFit
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                color: ListView.isCurrentItem ? palette.highlightedText : palette.windowText
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: appList.currentIndex = index
                            onClicked: {
                                modelData.execute()
                                root.visible = false
                            }
                        }
                    }
                }
            }
        }
}
