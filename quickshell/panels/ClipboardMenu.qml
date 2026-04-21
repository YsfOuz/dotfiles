import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."

PanelWindow {
    id: root
    visible: false
    color: "transparent"

    implicitWidth:  Settings.clipboardWidth
    implicitHeight: Settings.clipboardHeight

    anchors.top:    Settings.clipboardAnchorTop
    anchors.bottom: Settings.clipboardAnchorBottom
    anchors.left:   Settings.clipboardAnchorLeft
    anchors.right:  Settings.clipboardAnchorRight
    margins.top:    Settings.clipboardAnchorTop    ? Settings.margin : 0
    margins.bottom: Settings.clipboardAnchorBottom ? Settings.margin : 0
    margins.left:   Settings.clipboardAnchorLeft   ? Settings.margin : 0
    margins.right:  Settings.clipboardAnchorRight  ? Settings.margin : 0

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusiveZone: 0

    SystemPalette { id: palette }

    ListModel { id: clipModel }

    Process {
        id: listProc
        stdout: SplitParser {
            onRead: line => {
                var tab = line.indexOf("\t")
                if (tab === -1) return
                var entryId = line.substring(0, tab)
                var content = line.substring(tab + 1).trim()
                if (clipModel.count < Settings.clipboardMaxItems)
                    clipModel.append({ entryId: entryId, content: content })
            }
        }
    }

    Process { id: copyProc }
    Process { id: deleteProc }

    function toggle() {
        if (root.visible) {
            root.visible = false
        } else {
            clipModel.clear()
            searchField.text = ""
            listProc.exec(["cliphist", "list"])
            root.visible = true
            searchField.forceActiveFocus()
        }
    }

    Rectangle {
        anchors.fill: parent
        color:        Qt.rgba(palette.window.r, palette.window.g, palette.window.b, Settings.opacity)
        radius:       Settings.cornerRadius
        border.width: Settings.borderWidth
        border.color: Qt.rgba(palette.mid.r, palette.mid.g, palette.mid.b, 0.5)

        Keys.onEscapePressed: root.visible = false

        ColumnLayout {
            anchors { fill: parent; margins: Settings.padding }
            spacing: Settings.spacing

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Search clipboard…"
                font.pixelSize: Settings.fontSize
                leftPadding: 10
                background: Item {}

                Keys.onEscapePressed: root.visible = false
                Keys.onReturnPressed: {
                    if (clipList.currentItem) clipList.currentItem.copyEntry()
                }
                Keys.onDownPressed: {
                    clipList.forceActiveFocus()
                    clipList.currentIndex = 0
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(palette.mid.r, palette.mid.g, palette.mid.b, 0.4)
            }

            ListView {
                id: clipList
                Layout.fillWidth:  true
                Layout.fillHeight: true
                clip: true
                currentIndex: -1
                keyNavigationEnabled: true
                spacing: 2
                model: clipModel

                highlight: Rectangle {
                    color:  palette.highlight
                    radius: Settings.cornerRadius - 2
                }
                highlightMoveDuration: 80

                Keys.onEscapePressed: root.visible = false
                Keys.onReturnPressed: { if (currentItem) currentItem.copyEntry() }
                Keys.onUpPressed: {
                    if (currentIndex > 0) currentIndex--
                    else searchField.forceActiveFocus()
                }

                delegate: ItemDelegate {
                    id: delegateItem
                    width:       clipList.width
                    height:      Settings.itemHeight
                    padding:     0
                    highlighted: clipList.currentIndex === index
                    background:  Item {}

                    function copyEntry() {
                        copyProc.exec(["sh", "-c",
                            "cliphist decode " + model.entryId + " | wl-copy"])
                        root.visible = false
                    }

                    visible: searchField.text === "" ||
                             model.content.toLowerCase().indexOf(
                                 searchField.text.toLowerCase()) !== -1

                    onClicked: copyEntry()

                    contentItem: RowLayout {
                        anchors { fill: parent; leftMargin: 10; rightMargin: 6 }
                        spacing: 8

                        Text {
                            Layout.fillWidth: true
                            text:           model.content
                            color: delegateItem.highlighted ? palette.highlightedText : palette.text
                            font.pixelSize: Settings.fontSize - 2
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            text:           "\uf014"
                            font.pixelSize: Settings.fontSize - 4
                            color: delegateItem.highlighted
                                   ? Qt.rgba(palette.highlightedText.r,
                                             palette.highlightedText.g,
                                             palette.highlightedText.b, 0.6)
                                   : palette.placeholderText
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    deleteProc.exec(["sh", "-c",
                                        "printf '%s\\t%s' " + model.entryId +
                                        " '" + model.content.replace(/'/g, "'\\''") +
                                        "' | cliphist delete"])
                                    clipModel.remove(index)
                                }
                            }
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {}
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text:           clipModel.count + " item" + (clipModel.count !== 1 ? "s" : "")
                    font.pixelSize: Settings.fontSize - 4
                    color:          palette.placeholderText
                }

                Item { Layout.fillWidth: true }

                Text {
                    text:           "\uf1f8  Clear all"
                    font.pixelSize: Settings.fontSize - 4
                    color:          palette.placeholderText
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            deleteProc.exec(["cliphist", "wipe"])
                            clipModel.clear()
                        }
                    }
                }
            }
        }
    }
}
