pragma Singleton
import Quickshell

Singleton {
    property bool   active:   false
    property bool   playing:  false
    property string artist:   ""
    property string title:    ""
    property string artUrl:   ""
    property real   position: 0
    property real   length:   0

    function formatTime(secs) {
        var m = Math.floor(secs / 60)
        var s = Math.floor(secs % 60)
        return m + ":" + (s < 10 ? "0" : "") + s
    }
}
