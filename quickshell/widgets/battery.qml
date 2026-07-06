import QtQuick
import Quickshell
import Quickshell.Services.UPower
import QtQuick.Layouts
import "../config.js" as Config

Rectangle {
    implicitWidth: Config.bar.width - Layout.margins*2
    implicitHeight: widget.height
    color: Config.colors.bgLight
    Layout.margins: 8
    ColumnLayout {
        id: widget
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        readonly property int percentage: UPower.displayDevice.percentage * 100
        Text {
            color: Config.colors.fg
            font.pixelSize: Config.font.size
            text: {
                switch (UPower.displayDevice.state) {
                    case 5: return "󰁹"
                    case 1: return "󰂄"
                    case 2:
                        if (col.percentage > 90) return "󰂂"
                        if (col.percentage > 80) return "󰂁"
                        if (col.percentage > 70) return "󰂀"
                        if (col.percentage > 60) return "󰁿"
                        if (col.percentage > 50) return "󰁾"
                        if (col.percentage > 40) return "󰁽"
                        if (col.percentage > 30) return "󰁼"
                        if (col.percentage > 20) return "󰁻"
                        if (col.percentage > 10) return "󰁺"
                    default: return "󱟨"
                }
            }
        }
        Text {
            text: UPower.displayDevice ? widget.percentage + "%" : "?"
            color: Config.colors.fg
            font.pixelSize: Config.font.size
        }
    }
}
