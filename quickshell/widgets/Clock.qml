import QtQuick
import ".."

Item {
    implicitWidth:  col.implicitWidth
    implicitHeight: col.implicitHeight

    SystemPalette { id: palette }

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            hourLabel.text   = Qt.formatTime(new Date(), "HH")
            minuteLabel.text = Qt.formatTime(new Date(), "mm")
        }
    }

    Column {
        id: col
        spacing: 0
        anchors.centerIn: parent

        Text {
            id: hourLabel
            anchors.horizontalCenter: parent.horizontalCenter
            text:           Qt.formatTime(new Date(), "HH")
            color:          palette.text
            font.pixelSize: Settings.clockHourSize
            font.bold:      true
        }

        Text {
            id: minuteLabel
            anchors.horizontalCenter: parent.horizontalCenter
            text:           Qt.formatTime(new Date(), "mm")
            color:          palette.placeholderText
            font.pixelSize: Settings.clockMinuteSize
        }
    }
}
