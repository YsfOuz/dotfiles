import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

Rectangle {
    id: root
    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
    Layout.margins: 8
    implicitWidth: 32
    implicitHeight: 32
    radius: 8
    color: palette.mid

    Text {
        text: ["󰌪", "󰗑", "󰑣"][PowerProfiles.profile] ?? "N/A"
        anchors.centerIn: parent
        color: palette.windowText
    }
    MouseArea {
        anchors.fill: parent
        onClicked: PowerProfiles.profile = (PowerProfiles.profile + 1) % 3 
    }
}
