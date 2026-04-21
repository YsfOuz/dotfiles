import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."

Item {
    id: root

    SystemPalette { id: palette }

    // ── Media process (sole owner of playerctl) ────────────────────
    Process {
        id: mediaProc
        command: ["playerctl", "-F", "metadata", "--format",
            "{{status}}\t{{artist}}\t{{title}}\t{{mpris:artUrl}}\t{{position}}\t{{mpris:length}}"]
        Component.onCompleted: running = true
        stdout: SplitParser {
            onRead: line => {
                var p = line.split("\t")
                var st = p[0] ? p[0].trim() : ""
                if (st !== "Playing" && st !== "Paused" && st !== "Stopped") return
                MediaState.playing  = (st === "Playing")
                MediaState.artist   = p[1] ? p[1].trim() : ""
                MediaState.title    = p[2] ? p[2].trim() : ""
                MediaState.artUrl   = p[3] ? p[3].trim() : ""
                MediaState.position = p[4] ? parseInt(p[4]) / 1000000 : 0
                MediaState.length   = p[5] ? parseInt(p[5]) / 1000000 : 0
                MediaState.active   = true
            }
        }
        onExited: { MediaState.active = false; mediaRestartTimer.start() }
    }

    Timer { id: mediaRestartTimer; interval: 5000; repeat: false; onTriggered: mediaProc.running = true }

    Timer {
        interval: 200; repeat: true
        running: MediaState.playing && mediaPopup.visible
        onTriggered: MediaState.position = Math.min(MediaState.position + 0.2, MediaState.length)
    }

    Process { id: ctlProc }

    // ── Visualizer bar ─────────────────────────────────────────────
    PanelWindow {
        id: win

        anchors.bottom: true
        anchors.left:   true
        anchors.right:  true

        margins.bottom: Settings.margin
        margins.left:   Settings.margin
        margins.right:  Settings.margin

        implicitHeight: Settings.bottomBarHeight

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusiveZone: Settings.bottomBarHeight + Settings.margin
        color: "transparent"

        property var barValues: []

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
                PathArc  { x: Settings.cornerRadius;                  y: 0;
                            radiusX: Settings.cornerRadius; radiusY: Settings.cornerRadius; direction: PathArc.Clockwise }
                PathLine { x: barShape.width - Settings.cornerRadius; y: 0 }
                PathArc  { x: barShape.width; y: Settings.cornerRadius;
                            radiusX: Settings.cornerRadius; radiusY: Settings.cornerRadius; direction: PathArc.Clockwise }
                PathLine { x: barShape.width; y: barShape.height - Settings.cornerRadius }
                PathArc  { x: barShape.width - Settings.cornerRadius; y: barShape.height;
                            radiusX: Settings.cornerRadius; radiusY: Settings.cornerRadius; direction: PathArc.Clockwise }
                PathLine { x: Settings.cornerRadius; y: barShape.height }
                PathArc  { x: 0; y: barShape.height - Settings.cornerRadius;
                            radiusX: Settings.cornerRadius; radiusY: Settings.cornerRadius; direction: PathArc.Clockwise }
                PathLine { x: 0; y: Settings.cornerRadius }
            }
        }

        Canvas {
            id: visCanvas
            anchors { fill: parent; margins: Settings.padding }

            onPaint: {
                var ctx  = getContext("2d")
                var vals = win.barValues
                ctx.clearRect(0, 0, width, height)
                if (vals.length === 0) return

                var n   = vals.length
                var gap = Settings.visualizerBarGap
                var bw  = (width - gap * (n - 1)) / n
                var h   = palette.highlight

                ctx.fillStyle = Qt.rgba(h.r, h.g, h.b, Settings.visualizerOpacity)

                for (var i = 0; i < n; i++) {
                    var barH = Math.max(1, (vals[i] / 100) * height)
                    ctx.fillRect(
                        Math.round(i * (bw + gap)),
                        Math.round(height - barH),
                        Math.max(1, Math.round(bw)),
                        Math.round(barH))
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: MediaState.active ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (MediaState.active) mediaPopup.visible = !mediaPopup.visible
        }

        Process {
            id: cavaProc
            command: ["sh", "-c",
                "printf '[general]\\nbars=" + Settings.visualizerBars + "\\nframerate=60\\n" +
                "[input]\\nmethod=pulse\\nsource=auto\\n" +
                "[output]\\nmethod=raw\\nraw_target=/dev/stdout\\ndata_format=ascii\\nascii_max_range=100\\nbar_delimiter=59\\n" +
                "[smoothing]\\nmonstercat=1\\nwaves=0\\n' > /tmp/qs-cava.conf && cava -p /tmp/qs-cava.conf"
            ]
            Component.onCompleted: running = true
            stdout: SplitParser {
                onRead: line => {
                    var parts = line.split(";")
                        .filter(s => s !== "")
                        .map(Number)
                        .filter(v => !isNaN(v))
                    if (parts.length > 0) {
                        win.barValues = parts
                        visCanvas.requestPaint()
                    }
                }
            }
            onExited: cavaRestartTimer.start()
        }

        Timer {
            id: cavaRestartTimer
            interval: 3000; repeat: false
            onTriggered: cavaProc.running = true
        }
    }

    // ── Media popup ────────────────────────────────────────────────
    PanelWindow {
        id: mediaPopup
        visible: false

        anchors.bottom: true
        margins.bottom: Settings.margin

        implicitWidth:  Settings.mediaPopupWidth
        implicitHeight: Settings.mediaPopupHeight

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusiveZone: 0
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color:        Qt.rgba(palette.window.r, palette.window.g, palette.window.b, Settings.opacity)
            radius:       Settings.cornerRadius
            border.width: Settings.borderWidth
            border.color: Settings.borderWidth > 0
                ? Qt.rgba(palette.mid.r, palette.mid.g, palette.mid.b, 0.5)
                : "transparent"

            RowLayout {
                anchors { fill: parent; margins: Settings.padding }
                spacing: Settings.spacing

                // ── Spinning disc ──────────────────────────────────
                Item {
                    property int discSize: Settings.mediaPopupHeight - Settings.padding * 2
                    Layout.alignment: Qt.AlignVCenter
                    width:  discSize
                    height: discSize

                    Item {
                        id: disc
                        anchors.fill: parent

                        Canvas {
                            id: discCanvas
                            anchors.fill: parent

                            property string artUrl: MediaState.artUrl
                            onArtUrlChanged: { if (artUrl !== "") loadImage(artUrl); requestPaint() }
                            onImageLoaded: requestPaint()

                            onPaint: {
                                var ctx = getContext("2d")
                                var w = width, h = height, r = w / 2
                                ctx.clearRect(0, 0, w, h)
                                ctx.save()
                                ctx.beginPath()
                                ctx.arc(r, r, r, 0, Math.PI * 2)
                                ctx.clip()
                                ctx.fillStyle = "#1a1a1a"
                                ctx.fillRect(0, 0, w, h)
                                if (artUrl !== "" && isImageLoaded(artUrl)) {
                                    ctx.globalAlpha = 0.88
                                    ctx.drawImage(artUrl, 0, 0, w, h)
                                    ctx.globalAlpha = 1.0
                                }
                                ctx.strokeStyle = "rgba(0,0,0,0.35)"
                                ctx.lineWidth = w * 0.08
                                ctx.beginPath()
                                ctx.arc(r, r, r - w * 0.04, 0, Math.PI * 2)
                                ctx.stroke()
                                ctx.restore()
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible:          MediaState.artUrl === ""
                            text:             "\uf001"
                            font.pixelSize:   parent.width * 0.35
                            color:            Qt.rgba(palette.highlight.r, palette.highlight.g, palette.highlight.b, 0.6)
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width:  parent.width * 0.22
                        height: parent.width * 0.22
                        radius: width / 2
                        color:  palette.window

                        Rectangle {
                            anchors.centerIn: parent
                            width: 6; height: 6; radius: 3
                            color: palette.highlight
                        }
                    }

                    RotationAnimation {
                        target:    disc
                        property:  "rotation"
                        from: 0; to: 360
                        duration:  8000
                        loops:     Animation.Infinite
                        running:   true
                        paused:    !MediaState.playing
                    }
                }

                // ── Track info + controls ──────────────────────────
                ColumnLayout {
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                    spacing: 4

                    Item { Layout.fillHeight: true }

                    Text {
                        text:           MediaState.title || "Unknown"
                        color:          palette.text
                        font.pixelSize: Settings.fontSize
                        font.bold:      true
                        elide:          Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        visible:        MediaState.artist !== ""
                        text:           MediaState.artist
                        color:          Qt.rgba(palette.text.r, palette.text.g, palette.text.b, 0.65)
                        font.pixelSize: Settings.fontSize - 2
                        elide:          Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        spacing: Settings.spacing * 2

                        Text {
                            text: "\u23ee"
                            font.pixelSize: Settings.fontSize + 2; color: palette.text
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: ctlProc.exec(["playerctl", "previous"]) }
                        }
                        Text {
                            text: MediaState.playing ? "\u23f8" : "\u25b6"
                            font.pixelSize: Settings.fontSize + 4; color: palette.highlight
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: ctlProc.exec(["playerctl", "play-pause"]) }
                        }
                        Text {
                            text: "\u23ed"
                            font.pixelSize: Settings.fontSize + 2; color: palette.text
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                        onClicked: ctlProc.exec(["playerctl", "next"]) }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Settings.spacing / 2

                        Text {
                            text:           MediaState.formatTime(MediaState.position)
                            font.pixelSize: Settings.fontSize - 4
                            color:          Qt.rgba(palette.text.r, palette.text.g, palette.text.b, 0.55)
                        }

                        Item {
                            Layout.fillWidth: true
                            height: 4

                            Rectangle {
                                anchors.fill: parent
                                color:  Qt.rgba(palette.highlight.r, palette.highlight.g, palette.highlight.b, 0.22)
                                radius: 2
                            }
                            Rectangle {
                                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                width:  MediaState.length > 0
                                    ? Math.max(radius * 2, parent.width * (MediaState.position / MediaState.length))
                                    : 0
                                color:  palette.highlight
                                radius: 2
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape:  Qt.PointingHandCursor
                                onClicked: mouse => {
                                    var pos = (mouse.x / width) * MediaState.length
                                    MediaState.position = pos
                                    ctlProc.exec(["playerctl", "position", pos.toFixed(1)])
                                }
                            }
                        }

                        Text {
                            text:           MediaState.formatTime(MediaState.length)
                            font.pixelSize: Settings.fontSize - 4
                            color:          Qt.rgba(palette.text.r, palette.text.g, palette.text.b, 0.55)
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
