import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../.."

ColumnLayout {
    Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
    Layout.margins: 8

    property var tags: []

    Repeater {
        model: 9
        Rectangle {
            readonly property var tag: tags.length > index ? tags[index] : null
            readonly property bool isFocused: tag ? tag.focused : false
            readonly property bool isOccupied: tag ? tag.occupied : false
            readonly property bool isUrgent:  tag ? tag.urgent  : false

            visible: isFocused || isOccupied || index < 4
            implicitWidth: 32
            implicitHeight: 32
            radius: Settings.borderRadius
            color: isUrgent ? Settings.urgent : isFocused ? Settings.accent : Settings.surface

            Text {
                anchors.centerIn: parent
                text: index + 1
                color: isFocused ? Settings.accentText : Settings.text
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    tagSetter.command = ["riverctl", "set-focused-tags", (1 << index).toString()]
                    tagSetter.running = true
                }
            }
        }
    }

    Process {
        id: tagSetter
        running: false
    }

    Process {
        command: ["river-bedload", "-watch", "tags", "-minified"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                tags = JSON.parse(data).slice(0, 9)
            }
        }
    }
}
