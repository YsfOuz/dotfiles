import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ColumnLayout {
    Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
    Layout.margins: 8
    property string occupiedTags: "000000000"
    property string focusedTags: "000000000"
    property string urgentTags: "000000000"

    Process {
        command: ["mmsg", "-w", "-t"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.includes("tags")) {
                    let parts = line.trim().split(" ");
                    occupiedTags = parts[2];
                    focusedTags = parts[3];
                    urgentTags = parts[4];
                }
            }
        }
    }

    Repeater {
        model: 9
        Rectangle {
            implicitWidth: 32
            implicitHeight: 32
            radius: 8
            
            readonly property int stringIdx: 8 - index
            readonly property bool isOccupied: occupiedTags[stringIdx] === "1"
            readonly property bool isFocused: focusedTags[stringIdx] === "1"

            color: isFocused ? palette.highlight : palette.mid
            visible: index < 4 || isOccupied || isFocused

            Text {
                anchors.centerIn: parent
                text: index + 1
                color: isFocused ? palette.highlightedText : palette.windowText
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    tagSetter.command = ["mmsg", "-s", "-t", (index + 1).toString()]
                    tagSetter.running = true
                }
            }
        }
    }
    Process { id: tagSetter; running: false }
}
