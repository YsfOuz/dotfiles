import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import ".."

Item {
    IdleMonitor {
        timeout: Settings.idleDim
        respectInhibitors: true
        onIsIdleChanged: {
            dimProc.command = isIdle
                ? ["brightnessctl", "--save", "s", "50%"]
                : ["brightnessctl", "--restore"]
            dimProc.running = false
            dimProc.running = true
        }
    }

    IdleMonitor {
        timeout: Settings.idleScreenOff
        respectInhibitors: true
        onIsIdleChanged: {
            dpmsProc.command = ["sh", "-c",
                "wlr-randr | grep '^[^ ]' | cut -d' ' -f1 | xargs -I{} wlr-randr --output {} " + (isIdle ? "--off" : "--on")]
            dpmsProc.running = false
            dpmsProc.running = true
        }
    }

    IdleMonitor {
        timeout: Settings.idleLock
        respectInhibitors: true
        onIsIdleChanged: {
            if (!isIdle) return
            lockProc.running = false
            lockProc.running = true
        }
    }

    Process { id: dimProc }
    Process { id: dpmsProc }
    Process { id: lockProc; command: ["qs", "ipc", "call", "lockScreen", "lock"] }
}
