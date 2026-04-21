import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."

PanelWindow {
    id: root

    property bool menuVisible: false
    visible: menuVisible
    function toggle() { menuVisible = !menuVisible }

    anchors.top:    Settings.powerMenuAnchorTop
    anchors.bottom: Settings.powerMenuAnchorBottom
    anchors.left:   Settings.powerMenuAnchorLeft
    anchors.right:  Settings.powerMenuAnchorRight
    margins.top:    Settings.powerMenuMarginTop
    margins.bottom: Settings.powerMenuMarginBottom
    margins.left:   Settings.powerMenuMarginLeft
    margins.right:  Settings.powerMenuMarginRight

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusiveZone: 0
    color: "transparent"

    implicitWidth:  box.implicitWidth  + Settings.padding * 2
    implicitHeight: box.implicitHeight + Settings.padding * 2

    SystemPalette { id: palette }

    Process { id: cmdProc }

    Rectangle {
        id: box
        anchors.centerIn: parent
        implicitWidth:  row.implicitWidth  + Settings.padding * 4
        implicitHeight: row.implicitHeight + Settings.padding * 4
        radius:       Settings.cornerRadius
        color:        Qt.rgba(palette.window.r, palette.window.g, palette.window.b, Settings.opacity)
        border.width: Settings.borderWidth
        border.color: Qt.rgba(palette.mid.r, palette.mid.g, palette.mid.b, 0.5)
        focus: true

        Keys.onEscapePressed: root.menuVisible = false

        Row {
            id: row
            anchors.centerIn: parent
            spacing: Settings.padding

            Repeater {
                model: Settings.powerMenuActions

                delegate: Column {
                    spacing: 8

                    Rectangle {
                        width:  Settings.powerMenuButtonSize
                        height: Settings.powerMenuButtonSize
                        radius: Settings.cornerRadius
                        color: area.containsMouse
                               ? (modelData.accent !== "" ? modelData.accent : palette.highlight)
                               : Qt.rgba(palette.mid.r, palette.mid.g, palette.mid.b, 0.3)

                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text:           modelData.icon
                            font.pixelSize: Settings.powerMenuIconSize
                            color: area.containsMouse ? "white" : palette.text
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        MouseArea {
                            id: area
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.menuVisible = false
                                cmdProc.exec(modelData.cmd)
                            }
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:           modelData.label
                        color:          palette.text
                        font.pixelSize: Settings.fontSize - 2
                    }
                }
            }
        }
    }
}
