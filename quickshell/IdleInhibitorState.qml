pragma Singleton

import Quickshell

Singleton {
    property bool inhibiting: false
    function toggle() { inhibiting = !inhibiting }
}
