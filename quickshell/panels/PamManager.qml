import QtQuick
import Quickshell
import Quickshell.Services.Pam

QtObject {
    id: root

    property bool active: false
    property string message: ""
    property bool responseRequired: false
    property bool unlockRequested: false

    property PamContext pamContext: PamContext {
        config: "login"

        onPamMessage: function() {
            root.message = pamContext.message
            root.responseRequired = pamContext.responseRequired
        }

        onCompleted: result => {
            if (result === PamResult.Success) {
                root.active = false
                root.unlockRequested = true
            } else {
                root.message = "Incorrect — try again"
                root.responseRequired = true
                pamContext.start()
            }
        }
    }

    function startAuth() {
        active = true
        unlockRequested = false
        pamContext.start()
    }

    function respond(text) {
        pamContext.respond(text)
    }

    function stopAuth() {
        active = false
        unlockRequested = false
    }
}
