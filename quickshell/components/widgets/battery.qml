import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

Rectangle {
    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
    Layout.margins: 8
    visible: UPower.displayDevice ? UPower.displayDevice.isLaptopBattery : false

    implicitWidth: 32
    implicitHeight: 48
    radius: 8
    color: palette.mid

    Column {
        id: root
        anchors.centerIn: parent
        readonly property int percentage: UPower.displayDevice.percentage*100

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                switch(UPower.displayDevice.state){
                    case 5:
                        return "󰂄";
                    case 1:
                        return "󰁹"
                    case 2:
                        if(root.percentage > 90) { return "󰂂"; }
                        if(root.percentage > 80) { return "󰂁"; }
                        if(root.percentage > 70) { return "󰂀"; }
                        if(root.percentage > 60) { return "󰁿"; }
                        if(root.percentage > 50) { return "󰁾"; }
                        if(root.percentage > 40) { return "󰁽"; }
                        if(root.percentage > 30) { return "󰁼"; }
                        if(root.percentage > 20) { return "󰁻"; }
                        if(root.percentage > 10) { return "󰁺"; }
                    default:
                        return "󱟨";
                }
            }
            color: palette.windowText
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: UPower.displayDevice ? root.percentage + "%" : "?"
            color: palette.windowText
            font.pointSize: 8
        }
    }
}
