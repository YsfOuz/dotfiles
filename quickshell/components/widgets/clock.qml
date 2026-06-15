import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    implicitWidth: Settings.barWidth
    implicitHeight: Settings.clockH
    radius: Settings.borderRadius

    color: Settings.surfaceT
    border {
        width: Settings.borderWidth
        color: Settings.borderColor
    }

    Column {
        anchors.centerIn: parent

        Text {
            id: hours
            anchors.horizontalCenter: parent.horizontalCenter
            color: Settings.text
            font.pixelSize: Settings.clockHourFont
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            id: minutes
            anchors.horizontalCenter: parent.horizontalCenter
            color: Settings.subtext
            font.pixelSize: Settings.clockMinFont
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            hours.text = Qt.formatDateTime(now, "hh")
            minutes.text = Qt.formatDateTime(now, "mm")
        }
    }
}
