"""Weave logo generator: the Woven Rings mark, the custom "weave" wordmark, lockups, and app-icon art.

Every shape is an exact fill (arcs and straight lines, no strokes, masks or fonts), so the output
scales cleanly and the app icon and logo share one geometry.

    python3 WeaveApp/DesignSystem/Brand/source/make_logo.py WeaveApp/DesignSystem/Brand/svg
"""
import math
import pathlib
import sys

MINT, PERIWINKLE, PEACH = "#8EDCBC", "#A3ADFF", "#FFC98F"
INK, BRAND, WHITE, PAPER = "#111111", "#2D6A4F", "#FFFFFF", "#F1F0EC"
RINGS = [MINT, PERIWINKLE, PEACH]


def f(v):
    return f"{v:.2f}".rstrip("0").rstrip(".")


# ---------------------------------------------------------------------------
# Mark: three rings on a triangle. Ring i passes over ring (i+1) % 3 at both
# crossings (Borromean weave). Each under ring is cut along the over ring's
# band, offset by the gap, so cut ends run parallel to the band above.
# ---------------------------------------------------------------------------

class Mark:
    def __init__(self, R=50.0, W=19.0, G=4.5, T=42.0, centre=(128.0, 136.0)):
        self.R, self.W, self.G = R, W, G
        self.centres = [(centre[0] + T * math.cos(math.radians(a)), centre[1] + T * math.sin(math.radians(a)))
                        for a in (-90, 30, 150)]

    @staticmethod
    def _hits(c1, r1, c2, r2):
        dx, dy = c2[0] - c1[0], c2[1] - c1[1]
        d = math.hypot(dx, dy)
        a = (r1 * r1 - r2 * r2 + d * d) / (2 * d)
        h = math.sqrt(max(r1 * r1 - a * a, 0.0))
        mx, my = c1[0] + a * dx / d, c1[1] + a * dy / d
        return [(mx + h * dy / d, my - h * dx / d), (mx - h * dy / d, my + h * dx / d)]

    def ring(self, i):
        R, W, G = self.R, self.W, self.G
        over = (i - 1) % 3
        c, co = self.centres[i], self.centres[over]
        ro, ri = R + W / 2, R - W / 2
        cuts = []
        for p in self._hits(c, R, co, R):
            for off in (R + W / 2 + G, R - W / 2 - G):
                near = lambda pts: min(pts, key=lambda q: math.dist(q, p))
                q = near(self._hits(c, R, co, off))
                cuts.append((math.atan2(q[1] - c[1], q[0] - c[0]) % (2 * math.pi),
                             near(self._hits(c, ro, co, off)), near(self._hits(c, ri, co, off)), off))
        cuts.sort()

        def in_gap(a, b):
            m = (a + b) / 2
            d = math.dist((c[0] + R * math.cos(m), c[1] + R * math.sin(m)), co)
            return R - W / 2 - G < d < R + W / 2 + G

        if not in_gap(cuts[0][0], cuts[1][0]):
            cuts = cuts[1:] + cuts[:1]

        def sweep(p, q):  # short arc around the over ring's centre
            return 1 if (p[0] - co[0]) * (q[1] - co[1]) - (p[1] - co[1]) * (q[0] - co[0]) > 0 else 0

        d = ""
        for (a, ao, ai, offa), (b, bo, bi, offb) in ((cuts[1], cuts[2]), (cuts[3], cuts[0])):
            large = 1 if (b - a) % (2 * math.pi) > math.pi else 0
            d += (f"M{f(ao[0])} {f(ao[1])}A{f(ro)} {f(ro)} 0 {large} 1 {f(bo[0])} {f(bo[1])}"
                  f"A{f(offb)} {f(offb)} 0 0 {sweep(bo, bi)} {f(bi[0])} {f(bi[1])}"
                  f"A{f(ri)} {f(ri)} 0 {large} 0 {f(ai[0])} {f(ai[1])}"
                  f"A{f(offa)} {f(offa)} 0 0 {sweep(ai, ao)} {f(ao[0])} {f(ao[1])}Z")
        return d

    def svg(self, colors):
        if isinstance(colors, str):
            colors = [colors] * 3
        return "".join(f'<path fill="{colors[i]}" d="{self.ring(i)}"/>' for i in range(3))


MARK = Mark()                                   # master, 256 canvas
MARK_SMALL = Mark(R=48.0, W=24.0, G=6.0, T=36.0)  # 16-32 px: heavier bands, wider gaps
# Every cut needs the inner offset circle to reach the next ring: T*sqrt(3) < (R-W/2) + (R-W/2-G).
MARK_REVERSED = Mark(W=18.2)                    # white on dark reads heavier; thin ~4 %


