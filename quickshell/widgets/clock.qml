import QtQuick
import "../config.js" as Config

Rectangle {
    implicitWidth: Config.bar.width
    implicitHeight: Config.bar.width*2
    color: Config.colors.bgLight

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date()
            hours.text = Qt.formatTime(now, "hh")
            minutes.text = Qt.formatTime(now, "mm")
        }
    }
    Column {
        anchors.centerIn: parent

        Text {
            id: hours
            color: Config.colors.fg
            font.family: Config.font.family
            font.pixelSize: Config.font.size*2
            font.bold: true
        }

        Text {
            id: minutes
            color: Qt.alpha(Config.colors.fgDark, 0.5)
            font.family: Config.font.family
            font.pixelSize: Config.font.size*2
        }
    }
}
