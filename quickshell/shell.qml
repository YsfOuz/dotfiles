//@ pragma UseQApplication
import Quickshell
import QtQuick
import Quickshell.Wayland
import "components"

ShellRoot {
    Wallpaper{}
    Bar{}

    AppLauncher{}
    PowerMenu{}
    Notifications{}
    LockScreen{}
}
