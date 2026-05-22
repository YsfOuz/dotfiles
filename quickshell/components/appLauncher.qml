import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import ".."

PanelWindow {
    id: root
    visible: false
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
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
            focusTimer.start()
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: searchInput.forceActiveFocus()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        anchors.centerIn: parent
        width: Settings.launcherWidth
        height: Settings.launcherHeight
        color: Settings.bg
        radius: Settings.borderRadius
        border { width: Settings.borderWidth; color: Settings.borderColor }

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent

            Rectangle {
                Layout.fillWidth: true
                Layout.margins: 8
                height: Settings.launcherItemHeight
                color: Settings.surface
                radius: Settings.borderRadius

                TextInput {
                    id: searchInput
                    anchors { fill: parent; margins: 8 }
                    color: Settings.text
                    verticalAlignment: TextInput.AlignVCenter

                    Keys.onEscapePressed: root.visible = false
                    Keys.onUpPressed: {
                        appList.currentIndex = Math.max(0, appList.currentIndex - 1)
                        appList.positionViewAtIndex(appList.currentIndex, ListView.Contain)
                    }
                    Keys.onDownPressed: {
                        appList.currentIndex = Math.min(root.filteredApps.length - 1, appList.currentIndex + 1)
                        appList.positionViewAtIndex(appList.currentIndex, ListView.Contain)
                    }
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
                    height: Settings.launcherItemHeight
                    radius: Settings.borderRadius
                    color: ListView.isCurrentItem ? Settings.accent : Settings.surface

                    RowLayout {
                        anchors { fill: parent; margins: 8 }

                        Image {
                            Layout.preferredWidth: Settings.launcherIconSize
                            Layout.preferredHeight: Settings.launcherIconSize
                            sourceSize.width: Settings.launcherIconSize
                            sourceSize.height: Settings.launcherIconSize
                            source: "image://icon/" + modelData.icon
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            color: ListView.isCurrentItem ? Settings.accentText : Settings.text
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: appList.currentIndex = index
                        onClicked: { modelData.execute(); root.visible = false }
                    }
                }
            }
        }
    }
}
