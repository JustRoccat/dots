// ~/.config/quickshell/ShaderOverlay.qml
import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    // Warstwa Bottom — nad tapetą, pod oknami.
    // Nie blokuje eventów myszy.
    visible: GlobalState.shadersEnabled

    // KLUCZOWE: Pełne pokrycie ekranu bez marginesów
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell-shaders"
    WlrLayershell.exclusiveZone: 0

    Canvas {
        id: cv
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject

        // Zmienne cache dla optymalizacji
        property var lastWidth: 0
        property var lastHeight: 0
        property var grainSeed: 0
        property var animationTime: 0

        // 60 FPS — lepiej dla nowoczesnych monitorów
        Timer {
            interval: 16  // 1000/60 ≈ 16.67ms
            running: GlobalState.shadersEnabled
            repeat: true
            onTriggered: {
                cv.animationTime += 16
                if (cv.animationTime > 10000) cv.animationTime = 0
                cv.requestPaint()
            }
        }

        onPaint: {
            var ctx = getContext("2d")
            var W = width
            var H = height

            // Pełne wyczyszczenie
            ctx.clearRect(0, 0, W, H)

            // ── 1. Vignette (radialny gradient) ────────────────────
            var vig = ctx.createRadialGradient(
                W * 0.5, H * 0.5, H * 0.20,
                W * 0.5, H * 0.5, H * 0.88
            )
            vig.addColorStop(0.0, "rgba(0,0,0,0)")
            vig.addColorStop(0.6, "rgba(0,0,0,0.08)")
            vig.addColorStop(1.0, "rgba(0,0,0,0.58)")
            ctx.fillStyle = vig
            ctx.fillRect(0, 0, W, H)

            // ── 2. Scanlines (zoptymalizowane) ────────────────────
            // Zamiast rysować każdą linię osobno, rysujemy paski
            ctx.fillStyle = "rgba(0,0,0,0.10)"
            for (var y = 0; y < H; y += 3) {
                ctx.fillRect(0, y, W, 1)
            }

            // ── 3. Phosphor afterglow (subtelne) ──────────────────
            ctx.fillStyle = "rgba(255,255,255,0.013)"
            for (var y2 = 1; y2 < H; y2 += 3) {
                ctx.fillRect(0, y2, W, 1)
            }

            // ── 4. Film grain (animowany, zoptymalizowany) ────────
            // Zmniejszona ilość ziarnek dla lepszej wydajności
            var grainCount = Math.min(800, Math.floor(W * H / 3000))
            
            // Pseudo-losowość bazowana na czasie zamiast Math.random()
            // dla lepszej wydajności i spójności
            for (var i = 0; i < grainCount; i++) {
                var seed = (cv.animationTime + i * 73) % 10000
                var gx = (seed * 12.9898) % W
                var gy = ((seed * 78.233) % H)
                
                var ga = ((seed * 43758.5453) % 100) / 100 * 0.048
                var gr = ((seed * 23.14069) % 100) / 100
                
                if (gr < 0.7) {
                    ctx.fillStyle = "rgba(255,255,255," + ga.toFixed(3) + ")"
                } else if (gr < 0.85) {
                    ctx.fillStyle = "rgba(255,200,180," + (ga * 0.6).toFixed(3) + ")"
                } else {
                    ctx.fillStyle = "rgba(180,200,255," + (ga * 0.6).toFixed(3) + ")"
                }
                ctx.fillRect(gx, gy, 2, 2)
            }

            // ── 5. Chromatic aberration — krawędzie ────────────────
            // Lewa krawędź: czerwona fringa
            var leftR = ctx.createLinearGradient(0, 0, 28, 0)
            leftR.addColorStop(0.0, "rgba(255,30,30,0.055)")
            leftR.addColorStop(1.0, "rgba(255,30,30,0)")
            ctx.fillStyle = leftR
            ctx.fillRect(0, 0, 28, H)

            // Prawa krawędź: niebieska fringa
            var rightB = ctx.createLinearGradient(W, 0, W - 28, 0)
            rightB.addColorStop(0.0, "rgba(30,80,255,0.055)")
            rightB.addColorStop(1.0, "rgba(30,80,255,0)")
            ctx.fillStyle = rightB
            ctx.fillRect(W - 28, 0, 28, H)

            // Górna krawędź: zielonawa fringa (subtelna)
            var topG = ctx.createLinearGradient(0, 0, 0, 14)
            topG.addColorStop(0.0, "rgba(30,255,80,0.025)")
            topG.addColorStop(1.0, "rgba(30,255,80,0)")
            ctx.fillStyle = topG
            ctx.fillRect(0, 0, W, 14)

            // ── 6. Subtelna winieta kolorystyczna z accenta ────────
            var ac  = Theme.accent
            var acR = Math.round(ac.r * 255)
            var acG = Math.round(ac.g * 255)
            var acB = Math.round(ac.b * 255)

            var acVig = ctx.createRadialGradient(
                W*0.5, H*0.5, H*0.35,
                W*0.5, H*0.5, H*0.90
            )
            acVig.addColorStop(0.0, "rgba(" + acR + "," + acG + "," + acB + ",0)")
            acVig.addColorStop(1.0, "rgba(" + acR + "," + acG + "," + acB + ",0.06)")
            ctx.fillStyle = acVig
            ctx.fillRect(0, 0, W, H)

            // ── 7. Subtelna animowana pulsacja (opcjonalnie) ──────
            // Bardzo subtelna zmiana jasności dla efektu "oddychania"
            var pulse = Math.sin(cv.animationTime / 3000) * 0.008
            ctx.fillStyle = "rgba(0,0,0," + (pulse * 0.5).toFixed(3) + ")"
            ctx.fillRect(0, 0, W, H)
        }

        // Przerysuj gdy accent się zmienia
        Connections {
            target: Theme
            function onAccentChanged() { cv.requestPaint() }
        }

        // Przerysuj gdy shader się włącza/wyłącza
        Connections {
            target: GlobalState
            function onShadersEnabledChanged() { cv.requestPaint() }
        }
    }
}