# ---------------------------------------------------------------------------
# Wordmark: lowercase "weave", heavy geometric construction on a 100-unit
# x-height. Straight strokes 30 wide horizontally (about 27 perpendicular),
# round strokes 26, e-bar 20 (horizontals drawn thinner so they look equal).
# Round letters overshoot the baseline and x-height by 1.5 units.
# ---------------------------------------------------------------------------

XH, HW, RS, BAR, OS = 100.0, 30.0, 26.0, 20.0, 1.5
# Diagonals lean exactly 15 degrees from vertical, so a v is 2*XH*tan(15) + HW wide.
V_W = 2 * XH * math.tan(math.radians(15)) + HW


def stroke(xt, xb, hw=HW):
    """Diagonal stroke from top edge [xt, xt+hw] at y=0 to bottom edge [xb, xb+hw] at y=XH."""
    return f"M{f(xt)} 0L{f(xt + hw)} 0L{f(xb + hw)} {f(XH)}L{f(xb)} {f(XH)}Z"

# Each letter returns (shapes, advance width). A shape is (path data, even_odd).
# Shapes are separate <path> elements, so overlapping strokes join instead of cancelling.


def letter_v(x, w=V_W):
    mid = x + w / 2 - HW / 2
    return [(stroke(x, mid), False), (stroke(x + w - HW, mid), False)], w


def letter_w(x, vw=V_W):
    a, _ = letter_v(x, vw)
    b, _ = letter_v(x + vw - HW, vw)
    return a + b, 2 * vw - HW


def letter_e(x):
    ro = XH / 2 + OS
    ri = ro - RS
    cx, cy = x + ro, XH / 2
    t0 = math.radians(45)  # aperture: the ring stops 45 degrees below the right horizontal
    po0 = (cx + ro * math.cos(t0), cy + ro * math.sin(t0))
    pi0 = (cx + ri * math.cos(t0), cy + ri * math.sin(t0))
    ring = (f"M{f(po0[0])} {f(po0[1])}A{f(ro)} {f(ro)} 0 1 1 {f(cx + ro)} {f(cy)}"
            f"L{f(cx + ri)} {f(cy)}A{f(ri)} {f(ri)} 0 1 0 {f(pi0[0])} {f(pi0[1])}Z")
    top, bot = cy - 5.0, cy - 5.0 + BAR  # bar sits just below centre to keep the eye open
    edge = lambda y: cx + math.sqrt(ro * ro - (y - cy) ** 2)  # bar ends on the outer curve
    bar = (f"M{f(cx - ri - 1)} {f(top)}L{f(edge(top))} {f(top)}"
           f"A{f(ro)} {f(ro)} 0 0 1 {f(edge(bot))} {f(bot)}L{f(cx - ri - 1)} {f(bot)}Z")
    return [(ring, False), (bar, False)], 2 * ro


def letter_a(x):
    ro = XH / 2 + OS
    ri = ro - RS
    cx, cy = x + ro, XH / 2
    circle = lambda r: (f"M{f(cx + r)} {f(cy)}A{f(r)} {f(r)} 0 1 0 {f(cx - r)} {f(cy)}"
                        f"A{f(r)} {f(r)} 0 1 0 {f(cx + r)} {f(cy)}Z")
    sx = cx + ro - HW  # stem right edge sits flush with the bowl (no step)
    stem = f"M{f(sx)} {f(-OS + 1.5)}L{f(sx + HW)} {f(-OS + 1.5)}L{f(sx + HW)} {f(XH)}L{f(sx)} {f(XH)}Z"
    return [(circle(ro) + circle(ri), True), (stem, False)], sx + HW - x


# Optical spacing between letters (units of the 100 x-height).
SPACING = {"we": 6.0, "ea": 8.0, "av": 4.0, "ve": 6.0}


def wordmark(color, x0=0.0):
    body, x = "", x0
    for letter, gap in ((letter_w, "we"), (letter_e, "ea"), (letter_a, "av"), (letter_v, "ve"), (letter_e, None)):
        shapes, w = letter(x)
        for d, even_odd in shapes:
            rule = ' fill-rule="evenodd"' if even_odd else ""
            body += f'<path fill="{color}"{rule} d="{d}"/>'
        x += w + (SPACING[gap] if gap else 0)
    return f"<g>{body}</g>", x - x0


WORD_W = wordmark(INK)[1]


# ---------------------------------------------------------------------------
# Files
# ---------------------------------------------------------------------------

def svg(body, w, h, title="Weave logo"):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {f(w)} {f(h)}" width="{f(w)}" height="{f(h)}">'
            f'<title>{title}</title>{body}</svg>\n')


def tile(color, size=256, rx=58):
    return f'<rect width="{size}" height="{size}" rx="{rx}" fill="{color}"/>'


