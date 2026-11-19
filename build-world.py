#!/usr/bin/env python3
"""v1.6 world generator — builds src/workspace/World.model.json deterministically.

Original code for BRAINROT MEGA UNIVERSE v1.6. Layout follows
v1.5-design/builder-brief.md section 3 and texture-design.md. Seeded RNG
(seed 16) so the world — and the screenshots rendered from it — are identical
on every run. Also emits render/manifest.json (grove spots, code platform,
camera views, avatar spots) for the Three.js screenshot renderer.
"""
import json
import math
import random
import os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "src", "workspace", "World.model.json")
MANIFEST = os.path.join(HERE, "render", "manifest.json")

rng = random.Random(16)


def rgb(r, g, b):
    return [round(r / 255, 4), round(g / 255, 4), round(b / 255, 4)]


def rot(rx=0.0, ry=0.0, rz=0.0):
    """Rotation matrix rows for CFrame.Angles(rx, ry, rz) (Y-X-Z order)."""
    cx, sx = math.cos(rx), math.sin(rx)
    cy, sy = math.cos(ry), math.sin(ry)
    cz, sz = math.cos(rz), math.sin(rz)
    # Ry * Rx * Rz
    return [
        [cy * cz + sy * sx * sz, -cy * sz + sy * sx * cz, sy * cx],
        [cx * sz, cx * cz, -sx],
        [-sy * cz + cy * sx * sz, sy * sz + cy * sx * cz, cy * cx],
    ]


def cframe(x, y, z, rx=0.0, ry=0.0, rz=0.0):
    m = rot(rx, ry, rz)
    return [x, y, z,
            m[0][0], m[0][1], m[0][2],
            m[1][0], m[1][1], m[1][2],
            m[2][0], m[2][1], m[2][2]]


def part(name, pos, size, color, material, shape="Block", anchored=True,
         collide=True, transparency=0.0, rx=0.0, ry=0.0, rz=0.0, cls="Part"):
    props = {
        "Anchored": anchored,
        "CanCollide": collide,
        "Size": [round(float(size[0]), 3), round(float(size[1]), 3), round(float(size[2]), 3)],
        "CFrame": [round(float(v), 3) for v in cframe(pos[0], pos[1], pos[2], rx, ry, rz)],
        "Color": color,
        "Material": material,
    }
    if transparency:
        props["Transparency"] = transparency
    if shape != "Block":
        props["Shape"] = shape
    return {"className": cls, "name": name, "properties": props}


def surface_gui(name, face, children):
    return {"className": "SurfaceGui", "name": name,
            "properties": {"Face": face, "LightInfluence": 0},
            "children": children}


def text_label(name, text, size=24, color=None, font="FredokaOne"):
    return {"className": "TextLabel", "name": name,
            "properties": {
                "Text": text,
                "TextSize": size,
                "Font": font,
                "TextColor3": color or [1, 1, 1],
                "BackgroundTransparency": 1,
                "Size": {"UDim2": [[1, 0], [1, 0]]},
            }}


children = []

# ---------------------------------------------------------------- ground ----
children.append(part("GroundBase", (0, -2, 0), (420, 4, 420),
                     rgb(80, 65, 45), "Ground"))

# Rolling hills: flattened spheres at the map edges.
for i in range(12):
    ang = rng.uniform(0, math.tau)
    dist = rng.uniform(120, 190)
    hx, hz = math.cos(ang) * dist, math.sin(ang) * dist
    r = rng.uniform(30, 70)
    children.append(part("Hill", (hx, -2, hz), (r, rng.uniform(6, 14), r),
                          rgb(70, 110, 45) if i % 2 else rgb(80, 65, 45),
                          "Ground", shape="Ball"))

