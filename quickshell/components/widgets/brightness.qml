import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    Layout.alignment: Qt.AlignHCenter
    Layout.margins: 8
    implicitWidth: 32
    implicitHeight: 48
    radius: 8
    color: palette.mid

    property int current: 0
    property int max: 1
    property int pct: max > 0 ? Math.round(current / max * 100) : 0

    Process {
        id: getProc
        command: ["brightnessctl", "g"]
        stdout: SplitParser {
            onRead: line => current = parseInt(line.trim()) || 0
        }
    }

    Process {
        id: getMax
        command: ["brightnessctl", "m"]
        running: true
        stdout: SplitParser {
            onRead: line => max = parseInt(line.trim()) || 1
        }
    }

    Process {
        id: setProc
        onRunningChanged: if (!running) { getProc.running = false; getProc.running = true }
    }

    Process {
        id: watchProc
        command: ["udevadm", "monitor", "--subsystem-match=backlight"]
        running: true
        stdout: SplitParser {
            onRead: _ => { getProc.running = false; getProc.running = true }
        }
    }

    Component.onCompleted: { getProc.running = false; getProc.running = true }

    Column {
        anchors.centerIn: parent

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: pct > 66 ? "󰃠" : pct > 33 ? "󰃟" : "󰃝"
            color: palette.windowText
            font.pixelSize: 16
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: pct + "%"
            color: palette.windowText
            font.pixelSize: 12
        }
    }

    MouseArea {
        anchors.fill: parent
        onWheel: wheel => {
            setProc.command = ["brightnessctl", "s", wheel.angleDelta.y > 0 ? "+5%" : "5%-", "--min-value", "5%"]
            setProc.running = false
            setProc.running = true
        }
    }
}
