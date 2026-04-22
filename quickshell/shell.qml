//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Services.SystemTray
import "bars"
import "panels"

ShellRoot {
    WallpaperPanel {}

    AppLauncher   { id: launcher }
    LeftBar       {}
    BottomBar     {}
    ClipboardMenu { id: clipboard }
    Notifications { id: notifs }
    Osd           { id: osd }
    PowerMenu     { id: powerMenu }
    LockScreen    { id: lockScreen }

    IpcHandler {
        target: "launcher"
        function toggle() { launcher.toggle() }
    }

    IpcHandler {
        target: "osd"
        function display()           { osd.showOsd("volume") }
        function displayMic()        { osd.showOsd("mic") }
        function displayBrightness() { osd.showOsd("brightness") }
    }

    IpcHandler {
        target: "clipboard"
        function toggle() { clipboard.toggle() }
    }

    IpcHandler {
        target: "powermenu"
        function toggle() { powerMenu.toggle() }
    }

    IpcHandler {
        target: "lockscreen"
        function lock() { lockScreen.lock() }
    }

    NotificationServer {
        keepOnReload: true
        onNotification: notif => notifs.add(notif)
    }
}
