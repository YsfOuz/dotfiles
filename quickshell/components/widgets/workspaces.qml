import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../.."

ColumnLayout {
    id: root
    Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
    Layout.margins: 8

    property int activeTags: 0
    property int occupiedTags: 0
    property int urgentTags: 0

    Process {
        command: ["riveripc", "--watch"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                let t = line.trim()
                if (!t) return

                let mask = 0
                let index = t.indexOf(":")
                if (index !== -1) {
                    let nums = t.slice(index + 1).match(/\d+/g)
                    if (nums) {
                        for (let i = 0; i < nums.length; i++) {
                            mask |= (1 << (nums[i] - 1))
                        }
                    }
                }

                if (t[0] === "a") activeTags = mask
                else if (t[0] === "o") occupiedTags = mask
                else if (t[0] === "u") urgentTags = mask
            }
        }
    }

    Process {
        id: riverctl
        function focusTag(mask) {
            command = ["riverctl", "set-focused-tags", mask.toString()]
            running = true
        }
    }

    Repeater {
        model: 9
        Rectangle {
            readonly property int tagMask: 1 << index
            readonly property bool isFocused:  (root.activeTags   & tagMask) !== 0
            readonly property bool isOccupied: (root.occupiedTags & tagMask) !== 0
            readonly property bool isUrgent:   (root.urgentTags   & tagMask) !== 0

            visible: isFocused || isOccupied || index < 4
            implicitWidth: 32
            implicitHeight: 32
            radius: Settings.borderRadius
            color: isUrgent ? Settings.danger : isFocused ? Settings.accent : Settings.surfaceT

            Text {
                anchors.centerIn: parent
                text: index + 1
                color: isFocused ? Settings.accentText : Settings.text
            }

            MouseArea {
                anchors.fill: parent
                onClicked: riverctl.focusTag(tagMask)
            }
        }
    }
}