def scaled(body, s, tx=0.0, ty=0.0):
    return f'<g transform="translate({f(tx)} {f(ty)}) scale({f(s)})">{body}</g>'


# Mark bounds on the 256 canvas (used to align lockups).
MARK_TOP, MARK_BOTTOM = 34.5, 216.5


def lockup_horizontal(mark_body, word_color):
    # Symbol height 182 (ring bounds) ; wordmark x-height = 0.55 x symbol height.
    s = 1.0
    xh_scale = 0.48 * (MARK_BOTTOM - MARK_TOP) / XH
    gap = 0.32 * (MARK_BOTTOM - MARK_TOP)
    word, _ = wordmark(word_color)
    wx = 224 + gap
    wy = (MARK_TOP + MARK_BOTTOM) / 2 - XH * xh_scale / 2
    width = wx + WORD_W * xh_scale + 32
    return svg(mark_body + scaled(word, xh_scale, wx, wy), width, 256)


def lockup_stacked(mark_body, word_color):
    xh_scale = 0.30 * (MARK_BOTTOM - MARK_TOP) / XH
    word, _ = wordmark(word_color)
    ww = WORD_W * xh_scale
    width = max(256.0, ww + 64)
    mx = (width - 256) / 2
    wy = MARK_BOTTOM + 34
    return svg(scaled(mark_body, 1, mx, 0) + scaled(word, xh_scale, (width - ww) / 2, wy), width, wy + XH * xh_scale + 32)


def icon_art(bg, colors, size=1024, scale=0.66):
    # Full-bleed square for the App Store icon (iOS applies the corner mask).
    s = size / 256 * scale
    t = size * (1 - scale) / 2
    return svg(f'<rect width="{size}" height="{size}" fill="{bg}"/>' + scaled(MARK.svg(colors), s, t, t - size * 0.012),
               size, size, "Weave app icon")


def main(out):
    out = pathlib.Path(out)
    out.mkdir(parents=True, exist_ok=True)
    files = {
        # symbol
        "weave-symbol-color.svg": svg(MARK.svg(RINGS), 256, 256),
        "weave-symbol-black.svg": svg(MARK.svg(INK), 256, 256),
        "weave-symbol-white.svg": svg(MARK_REVERSED.svg(WHITE), 256, 256),
        "weave-symbol-green.svg": svg(MARK.svg(BRAND), 256, 256),
        "weave-symbol-small.svg": svg(MARK_SMALL.svg(INK), 256, 256),
        "weave-symbol-small-color.svg": svg(MARK_SMALL.svg(RINGS), 256, 256),
        "weave-symbol-tile.svg": svg(tile(INK) + scaled(MARK.svg(RINGS), 0.78, 28.16, 24), 256, 256),
        # wordmark
        "weave-wordmark-black.svg": svg(wordmark(INK)[0], WORD_W, XH, "Weave wordmark"),
        "weave-wordmark-white.svg": svg(wordmark(WHITE)[0], WORD_W, XH, "Weave wordmark"),
        # lockups
        "weave-horizontal-color-on-dark.svg": lockup_horizontal(MARK_REVERSED.svg(RINGS), WHITE),
        "weave-horizontal-black.svg": lockup_horizontal(MARK.svg(INK), INK),
        "weave-horizontal-white.svg": lockup_horizontal(MARK_REVERSED.svg(WHITE), WHITE),
        "weave-horizontal-green.svg": lockup_horizontal(MARK.svg(BRAND), INK),
        "weave-stacked-color-on-dark.svg": lockup_stacked(MARK_REVERSED.svg(RINGS), WHITE),
        "weave-stacked-black.svg": lockup_stacked(MARK.svg(INK), INK),
        # web icons: colour rings on the ink tile
        "web-favicon.svg": svg(tile(INK) + scaled(MARK_SMALL.svg(RINGS), 0.86, 17.92, 14), 256, 256, "Weave"),
        "web-icon.svg": svg(f'<rect width="256" height="256" fill="{INK}"/>' + scaled(MARK.svg(RINGS), 0.74, 33.28, 28), 256, 256, "Weave"),
        "web-icon-maskable.svg": svg(f'<rect width="256" height="256" fill="{INK}"/>' + scaled(MARK.svg(RINGS), 0.58, 53.76, 50), 256, 256, "Weave"),
        # app icon art (1024, full bleed)
        "appicon-default.svg": icon_art(BRAND, RINGS),
        "appicon-dark.svg": icon_art("#0B0B0C", RINGS),
        "appicon-tinted.svg": icon_art("#000000", ["#FFFFFF", "#C8C8C8", "#969696"]),
    }
    for name, content in files.items():
        (out / name).write_text(content)
    print(f"wrote {len(files)} files to {out}")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "svg")
