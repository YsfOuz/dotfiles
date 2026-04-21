import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."

PanelWindow {
    id: root

    property bool   osdVisible: false
    property string osdType:    "volume"
    property real   volume:     0
    property bool   muted:      false
    property real   brightness: 0

    visible: osdVisible

    anchors.top:    Settings.osdAnchorTop
    anchors.bottom: Settings.osdAnchorBottom
    anchors.left:   Settings.osdAnchorLeft
    anchors.right:  Settings.osdAnchorRight
    margins.top:    Settings.osdMarginTop
    margins.bottom: Settings.osdMarginBottom
    margins.left:   Settings.osdMarginLeft
    margins.right:  Settings.osdMarginRight

    implicitWidth:  Settings.osdWidth
    implicitHeight: Settings.osdHeight

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusiveZone: 0
    color: "transparent"

    SystemPalette { id: palette }

    Process {
        id: audioQuery
        stdout: SplitParser {
            onRead: line => {
                var m = line.match(/Volume:\s*([\d.]+)/)
                if (m) {
                    root.volume = parseFloat(m[1])
                    root.muted  = line.indexOf("[MUTED]") !== -1
                    root.osdVisible = true
                    hideTimer.restart()
                }
            }
        }
    }

    Process {
        id: brightnessQuery
        stdout: SplitParser {
            onRead: line => {
                var parts = line.split(",")
                if (parts.length >= 4) {
                    var pct = parseInt(parts[3])
                    if (!isNaN(pct)) {
                        root.brightness = pct / 100.0
                        root.osdVisible = true
                        hideTimer.restart()
                    }
                }
            }
        }
    }

    function showOsd(type) {
        root.osdType = type
        if (type === "volume")
            audioQuery.exec(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"])
        else if (type === "mic")
            audioQuery.exec(["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"])
        else if (type === "brightness")
            brightnessQuery.exec(["brightnessctl", "-m"])
    }

    Timer {
        id: hideTimer
        interval: Settings.osdTimeout
        onTriggered: root.osdVisible = false
    }

    Rectangle {
        anchors.fill: parent
        color:        Qt.rgba(palette.window.r, palette.window.g, palette.window.b, Settings.opacity)
        radius:       Settings.cornerRadius
        border.color: Qt.rgba(palette.mid.r, palette.mid.g, palette.mid.b, 0.5)
        border.width: Settings.borderWidth

        RowLayout {
            anchors { fill: parent; margins: Settings.padding }
            spacing: 12

            Text {
                text: {
                    if (root.osdType === "brightness") return "󰃠"
                    if (root.osdType === "mic")
                        return root.muted ? "󰍭" : "󰍬"
                    return root.muted         ? "󰝟"
                         : root.volume <= 0   ? "󰕿"
                         : root.volume <= 0.5 ? "󰖀"
                         :                      "󰕾"
                }
                font.pixelSize: 22
                color:          palette.text
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                ProgressBar {
                    Layout.fillWidth: true
                    from: 0; to: 1
                    value: root.osdType === "brightness" ? root.brightness
                         : root.muted                   ? 0
                         : Math.min(root.volume, 1.0)
                    background: Item {}
                }

                Text {
                    text: {
                        if (root.osdType === "brightness")
                            return Math.round(root.brightness * 100) + "%"
                        if (root.muted)
                            return root.osdType === "mic" ? "Mic muted" : "Muted"
                        return Math.round(root.volume * 100) + "%"
                    }
                    font.pixelSize: Settings.fontSize - 2
                    color:          palette.text
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
