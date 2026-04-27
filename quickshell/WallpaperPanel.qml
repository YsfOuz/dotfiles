import QtQuick
import Quickshell
import Quickshell.Wayland
import "."

PanelWindow {
    anchors.top:    true
    anchors.bottom: true
    anchors.left:   true
    anchors.right:  true

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    color: "black"

    Image {
        anchors.fill: parent
        source:       "file://" + Quickshell.shellDir + "/../wallpapers/verdigrisMinimal.png"
        fillMode:     Image.PreserveAspectCrop
        asynchronous: true
    }
}
