import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../.."

Rectangle {
    visible: UPower.displayDevice ? UPower.displayDevice.isLaptopBattery : false
    implicitWidth: Settings.widgetSize
    implicitHeight: Settings.widgetSize + 16
    radius: Settings.borderRadius

    color: Settings.surface

    Column {
        id: col
        anchors.centerIn: parent
        readonly property int percentage: UPower.displayDevice.percentage * 100

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Settings.text
            font.pixelSize: Settings.iconFont
            text: {
                switch (UPower.displayDevice.state) {
                    case 5: return "󰂄"
                    case 1: return "󰁹"
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
            anchors.horizontalCenter: parent.horizontalCenter
            text: UPower.displayDevice ? col.percentage + "%" : "?"
            color: Settings.text
            font.pixelSize: Settings.labelFont
        }
    }
}
