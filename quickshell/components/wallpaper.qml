import Quickshell
import Quickshell.Wayland
import QtQuick
import ".."

Variants {
    model: Quickshell.screens

    delegate: PanelWindow {
        required property var modelData
        screen: modelData
        color: "black"
        anchors { top: true; bottom: true; left: true; right: true }
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        Image {
            anchors.fill: parent
            source: Settings.wallpaperPath
            fillMode: Settings.wallpaperFillMode
        }
    }
}
