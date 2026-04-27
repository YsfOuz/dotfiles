pragma Singleton
import Quickshell

Singleton {
    // ── Theme ─────────────────────────────────────────────────────
    property int    cornerRadius: 8
    property int    padding:      8
    property int    spacing:      8
    property int    fontSize:     16
    property real   borderWidth:  2
    property int    margin:       8
    property real   opacity:      1

    // New Fine-Tuning Properties
    property int    discHoleSize: 4
    property int    mediaProgressHeight: 4
    property int    urgentBorderWidth: 2
    property int    actionItemSpacing: 8
    property bool   enableAnimations: false
    property int    animationDuration: 200 // ms

    // ── Bars ──────────────────────────────────────────────────────
    property int leftBarWidth:    48
    property int bottomBarHeight: 48

    // Available modules: "workspaces" "clock" "battery" "powerprofile"
    //                    "idleinhibitor" "tray" "media" "wifi" "bluetooth"
    //                    "volume" "brightness"
    property var barTopModules:    ["workspaces"]
    property var barCenterModules: ["clock"]
    property var barBottomModules: ["tray", "idleinhibitor", "wifi", "bluetooth",
                                    "volume", "brightness", "powerprofile", "battery"]

    // ── Clock ─────────────────────────────────────────────────────
    property int clockHourSize:   32
    property int clockMinuteSize: 28

    // ── Workspaces ────────────────────────────────────────────────
    property int workspaceCount: 4

    // ── Media ─────────────────────────────────────────────────────
    property int mediaTrackWidth:  80
    property int mediaPopupWidth:  480
    property int mediaPopupHeight: 160

    // ── Power menu ────────────────────────────────────────────────
    property int  powerMenuButtonSize: 128
    property int  powerMenuIconSize:   64

    property bool powerMenuAnchorTop:    false
    property bool powerMenuAnchorBottom: false
    property bool powerMenuAnchorLeft:   false
    property bool powerMenuAnchorRight:  false
    property int  powerMenuMarginTop:    0
    property int  powerMenuMarginBottom: 0
    property int  powerMenuMarginLeft:   0
    property int  powerMenuMarginRight:  0

    property var powerMenuActions: [
        { icon: "󰌾", label: "Lock",      cmd: ["qs", "ipc", "call", "lockscreen", "lock"], accent: ""        },
        { icon: "󰒲", label: "Suspend",   cmd: ["loginctl", "suspend"],                     accent: ""        },
        { icon: "󰋊", label: "Hibernate", cmd: ["loginctl", "hibernate"],                   accent: ""        },
        { icon: "󰍃", label: "Logout",    cmd: ["mmsg", "-q"],                               accent: ""        },
        { icon: "󰑓", label: "Reboot",    cmd: ["loginctl", "reboot"],                       accent: "#e0a050" },
        { icon: "󰐥", label: "Shutdown",  cmd: ["loginctl", "poweroff"],                     accent: "#e05050" },
    ]

    // ── Clipboard ─────────────────────────────────────────────────
    property int  clipboardWidth:    400
    property int  clipboardHeight:   500
    property int  clipboardMaxItems: 200

    property bool clipboardAnchorTop:    false
    property bool clipboardAnchorBottom: false
    property bool clipboardAnchorLeft:   false
    property bool clipboardAnchorRight:  false

    // ── App launcher ──────────────────────────────────────────────
    property int  launcherWidth:  500
    property int  launcherHeight: 500
    property int  itemHeight:     48
    property int  iconSize:       32
    property int  searchFontSize: 16

    property bool launcherAnchorLeft:   false
    property bool launcherAnchorRight:  false
    property bool launcherAnchorTop:    false
    property bool launcherAnchorBottom: false

    property string terminal:     "alacritty"
    property var    terminalArgs: ["-e"]

    // ── Notifications ─────────────────────────────────────────────
    property int  notifWidth:          360
    property int  notifDefaultTimeout: 5000
    property int  notifSpacing:        8

    property bool notifAnchorTop:    true
    property bool notifAnchorBottom: false
    property bool notifAnchorLeft:   false
    property bool notifAnchorRight:  true

    // ── Visualizer ────────────────────────────────────────────────
    property int  visualizerBars:    64
    property real visualizerOpacity: 1.0
    property int  visualizerBarGap:  8

    // ── OSD ───────────────────────────────────────────────────────
    property int  osdWidth:        240
    property int  osdHeight:       64
    property int  osdTimeout:      2000

    property bool osdAnchorTop:    false
    property bool osdAnchorBottom: true
    property bool osdAnchorLeft:   false
    property bool osdAnchorRight:  false
    property int  osdMarginTop:    0
    property int  osdMarginBottom: 8
    property int  osdMarginLeft:   0
    property int  osdMarginRight:  0
}
