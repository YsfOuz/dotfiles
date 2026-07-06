import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import "config.js" as Config

PanelWindow {
    id: root

    readonly property int searchHeight: 48
    readonly property int rowHeight: 48
    readonly property int maxRows: 8
    readonly property int iconSize: 32
    readonly property int pad: 8

    property string query: ""
    readonly property var results: {
        const q = query.trim().toLowerCase();
        const apps = DesktopEntries.applications.values.filter(a => !a.runInTerminal);
        const matched = q ? apps.filter(a => a.name.toLowerCase().includes(q)) : apps;
        return matched.slice().sort((a, b) => a.name.localeCompare(b.name));
    }

    function move(delta) {
        list.currentIndex = Math.max(0, Math.min(results.length - 1, list.currentIndex + delta));
        list.positionViewAtIndex(list.currentIndex, ListView.Contain);
    }

    function activate() {
        const entry = results[list.currentIndex];
        if (!entry)
            return;
        entry.execute();
        visible = false;
    }

    visible: false
    color: "transparent"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "launcher"
    anchors { top: true; left: true; right: true; bottom: true }

    onVisibleChanged: {
        if (!visible)
            return;
        field.text = "";
        query = "";
        list.currentIndex = 0;
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { root.visible = !root.visible }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: Config.launcher.width
        height: column.implicitHeight
        color: Config.colors.bg
        border { width: 2; color: Config.colors.bgLight }

        MouseArea { anchors.fill: parent }

        Column {
            id: column
            width: parent.width

            TextInput {
                id: field
                focus: true
                width: parent.width
                height: root.searchHeight
                leftPadding: root.pad
                rightPadding: root.pad
                verticalAlignment: TextInput.AlignVCenter
                color: Config.colors.fgDark
                font.family: Config.font.family
                font.pixelSize: Config.font.size

                onTextChanged: { root.query = text; list.currentIndex = 0 }
                Keys.onEscapePressed: root.visible = false
                Keys.onUpPressed: root.move(-1)
                Keys.onDownPressed: root.move(1)
                Keys.onReturnPressed: root.activate()
                Keys.onEnterPressed: root.activate()
            }

            ListView {
                id: list
                width: parent.width
                height: Math.min(contentHeight, root.maxRows * root.rowHeight)
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: root.results

                delegate: Item {
                    required property var modelData
                    required property int index

                    width: ListView.view.width
                    height: root.rowHeight

                    Rectangle {
                        anchors.fill: parent
                        color: index === list.currentIndex ? Config.colors.bgLight : "transparent"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: list.currentIndex = index
                        onClicked: { list.currentIndex = index; root.activate() }
                    }

                    Row {
                        anchors {
                            left: parent.left; right: parent.right
                            leftMargin: root.pad; rightMargin: root.pad
                        }
                        height: parent.height
                        spacing: root.pad

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            width: root.iconSize
                            height: root.iconSize
                            sourceSize.width: root.iconSize
                            sourceSize.height: root.iconSize
                            source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - root.iconSize - parent.spacing
                            text: modelData.name
                            color: Config.colors.fgDark
                            font.family: Config.font.family
                            font.pixelSize: Config.font.size
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
