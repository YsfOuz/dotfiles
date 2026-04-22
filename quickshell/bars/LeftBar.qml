import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import ".."
import "../widgets"

Item {
    SystemPalette { id: palette }

    Component { id: workspacesComp;   Workspaces {}    }
    Component { id: clockComp;        Clock {}         }
    Component { id: batteryComp;      Battery {}       }
    Component { id: powerProfileComp; PowerProfile {}  }
    Component { id: idleComp;         IdleInhibitor {} }
    Component { id: trayComp;         Tray {}          }
    Component { id: mediaComp;        Media {}         }
    Component { id: wifiComp;         Wifi {}          }
    Component { id: bluetoothComp;    Bluetooth {}     }
    Component { id: volumeComp;       Volume {}        }
    Component { id: brightnessComp;   Brightness {}    }

    property var moduleMap: ({
        "workspaces":    workspacesComp,
        "clock":         clockComp,
        "battery":       batteryComp,
        "powerprofile":  powerProfileComp,
        "idleinhibitor": idleComp,
        "tray":          trayComp,
        "media":         mediaComp,
        "wifi":          wifiComp,
        "bluetooth":     bluetoothComp,
        "volume":        volumeComp,
        "brightness":    brightnessComp,
    })

    PanelWindow {
        id: leftBarPanel
        anchors.left:   true
        anchors.top:    true
        anchors.bottom: true

        margins.left:   Settings.margin
        margins.top:    Settings.margin
        margins.bottom: Settings.margin

        implicitWidth: Settings.leftBarWidth

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusiveZone: Settings.leftBarWidth + Settings.margin
        color: "transparent"

        Shape {
            id: barShape
            anchors.fill: parent
            ShapePath {
                fillColor:   Qt.rgba(palette.window.r, palette.window.g, palette.window.b, Settings.opacity)
                strokeWidth: Settings.borderWidth
                strokeColor: Settings.borderWidth > 0
                    ? Qt.rgba(palette.mid.r, palette.mid.g, palette.mid.b, 0.5)
                    : "transparent"

                startX: 0; startY: Settings.cornerRadius
                PathArc  { x: Settings.cornerRadius;                   y: 0;
                            radiusX: Settings.cornerRadius; radiusY: Settings.cornerRadius; direction: PathArc.Clockwise }
                PathLine { x: barShape.width - Settings.cornerRadius;  y: 0 }
                PathArc  { x: barShape.width; y: Settings.cornerRadius;
                            radiusX: Settings.cornerRadius; radiusY: Settings.cornerRadius; direction: PathArc.Clockwise }
                PathLine { x: barShape.width; y: barShape.height - Settings.cornerRadius }
                PathArc  { x: barShape.width - Settings.cornerRadius;  y: barShape.height;
                            radiusX: Settings.cornerRadius; radiusY: Settings.cornerRadius; direction: PathArc.Clockwise }
                PathLine { x: Settings.cornerRadius; y: barShape.height }
                PathArc  { x: 0; y: barShape.height - Settings.cornerRadius;
                            radiusX: Settings.cornerRadius; radiusY: Settings.cornerRadius; direction: PathArc.Clockwise }
                PathLine { x: 0; y: Settings.cornerRadius }
            }
        }

        ColumnLayout {
            anchors { fill: parent; margins: Settings.padding }
            spacing: 6

            Repeater {
                model: Settings.barTopModules
                Loader {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: item ? item.implicitHeight : 0
                    sourceComponent: moduleMap[modelData] ?? null
                }
            }
            Item { Layout.fillHeight: true }
            Repeater {
                model: Settings.barCenterModules
                Loader {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: item ? item.implicitHeight : 0
                    sourceComponent: moduleMap[modelData] ?? null
                }
            }
            Item { Layout.fillHeight: true }
            Repeater {
                model: Settings.barBottomModules
                Loader {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: item ? item.implicitHeight : 0
                    sourceComponent: moduleMap[modelData] ?? null
                }
            }
        }
    }
}
