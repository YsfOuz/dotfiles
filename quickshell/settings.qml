pragma Singleton
import QtQuick
import Quickshell

QtObject {

    readonly property SystemPalette _p: SystemPalette { colorGroup: SystemPalette.Active }

    property color bg:          _p.base
    property color surface:     _p.alternateBase
    property color borderColor: _p.alternateBase
    property color text:        _p.text
    property color subtext:     _p.placeholderText
    property color accent:      _p.highlight
    property color accentText:  _p.highlightedText
    property color danger:      "#B63A3A"

    property real opacity: 1.0

    readonly property color bgT:      Qt.rgba(bg.r,      bg.g,      bg.b,      opacity)
    readonly property color surfaceT: Qt.rgba(surface.r, surface.g, surface.b, opacity)

    property int borderWidth:  2
    property int borderRadius: 4

    property int barWidth:      48
    property int barMargin:     4
    property int widgetPadding: 8

    property var topModules:    ["workspaces"]
    property var centerModules: ["clock"]
    property var bottomModules: ["tray", "idleInhibitor", "mic", "volume", "brightness", "powerProfile", "battery"]

    property int idleDim:       300
    property int idleScreenOff: 600
    property int idleLock:      1800

    property string wallpaperPath:     Quickshell.env("HOME") + "/.config/wallpapers/verdigris.png"
    property int    wallpaperFillMode: 2

    property real   volumeStep:     0.05
    property string brightnessStep: "5%"

    property int launcherWidth:      480
    property int launcherHeight:     640
    property int launcherItemHeight: 48
    property int launcherIconSize:   32

    property int powerMenuBtnSize: 128

    property int notifWidth:          320
    property int notifDefaultTimeout: 5000

    property int polkitWidth: 512

    property int    lockInputWidth:    480
    property int    lockClockFontSize: 96
    property string lockTimeFormat:    "HH:mm"
    property string lockDateFormat:    "dddd, MMMM d"

    readonly property int widgetSize:    barWidth - 16
    readonly property int iconFont:      Math.max(10, Math.round(widgetSize / 2))
    readonly property int labelFont:     Math.max(8,  Math.round(widgetSize * 3 / 8))
    readonly property int clockH:        barWidth * 2
    readonly property int clockHourFont: Math.max(14, Math.round(barWidth * 5 / 6))
    readonly property int clockMinFont:  Math.max(12, Math.round(barWidth * 2 / 3))
}
