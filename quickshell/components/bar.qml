import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import ".."

PanelWindow {
    id: barWindow
    implicitWidth: Settings.barWidth
    color: "transparent"
    anchors { left: true; top: true; bottom: true }
    margins { left: Settings.barMargin; top: Settings.barMargin; bottom: Settings.barMargin }

    readonly property var moduleMap: ({
        "workspaces":    "widgets/workspaces.qml",
        "clock":         "widgets/clock.qml",
        "tray":          "widgets/systemTray.qml",
        "idleInhibitor": "widgets/idleInhibitor.qml",
        "mic":           "widgets/mic.qml",
        "volume":        "widgets/volume.qml",
        "brightness":    "widgets/brightness.qml",
        "powerProfile":  "widgets/powerProfile.qml",
        "battery":       "widgets/battery.qml",
    })

    Rectangle {
        anchors.fill: parent
        color: Settings.bg
        radius: Settings.borderRadius
        border {
            width: Settings.borderWidth
            color: Settings.borderColor
        }
    }

    ColumnLayout {
        spacing: 0
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        Repeater {
            model: Settings.topModules
            Loader {
                required property string modelData
                source: barWindow.moduleMap[modelData] ? Qt.resolvedUrl(barWindow.moduleMap[modelData]) : ""
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: Settings.widgetPadding
                onLoaded: if (modelData === "tray" || modelData === "idleInhibitor") item.window = barWindow
            }
        }
    }

    ColumnLayout {
        spacing: 0
        anchors.centerIn: parent
        Repeater {
            model: Settings.centerModules
            Loader {
                required property string modelData
                source: barWindow.moduleMap[modelData] ? Qt.resolvedUrl(barWindow.moduleMap[modelData]) : ""
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: Settings.widgetPadding
                onLoaded: if (modelData === "tray" || modelData === "idleInhibitor") item.window = barWindow
            }
        }
    }

    ColumnLayout {
        spacing: 0
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        Repeater {
            model: Settings.bottomModules
            Loader {
                required property string modelData
                source: barWindow.moduleMap[modelData] ? Qt.resolvedUrl(barWindow.moduleMap[modelData]) : ""
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: Settings.widgetPadding
                onLoaded: if (modelData === "tray" || modelData === "idleInhibitor") item.window = barWindow
            }
        }
    }
}
