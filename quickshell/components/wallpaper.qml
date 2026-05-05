import Quickshell
import Quickshell.Wayland
import QtQuick

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
            //source: "/home/yusuf/.config/wallpapers/verdigrisMinimal.png"
	    source: "/home/yusuf/.config/wallpapers/verdigris.png"
	    fillMode: Image.PreserveAspectCrop
        }
    }
}
