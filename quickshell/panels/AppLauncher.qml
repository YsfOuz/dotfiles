import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import ".."

PanelWindow {
    id: root
    visible: false
    implicitWidth:  Settings.launcherWidth
    implicitHeight: Settings.launcherHeight
    color: "transparent"

    anchors.left:   Settings.launcherAnchorLeft
    anchors.right:  Settings.launcherAnchorRight
    anchors.top:    Settings.launcherAnchorTop
    anchors.bottom: Settings.launcherAnchorBottom

    margins.top:    Settings.margin
    margins.bottom: Settings.margin
    margins.left:   Settings.margin
    margins.right:  Settings.margin

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusiveZone: 0

    SystemPalette { id: palette; colorGroup: SystemPalette.Active }

    Process { id: termProc }

    function toggle() {
        if (root.visible) {
            root.visible = false
        } else {
            searchField.text = ""
            appList.currentIndex = 0
            root.visible = true
            searchField.forceActiveFocus()
        }
    }

    function launch(app) {
        if (app.runInTerminal) {
            termProc.exec([Settings.terminal].concat(Settings.terminalArgs).concat(app.command))
        } else {
            app.execute()
        }
        root.visible = false
    }

    function launchCurrent() {
        var apps = appList.model
        if (!apps || apps.length === 0) return
        var idx = appList.currentIndex >= 0 ? appList.currentIndex : 0
        if (idx < apps.length) root.launch(apps[idx])
    }

    function buildAppList(query) {
        var entries = DesktopEntries.applications.values
        if (!entries) return []
        var q = query.toLowerCase()
        var result = []
        for (var i = 0; i < entries.length; i++) {
            var app = entries[i]
            if (app.noDisplay || !app.name) continue
            if (q === ""
                    || app.name.toLowerCase().indexOf(q) !== -1
                    || (app.genericName && app.genericName.toLowerCase().indexOf(q) !== -1)
                    || (app.comment && app.comment.toLowerCase().indexOf(q) !== -1)) {
                result.push(app)
            }
        }
        result.sort((a, b) => a.name.localeCompare(b.name))
        return result
    }

    function resolveIcon(icon) {
        if (!icon) return ""
        if (icon.startsWith("/")) return "file://" + icon
        if (icon.indexOf("://") !== -1) return icon
        return "image://icon/" + icon
    }

    Rectangle {
        anchors.fill: parent
        color:        Qt.rgba(palette.window.r, palette.window.g, palette.window.b, Settings.opacity)
        border.color: palette.mid
        border.width: Settings.borderWidth
        radius:       Settings.cornerRadius
        focus:        true

        Keys.onEscapePressed: root.visible = false

        ColumnLayout {
            anchors { fill: parent; margins: Settings.padding }
            spacing: Settings.spacing

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search applications…"
                font.pixelSize: Settings.searchFontSize
                leftPadding: 10
                focus: true
                background: Item {}

                onTextChanged: {
                    appList.model = root.buildAppList(text)
                    appList.currentIndex = 0
                }

                Keys.onEscapePressed: root.visible = false
                Keys.onReturnPressed: root.launchCurrent()
                Keys.onDownPressed: {
                    if (appList.count > 0) {
                        appList.currentIndex = Math.min(appList.currentIndex + 1, appList.count - 1)
                        appList.forceActiveFocus()
                    }
                }
            }

            ListView {
                id: appList
                Layout.fillWidth:  true
                Layout.fillHeight: true
                clip: true
                currentIndex: 0
                keyNavigationEnabled: true
                model: root.buildAppList("")

                highlight: Rectangle {
                    color:  palette.highlight
                    radius: Settings.cornerRadius - 2
                }
                highlightMoveDuration: 80

                Keys.onEscapePressed: root.visible = false
                Keys.onReturnPressed: root.launchCurrent()
                Keys.onUpPressed: {
                    if (currentIndex > 0) currentIndex--
                    else searchField.forceActiveFocus()
                }

                delegate: ItemDelegate {
                    id: delegateItem
                    width:       appList.width
                    height:      Settings.itemHeight
                    padding:     0
                    highlighted: appList.currentIndex === index
                    background:  Item {}

                    onClicked: root.launch(modelData)

                    contentItem: RowLayout {
                        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                        spacing: 10

                        Rectangle {
                            implicitWidth:  Settings.iconSize
                            implicitHeight: Settings.iconSize
                            radius: 4
                            color: Qt.rgba(palette.highlight.r, palette.highlight.g,
                                           palette.highlight.b, 0.15)
                            visible: iconImg.status !== Image.Ready

                            Text {
                                anchors.centerIn: parent
                                text:           modelData.name.charAt(0).toUpperCase()
                                font.pixelSize: Settings.iconSize * 0.5
                                font.bold:      true
                                color:          palette.highlight
                            }
                        }

                        IconImage {
                            id: iconImg
                            source:         root.resolveIcon(modelData.icon)
                            implicitWidth:  Settings.iconSize
                            implicitHeight: Settings.iconSize
                            implicitSize:   Settings.iconSize
                            smooth:  true
                            visible: status === Image.Ready
                        }

                        Label {
                            text:           modelData.name
                            font.pixelSize: Settings.fontSize
                            color: delegateItem.highlighted ? palette.highlightedText : palette.text
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Label {
                            text: (modelData.genericName && modelData.genericName !== modelData.name)
                                  ? modelData.genericName : ""
                            font.pixelSize: Settings.fontSize - 2
                            color: delegateItem.highlighted
                                ? Qt.rgba(palette.highlightedText.r, palette.highlightedText.g,
                                          palette.highlightedText.b, 0.6)
                                : palette.placeholderText
                            visible: text !== ""
                            elide: Text.ElideRight
                            Layout.maximumWidth: 160
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {}
            }

            Label {
                text:           appList.count + " app" + (appList.count !== 1 ? "s" : "")
                font.pixelSize: Settings.fontSize - 2
                color:          palette.placeholderText
                Layout.alignment: Qt.AlignRight
                bottomPadding: 2
            }
        }
    }
}