# ---------------------------------------------------------------- paths -----
def path_segment(a, b, width=3.0):
    mx, mz = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
    length = math.hypot(b[0] - a[0], b[1] - a[1]) + 1.5
    ang = math.atan2(b[0] - a[0], b[1] - a[1])
    children.append(part("DirtPath", (mx, 0.16, mz), (width, 0.3, length),
                          rgb(115, 85, 55), "Slate", ry=ang))
    # stepping stones along the edges
    steps = int(length // 3)
    for s in range(steps):
        t = (s + 0.5) / max(steps, 1)
        sx = a[0] + (b[0] - a[0]) * t + rng.uniform(-1.6, 1.6)
        sz = a[1] + (b[1] - a[1]) * t + rng.uniform(-1.6, 1.6)
        children.append(part("PathStone", (sx, 0.2, sz),
                              (rng.uniform(0.8, 1.4), 0.25, rng.uniform(0.8, 1.4)),
                              rgb(90, 85, 75), "Rock", ry=rng.uniform(0, math.tau)))

PATHS = [
    [(0, 15), (0, 8), (0, 0)],
    [(0, -2), (-4, -20), (-10, -38)],
    [(6, 2), (20, -2), (32, -8)],
    [(4, -8), (10, -25), (15, -36)],
    [(-6, 6), (-14, 14), (-22, 24)],
]
for route in PATHS:
    for a, b in zip(route, route[1:]):
        path_segment(a, b)

# --------------------------------------------------------------- fountain ---
for i in range(16):
    ang = (i / 16) * math.tau
    x, z = math.cos(ang) * 6, math.sin(ang) * 6
    children.append(part("FountainStone", (x, 1.5, z), (1.9, 3, 1.6),
                          rgb(110, 115, 120), "Cobblestone", ry=-ang))
children.append(part("FountainWater", (0, 1.0, 0), (1.0, 10.4, 10.4),
                     rgb(50, 120, 170), "Glass", shape="Cylinder",
                     transparency=0.2, rz=math.pi / 2))
children.append(part("FountainCore", (0, 2.2, 0), (2.4, 1.6, 1.6),
                     rgb(110, 115, 120), "Cobblestone", shape="Cylinder",
                     rz=math.pi / 2))

# ------------------------------------------------------------------ lake ----
children.append(part("LakeWater", (-10, -0.75, -45), (44, 1.5, 32),
                     rgb(35, 95, 140), "Glass", transparency=0.4))
for i in range(22):
    ang = rng.uniform(0, math.tau)
    x = -10 + math.cos(ang) * rng.uniform(20, 24)
    z = -45 + math.sin(ang) * rng.uniform(14, 18)
    children.append(part("LakeRock", (x, -0.4, z),
                          (rng.uniform(1.5, 3.5), rng.uniform(1, 2.5), rng.uniform(1.5, 3.5)),
                          rgb(90, 95, 100), "Slate", ry=rng.uniform(0, math.tau)))

# -------------------------------------------------------------- waterfall ---
# Cliff face: stacked jagged rocks.
for i in range(42):
    x = -40 + rng.uniform(-9, 9)
    y = rng.uniform(1, 27)
    z = -70 + rng.uniform(-3, 2)
    children.append(part("CliffRock", (x, y, z),
                          (rng.uniform(3, 7), rng.uniform(2, 5), rng.uniform(2, 4)),
                          rgb(75, 80, 85), "Slate",
                          rx=rng.uniform(-0.2, 0.2), ry=rng.uniform(0, math.tau)))
# Water sheets in front of the cliff.
for dx, w in ((-4, 5), (0, 7), (4.5, 5)):
    children.append(part("FallSheet", (-40 + dx, 14, -66.5), (w, 26, 0.6),
                          rgb(200, 220, 240), "Glass", transparency=0.3))
# Rainbow arc: neon blocks arranged in a half circle inside the mist zone.
for i in range(12):
    t = (i / 11) * math.pi
    x = -36 + math.cos(t) * 6
    y = 6 + math.sin(t) * 6
    children.append(part("RainbowArc", (x, y, -64), (1.1, 1.1, 1.1),
                          rgb(255, 120, 200), "Neon", transparency=0.5,
                          collide=False))

# ---------------------------------------------------------- karaoke deck ----
children.append(part("KaraokeDeck", (15, 0.5, -40), (18, 1, 18),
                     rgb(120, 80, 50), "WoodPlanks"))
children.append(part("MicStand", (15, 2.6, -44), (3.2, 0.3, 0.3),
                     rgb(40, 40, 40), "Metal", shape="Cylinder", rz=math.pi / 2))
children.append(part("MicHead", (15, 4.4, -44), (0.8, 0.8, 0.8),
                     rgb(40, 40, 40), "Metal", shape="Ball"))
for sx in (-6, 6):
    children.append(part("DeckPost", (15 + sx, 3.5, -46), (0.6, 6, 0.6),
                         rgb(95, 55, 35), "Wood"))
children.append(part("DeckRoof", (15, 6.8, -43), (16, 0.6, 10),
                     rgb(95, 55, 35), "WoodPlanks"))
for sx in (-8, 8):
    children.append(part("Speaker", (15 + sx, 2.5, -47), (3, 4, 2),
                         rgb(20, 20, 20), "SmoothPlastic"))
screen = part("KaraokeScreen", (15, 4.5, -48.5), (11, 6, 0.5),
              rgb(15, 15, 25), "SmoothPlastic")
screen["children"] = [surface_gui("ScreenGui", "Front",
    [text_label("ScreenText", "♪ KARAOKE — antrean kosong, ayo nyanyi!", 28)])]
children.append(screen)

# ------------------------------------------------------------ rope bridge ---
for i in range(12):
    z = -20 - i * 2.1
    children.append(part("BridgePlank", (-10, 2.1, z), (4, 0.5, 1.5),
                          rgb(100, 65, 40), "WoodPlanks"))
for side in (-2.2, 2.2):
    for seg in range(3):
        z0 = -20 - seg * 8.4
        children.append(part("BridgeRope", (-10 + side, 3.6, z0 - 4),
                              (0.25, 0.25, 8.6), rgb(60, 45, 30),
                              "SmoothPlastic", rx=0.06 if seg == 1 else 0))

# ------------------------------------------------------------------ cabin ---
cx, cz = 35, -10
children.append(part("CabinFloor", (cx, 0.6, cz), (16, 1, 14),
                     rgb(120, 80, 50), "WoodPlanks"))
for wy, wz in ((5.5, -6.5), (5.5, 6.5)):
    children.append(part("CabinWall", (cx, wy, cz + wz), (16, 10, 1),
                         rgb(95, 55, 35), "Wood"))
for wx in (-7.5, 7.5):
    children.append(part("CabinWall", (cx + wx, 5.5, cz), (1, 10, 14),
                         rgb(95, 55, 35), "Wood"))
# log trim on the front wall
for ly in (1.5, 4.5, 7.5):
    children.append(part("CabinLog", (cx, ly, cz - 7.2), (16, 1.2, 0.8),
                         rgb(65, 45, 30), "Wood", shape="Cylinder"))
children.append(part("CabinRoofL", (cx - 4, 12.5, cz), (10, 0.8, 15),
                     rgb(70, 40, 25), "WoodPlanks", rz=0.5))
children.append(part("CabinRoofR", (cx + 4, 12.5, cz), (10, 0.8, 15),
                     rgb(70, 40, 25), "WoodPlanks", rz=-0.5))
children.append(part("CabinWindow", (cx - 4, 6, cz - 7.1), (3, 3, 0.3),
                     rgb(255, 170, 60), "Neon"))
children.append(part("CabinWindow", (cx + 4, 6, cz - 7.1), (3, 3, 0.3),
                     rgb(255, 170, 60), "Neon"))
children.append(part("CabinDoor", (cx, 3.5, cz - 7.1), (3.5, 6, 0.4),
                     rgb(45, 25, 15), "Wood"))
children.append(part("CabinPorch", (cx, 0.7, cz - 10), (12, 0.6, 6),
                     rgb(120, 80, 50), "WoodPlanks"))

# ------------------------------------------------------------ market stalls --
for sx, sz in ((20, 10), (28, 15)):
    children.append(part("StallCounter", (sx, 1.5, sz), (4.5, 2, 2),
                         rgb(120, 80, 50), "WoodPlanks"))
    for px, pz in ((-2, -0.8), (2, -0.8), (-2, 0.8), (2, 0.8)):
        children.append(part("StallPost", (sx + px, 3.5, sz + pz), (0.4, 4, 0.4),
                             rgb(95, 55, 35), "Wood"))
    for i in range(5):
        col = rgb(210, 70, 70) if i % 2 == 0 else rgb(240, 240, 240)
        children.append(part("AwningStripe", (sx - 2.4 + i * 1.2, 5.6, sz),
                             (1.2, 0.25, 4), col, "Fabric", rx=0.15))
    children.append(part("StallGoods", (sx, 2.9, sz), (3.5, 0.8, 1.4),
                         rgb(240, 210, 80), "SmoothPlastic", shape="Ball"))

# ---------------------------------------------------------------- benches ---
BENCH_SPOTS = [(-8, 6), (-2, -28), (30, -2), (-25, 30), (12, 12)]
for bx, bz in BENCH_SPOTS:
    children.append(part("BenchSeat", (bx, 1.0, bz), (4, 0.4, 1.6),
                         rgb(110, 70, 45), "WoodPlanks"))
    children.append(part("BenchBack", (bx, 2.0, bz + 0.8), (4, 1.2, 0.3),
                         rgb(110, 70, 45), "WoodPlanks"))
    for lx in (-1.7, 1.7):
        children.append(part("BenchLeg", (bx + lx, 0.5, bz), (0.4, 1, 1.4),
                             rgb(40, 40, 40), "Metal"))
    seat = part("SeatPart", (bx, 1.45, bz), (2, 0.5, 1.4),
                rgb(110, 70, 45), "WoodPlanks", cls="Seat")
    seat["name"] = "BenchSeatInstance"
    children.append(seat)

# --------------------------------------------------------------- signpost ---
children.append(part("Signpost", (8, 2, 8), (4, 0.6, 0.6),
                     rgb(65, 45, 30), "Wood", shape="Cylinder", rz=math.pi / 2))
SIGNS = [("Hutan", 0.6), ("Air Terjun", 1.4), ("Air Mancur", 2.2), ("Karaoke Deck", 3.0)]
for label, y in SIGNS:
    board = part("SignBoard", (8, y + 1, 8), (4.5, 0.9, 0.25),
                 rgb(120, 80, 50), "WoodPlanks")
    board["children"] = [surface_gui("BoardGui", "Front",
        [text_label("BoardText", label, 20)])]
    children.append(board)

# ------------------------------------------------------------------- lamps --
for lx, lz in ((-4, 18), (5, 20), (-8, -12), (12, -18), (-18, -34), (24, 4)):
    children.append(part("LampPole", (lx, 2, lz), (4, 0.35, 0.35),
                         rgb(40, 40, 40), "Metal", shape="Cylinder", rz=math.pi / 2))
    children.append(part("LampGlow", (lx, 4.3, lz), (0.9, 0.9, 0.9),
                         rgb(255, 200, 100), "Neon", shape="Ball"))

# -------------------------------------------------------------- god rays ----
for gx, gz in ((-20, -10), (-5, -30), (-30, 20), (10, -15), (0, 5)):
    children.append(part("GodRay", (gx, 14, gz), (2, 28, 0.6),
                          rgb(255, 240, 210), "SmoothPlastic",
                          transparency=0.94, collide=False,
                          rx=0.1, ry=0.3, rz=0.15))

# ------------------------------------------------------------------ trees ---
def tree(x, z, tall=False):
    h = rng.uniform(20, 32) if tall else rng.uniform(12, 20)
    d = rng.uniform(1.5, 2.5)
    children.append(part("Trunk", (x, h / 2, z),
                          (h, d, d),
                          rgb(65, 45, 30), "Wood", shape="Cylinder", rz=math.pi / 2))
    layers = rng.randint(9, 13)
    for i in range(layers):
        t = i / max(layers - 1, 1)
        sy = h * (0.45 + 0.5 * t)
        spread = (1 - t * 0.55) * rng.uniform(3.5, 5.5)
        ox = rng.uniform(-spread, spread)
        oz = rng.uniform(-spread, spread)
        r = rng.uniform(3.5, 6.5) * (1 - t * 0.35)
        col = [rgb(20, 50, 30), rgb(45, 95, 50), rgb(90, 140, 60)][i % 3]
        children.append(part("Canopy", (x + ox, sy, z + oz), (r, r * 0.8, r),
                             col, "LeafyGrass", shape="Ball", collide=False))

TREE_SPOTS = []
tries = 0
while len(TREE_SPOTS) < 46 and tries < 600:
    tries += 1
    x = rng.uniform(-95, 95)
    z = rng.uniform(-95, 95)
    if math.hypot(x, z) < 16:  # keep the plaza clear
        continue
    if -34 < x < 14 and -62 < z < -28:  # keep the lake clear
        continue
    if 25 < x < 45 and -20 < z < 0:  # keep the cabin clear
        continue
    if 4 < x < 26 and -50 < z < -30:  # keep the karaoke deck clear
        continue
    if any(math.hypot(x - px, z - pz) < 9 for px, pz in TREE_SPOTS):
        continue
    TREE_SPOTS.append((x, z))
for i, (x, z) in enumerate(TREE_SPOTS):
    tree(x, z, tall=(i % 7 == 0))

# Treehouse in the big pine at (-40, 22, 25).
tree(-40, 25, tall=True)
children.append(part("TreehouseFloor", (-40, 22, 25), (8, 1, 8),
                     rgb(120, 80, 50), "WoodPlanks"))
children.append(part("TreehouseRoof", (-40, 26.5, 25), (9, 0.6, 9),
                     rgb(210, 70, 70), "Fabric"))
children.append(part("TreehouseLadder", (-36.5, 12, 25), (0.5, 20, 1.5),
                     rgb(100, 65, 40), "WoodPlanks"))

# ------------------------------------------------------------------ grass --
# Dense meadow patches break up the brown ground into a green NGOBROL meadow.
MEADOW_COLORS = [rgb(70, 130, 50), rgb(90, 140, 60), rgb(55, 110, 45)]
for _ in range(46):
    mx = rng.uniform(-90, 90)
    mz = rng.uniform(-90, 90)
    if math.hypot(mx, mz) < 9:
        continue
    if -34 < mx < 14 and -62 < mz < -28:
        continue
    children.append(part("Meadow", (mx, 0.1, mz),
                          (rng.uniform(12, 30), 0.25, rng.uniform(12, 30)),
                          rng.choice(MEADOW_COLORS), "LeafyGrass",
                          ry=rng.uniform(0, math.tau)))

GRASS_COLORS = [rgb(34, 68, 34), rgb(70, 130, 50), rgb(140, 185, 50)]
blades = 0
tries = 0
while blades < 2600 and tries < 20000:
    tries += 1
    # Bias density toward the central play area so the cover reads as meadow.
    if rng.random() < 0.6:
        ang = rng.uniform(0, math.tau)
        dist = rng.uniform(0, 70)
        x, z = math.cos(ang) * dist, math.sin(ang) * dist
    else:
        x = rng.uniform(-90, 90)
        z = rng.uniform(-90, 90)
    if math.hypot(x, z) < 9:
        continue
    if -34 < x < 14 and -62 < z < -28:
        continue
    h = rng.uniform(1.0, 2.6)
    children.append(part("GrassBlade", (x, h / 2, z),
                          (rng.uniform(0.2, 0.3), h, rng.uniform(0.2, 0.3)),
                          rng.choice(GRASS_COLORS),
                          rng.choice(["LeafyGrass", "Grass"]),
                          collide=False,
                          rx=rng.uniform(-0.26, 0.26), rz=rng.uniform(-0.26, 0.26)))
    blades += 1

# --------------------------------------------------------------- wildflowers --
FLOWER_COLORS = [rgb(240, 240, 240), rgb(230, 140, 160), rgb(240, 210, 80)]
for _ in range(140):
    x = rng.uniform(-80, 80)
    z = rng.uniform(-80, 80)
    if math.hypot(x, z) < 9:
        continue
    if -34 < x < 14 and -62 < z < -28:
        continue
    children.append(part("FlowerStem", (x, 0.4, z), (0.8, 0.12, 0.12),
                         rgb(70, 130, 50), "Grass", shape="Cylinder",
                         collide=False, rz=math.pi / 2))
    children.append(part("FlowerHead", (x, 0.9, z), (0.32, 0.32, 0.32),
                         rng.choice(FLOWER_COLORS), "SmoothPlastic",
                         shape="Ball", collide=False))

# ------------------------------------------------------------ scattered rocks --
for _ in range(30):
    x = rng.uniform(-90, 90)
    z = rng.uniform(-90, 90)
    if math.hypot(x, z) < 10:
        continue
    children.append(part("Rock", (x, 0.6, z),
                          (rng.uniform(1, 3), rng.uniform(0.8, 2), rng.uniform(1, 3)),
                          rgb(90, 95, 100), "Slate", ry=rng.uniform(0, math.tau)))

# ------------------------------------------------------------ spawn location --
spawn = part("SpawnLocation", (0, 2, 15), (6, 1, 6),
             rgb(110, 115, 120), "Slate", cls="SpawnLocation")
spawn["properties"]["Neutral"] = True
children.append(spawn)

model = {"className": "Model", "name": "World", "children": children}
os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, "w") as f:
    json.dump(model, f, separators=(",", ":"))

manifest = {
    "groves": [[-55, 0, 20], [55, 0, 30], [-62, 0, -30], [45, 0, -55], [0, 0, 60]],
    "platform": {"center": [0, 0, 15], "size": [40, 2, 40], "color": [150, 105, 60]},
    "cameras": {
        "1-hub": {"pos": [-26, 21, 50], "target": [2, 8, -25]},
        "2-bazaar": {"pos": [48, 14, 38], "target": [15, 4, -40]},
        "3-boss": {"pos": [-6, 14, -14], "target": [-40, 10, -68]},
    },
    "avatars": [
        {"pos": [-8, 1.2, 6], "sit": True, "shirt": [210, 70, 70]},
        {"pos": [13, 1, -36], "sit": False, "shirt": [70, 130, 200]},
        {"pos": [-2, 1.2, -28], "sit": True, "shirt": [240, 210, 80]},
    ],
    "instance_count": len(children),
}
os.makedirs(os.path.dirname(MANIFEST), exist_ok=True)
with open(MANIFEST, "w") as f:
    json.dump(manifest, f, indent=1)

print("world parts:", len(children))
print("wrote", OUT, os.path.getsize(OUT), "bytes")
print("wrote", MANIFEST)
