import QtQuick
import QtQuick.Layouts

Rectangle {
    Layout.alignment: Qt.AlignHCenter
    Layout.margins: 8
    implicitWidth: 48
    implicitHeight: 96
    radius: 8
    color: palette.mid
    border{
        width: 2
        color: palette.alternateBase
    }

    Column {
        anchors.centerIn: parent

        Text {
            id: hours
            anchors.horizontalCenter: parent.horizontalCenter
            color: palette.highlightedText
            font.pixelSize: 40
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            id: minutes
            anchors.horizontalCenter: parent.horizontalCenter
            color: palette.text
            font.pixelSize: 32
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
