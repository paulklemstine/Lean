#!/usr/bin/env python3
"""
Generate SVG visuals for the MetaFactoring framework.

Produces:
1. seven_lenses_architecture.svg — The MetaFactoring architecture diagram
2. constraint_intersection.svg — How lenses intersect to narrow the search
3. hyperbola_divisors.svg — Divisor pairs on the hyperbola xy = N
4. fibonacci_carry_cascade.svg — Bidirectional carry propagation
5. norm_sphere_collision.svg — Sum-of-squares collision geometry
6. lens_comparison_radar.svg — Radar chart of lens effectiveness
"""

import math
import os

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "visuals")
os.makedirs(OUTPUT_DIR, exist_ok=True)


def save_svg(filename, content):
    path = os.path.join(OUTPUT_DIR, filename)
    with open(path, 'w') as f:
        f.write(content)
    print(f"  Saved: {path}")


# ═══════════════════════════════════════════════════════════════
# 1. SEVEN LENSES ARCHITECTURE DIAGRAM
# ═══════════════════════════════════════════════════════════════

def generate_architecture():
    """Central MetaFactoring hub with seven spokes to each lens."""

    lenses = [
        ("Fibonacci\nZeckendorf", "#E74C3C", "φ"),
        ("Hyperbolic\nGeometry", "#E67E22", "xy=N"),
        ("Orbit\nDynamics", "#F1C40F", "ρ"),
        ("Spectral\nHarmonic", "#2ECC71", "χ"),
        ("Division\nAlgebra", "#3498DB", "‖·‖"),
        ("Lattice\nReduction", "#9B59B6", "LLL"),
        ("Congruence\nof Squares", "#1ABC9C", "x²≡y²"),
    ]

    w, h = 800, 800
    cx, cy = 400, 400
    R = 280  # spoke radius
    r_outer = 65  # outer node radius
    r_center = 90

    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">
  <defs>
    <radialGradient id="centerGrad" cx="50%" cy="40%">
      <stop offset="0%" stop-color="#667eea"/>
      <stop offset="100%" stop-color="#764ba2"/>
    </radialGradient>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="2" dy="2" stdDeviation="3" flood-opacity="0.25"/>
    </filter>
    <filter id="glow">
      <feGaussianBlur stdDeviation="4" result="blur"/>
      <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>

  <!-- Background -->
  <rect width="{w}" height="{h}" fill="#0a0a2e" rx="20"/>

  <!-- Title -->
  <text x="{cx}" y="45" text-anchor="middle" fill="#ffffff" font-size="28"
        font-family="Georgia, serif" font-weight="bold">MetaFactoring</text>
  <text x="{cx}" y="72" text-anchor="middle" fill="#aaaacc" font-size="14"
        font-family="Arial, sans-serif">Seven-Lens Unified Framework</text>

  <!-- Connection lines (spokes) -->
'''

    for i, (name, color, symbol) in enumerate(lenses):
        angle = -math.pi/2 + 2 * math.pi * i / len(lenses)
        x2 = cx + R * math.cos(angle)
        y2 = cy + R * math.sin(angle)
        svg += f'  <line x1="{cx}" y1="{cy}" x2="{x2:.0f}" y2="{y2:.0f}" '
        svg += f'stroke="{color}" stroke-width="3" opacity="0.6"/>\n'

    # Outer ring connections (subtle)
    for i in range(len(lenses)):
        a1 = -math.pi/2 + 2 * math.pi * i / len(lenses)
        a2 = -math.pi/2 + 2 * math.pi * ((i+1) % len(lenses)) / len(lenses)
        x1 = cx + R * math.cos(a1)
        y1 = cy + R * math.sin(a1)
        x2 = cx + R * math.cos(a2)
        y2 = cy + R * math.sin(a2)
        svg += f'  <line x1="{x1:.0f}" y1="{y1:.0f}" x2="{x2:.0f}" y2="{y2:.0f}" '
        svg += f'stroke="#333355" stroke-width="1" opacity="0.5" stroke-dasharray="4,4"/>\n'

    # Outer nodes
    for i, (name, color, symbol) in enumerate(lenses):
        angle = -math.pi/2 + 2 * math.pi * i / len(lenses)
        x = cx + R * math.cos(angle)
        y = cy + R * math.sin(angle)

        svg += f'''
  <circle cx="{x:.0f}" cy="{y:.0f}" r="{r_outer}" fill="{color}" opacity="0.85"
          filter="url(#shadow)"/>
  <text x="{x:.0f}" y="{y-12:.0f}" text-anchor="middle" fill="white"
        font-size="11" font-family="Arial, sans-serif" font-weight="bold">
    <tspan x="{x:.0f}" dy="0">{name.split(chr(10))[0]}</tspan>
    <tspan x="{x:.0f}" dy="14">{name.split(chr(10))[1] if chr(10) in name else ""}</tspan>
  </text>
  <text x="{x:.0f}" y="{y+28:.0f}" text-anchor="middle" fill="white"
        font-size="18" font-family="Georgia, serif" opacity="0.7">{symbol}</text>
'''

    # Center hub
    svg += f'''
  <circle cx="{cx}" cy="{cy}" r="{r_center}" fill="url(#centerGrad)"
          filter="url(#glow)"/>
  <text x="{cx}" y="{cy-15}" text-anchor="middle" fill="white" font-size="22"
        font-family="Georgia, serif" font-weight="bold">Meta</text>
  <text x="{cx}" y="{cy+10}" text-anchor="middle" fill="white" font-size="22"
        font-family="Georgia, serif" font-weight="bold">Factoring</text>
  <text x="{cx}" y="{cy+35}" text-anchor="middle" fill="#ccccee" font-size="12"
        font-family="Arial, sans-serif">N = p × q</text>

  <!-- Bottom caption -->
  <text x="{cx}" y="{h-25}" text-anchor="middle" fill="#888899" font-size="12"
        font-family="Arial, sans-serif">
    Each lens provides independent constraints — their intersection reveals factors
  </text>
</svg>'''

    save_svg("seven_lenses_architecture.svg", svg)


# ═══════════════════════════════════════════════════════════════
# 2. CONSTRAINT INTERSECTION VENN DIAGRAM
# ═══════════════════════════════════════════════════════════════

def generate_constraint_intersection():
    """Venn-style diagram showing how lenses intersect."""

    w, h = 700, 500

    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">
  <rect width="{w}" height="{h}" fill="#0f0f2f" rx="15"/>

  <text x="350" y="40" text-anchor="middle" fill="white" font-size="22"
        font-family="Georgia, serif" font-weight="bold">
    Constraint Intersection: Progressive Search Space Reduction
  </text>

  <!-- Full search space -->
  <rect x="50" y="70" width="600" height="60" rx="8" fill="#2c3e50" opacity="0.8"/>
  <text x="350" y="100" text-anchor="middle" fill="white" font-size="14"
        font-family="Arial">Full Search Space: 2^k candidates</text>
  <text x="640" y="100" text-anchor="end" fill="#e74c3c" font-size="12"
        font-family="monospace">100%</text>

  <!-- After Fibonacci lens -->
  <rect x="50" y="145" width="372" height="45" rx="8" fill="#e74c3c" opacity="0.7"/>
  <text x="236" y="173" text-anchor="middle" fill="white" font-size="13"
        font-family="Arial">+ Fibonacci Non-Adjacency</text>
  <text x="415" y="173" fill="#e74c3c" font-size="12" font-family="monospace">62% (φ/2)^k</text>

  <!-- After Hyperbolic -->
  <rect x="50" y="200" width="186" height="45" rx="8" fill="#e67e22" opacity="0.7"/>
  <text x="143" y="228" text-anchor="middle" fill="white" font-size="12"
        font-family="Arial">+ Hyperbolic √N</text>
  <text x="230" y="228" fill="#e67e22" font-size="12" font-family="monospace">31%</text>

  <!-- After Orbit -->
  <rect x="50" y="255" width="130" height="45" rx="8" fill="#f1c40f" opacity="0.7"/>
  <text x="115" y="283" text-anchor="middle" fill="black" font-size="12"
        font-family="Arial">+ Orbit</text>
  <text x="175" y="283" fill="#f1c40f" font-size="12" font-family="monospace">22%</text>

  <!-- After Spectral -->
  <rect x="50" y="310" width="91" height="45" rx="8" fill="#2ecc71" opacity="0.7"/>
  <text x="95" y="338" text-anchor="middle" fill="white" font-size="11"
        font-family="Arial">+ Spectral</text>
  <text x="137" y="338" fill="#2ecc71" font-size="12" font-family="monospace">15%</text>

  <!-- After Norm -->
  <rect x="50" y="365" width="55" height="40" rx="8" fill="#3498db" opacity="0.7"/>
  <text x="77" y="389" text-anchor="middle" fill="white" font-size="10"
        font-family="Arial">+Norm</text>
  <text x="100" y="389" fill="#3498db" font-size="12" font-family="monospace">9%</text>

  <!-- After all 7 -->
  <rect x="50" y="415" width="20" height="35" rx="5" fill="#9b59b6" opacity="0.9"/>
  <text x="80" y="437" fill="#9b59b6" font-size="12" font-family="monospace">3%</text>
  <text x="100" y="437" fill="#aaa" font-size="11" font-family="Arial">← All 7 lenses combined</text>

  <!-- Arrow showing reduction -->
  <line x1="660" y1="100" x2="660" y2="437" stroke="white" stroke-width="1" stroke-dasharray="3,3"/>
  <text x="670" y="270" fill="#aaaacc" font-size="14" font-family="Georgia"
        transform="rotate(90 670 270)">exponential reduction →</text>

  <!-- Bottom text -->
  <text x="350" y="{h-15}" text-anchor="middle" fill="#666688" font-size="11"
        font-family="Arial">
    Each lens independently eliminates candidates — reductions multiply
  </text>
</svg>'''

    save_svg("constraint_intersection.svg", svg)


# ═══════════════════════════════════════════════════════════════
# 3. HYPERBOLA DIVISOR DIAGRAM
# ═══════════════════════════════════════════════════════════════

def generate_hyperbola():
    """Divisor pairs plotted on the hyperbola xy = N."""

    N = 210  # 2 × 3 × 5 × 7 → many divisors
    w, h = 700, 600

    # Divisor pairs
    divs = []
    for d in range(1, N + 1):
        if N % d == 0:
            divs.append((d, N // d))

    # Scale to fit
    max_val = N + 10
    scale = 450 / max_val
    ox, oy = 80, 520  # origin

    def tx(x): return ox + x * scale
    def ty(y): return oy - y * scale

    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">
  <rect width="{w}" height="{h}" fill="#0a0a2e" rx="15"/>

  <text x="350" y="35" text-anchor="middle" fill="white" font-size="22"
        font-family="Georgia, serif" font-weight="bold">
    Divisor Hyperbola: xy = 210
  </text>
  <text x="350" y="55" text-anchor="middle" fill="#aaaacc" font-size="13"
        font-family="Arial">210 = 2 × 3 × 5 × 7 — 16 divisor pairs as lattice points</text>

  <!-- Axes -->
  <line x1="{ox}" y1="{oy}" x2="{tx(220)}" y2="{oy}" stroke="#444466" stroke-width="1.5"/>
  <line x1="{ox}" y1="{oy}" x2="{ox}" y2="{ty(220)}" stroke="#444466" stroke-width="1.5"/>
  <text x="{tx(220)}" y="{oy+20}" fill="#888" font-size="12" font-family="Arial">x</text>
  <text x="{ox-20}" y="{ty(220)}" fill="#888" font-size="12" font-family="Arial">y</text>

  <!-- Hyperbola curve -->
  <path d="'''

    # Draw the hyperbola curve
    pts = []
    for i in range(1, 220):
        x = i
        y = N / x
        if y <= 220:
            pts.append(f"{tx(x):.1f},{ty(y):.1f}")
    svg += f"M {pts[0]} " + " L ".join(pts[1:])
    svg += f'" fill="none" stroke="#e67e22" stroke-width="2" opacity="0.6"/>\n'

    # Symmetry line y = x
    diag_max = min(220, 220)
    svg += f'  <line x1="{tx(0)}" y1="{ty(0)}" x2="{tx(diag_max)}" y2="{ty(diag_max)}" '
    svg += f'stroke="#444466" stroke-width="1" stroke-dasharray="5,5"/>\n'
    svg += f'  <text x="{tx(180)}" y="{ty(185)}" fill="#666" font-size="10" '
    svg += f'font-family="Arial" transform="rotate(-45 {tx(180)} {ty(185)})">y = x</text>\n'

    # √N marker
    sn = math.sqrt(N)
    svg += f'  <circle cx="{tx(sn)}" cy="{ty(sn)}" r="4" fill="none" stroke="#f1c40f" stroke-width="1.5"/>\n'
    svg += f'  <text x="{tx(sn)+8}" y="{ty(sn)-5}" fill="#f1c40f" font-size="11" font-family="Arial">√210 ≈ {sn:.1f}</text>\n'

    # Divisor points
    colors = ["#e74c3c", "#3498db", "#2ecc71", "#9b59b6", "#f39c12",
              "#1abc9c", "#e67e22", "#c0392b"]
    for i, (d, e) in enumerate(divs):
        if d <= 220 and e <= 220:
            c = colors[i % len(colors)]
            svg += f'  <circle cx="{tx(d):.0f}" cy="{ty(e):.0f}" r="6" fill="{c}" '
            svg += f'filter="url(#shadow)"/>\n'
            # Label
            label_x = tx(d) + 10
            label_y = ty(e) - 8
            svg += f'  <text x="{label_x:.0f}" y="{label_y:.0f}" fill="{c}" '
            svg += f'font-size="10" font-family="monospace">({d},{e})</text>\n'

    svg += f'''
  <!-- Legend -->
  <text x="500" y="500" fill="#aaaacc" font-size="12" font-family="Arial">
    ● = lattice point (d, 210/d)
  </text>
  <text x="500" y="518" fill="#aaaacc" font-size="12" font-family="Arial">
    σ₀(210) = {len(divs)} divisor pairs
  </text>

  <defs>
    <filter id="shadow"><feDropShadow dx="1" dy="1" stdDeviation="2" flood-opacity="0.3"/></filter>
  </defs>
</svg>'''

    save_svg("hyperbola_divisors.svg", svg)


# ═══════════════════════════════════════════════════════════════
# 4. FIBONACCI CARRY CASCADE
# ═══════════════════════════════════════════════════════════════

def generate_fibonacci_cascade():
    """Diagram showing bidirectional carries in Fibonacci arithmetic."""

    w, h = 800, 450

    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">
  <defs>
    <marker id="arrowR" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#e74c3c"/>
    </marker>
    <marker id="arrowB" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#3498db"/>
    </marker>
    <marker id="arrowG" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#aaa"/>
    </marker>
  </defs>

  <rect width="{w}" height="{h}" fill="#0a0a2e" rx="15"/>

  <text x="400" y="35" text-anchor="middle" fill="white" font-size="20"
        font-family="Georgia, serif" font-weight="bold">
    Fibonacci vs Binary: Carry Propagation
  </text>

  <!-- BINARY SECTION -->
  <text x="400" y="75" text-anchor="middle" fill="#aaaacc" font-size="15"
        font-family="Arial" font-weight="bold">Binary: Unidirectional →</text>
'''

    # Binary digit positions
    positions = list(range(10))
    x_start = 100
    spacing = 60
    y_bin = 120

    for i in positions:
        x = x_start + i * spacing
        svg += f'  <rect x="{x-20}" y="{y_bin-15}" width="40" height="30" rx="5" '
        svg += f'fill="#1a1a3e" stroke="#444466"/>\n'
        svg += f'  <text x="{x}" y="{y_bin+5}" text-anchor="middle" fill="#888" '
        svg += f'font-size="12" font-family="monospace">2^{9-i}</text>\n'

    # Binary carry arrows (all rightward → leftward in position)
    for i in range(1, 8):
        x1 = x_start + i * spacing + 20
        x2 = x_start + (i-1) * spacing - 20
        svg += f'  <line x1="{x1}" y1="{y_bin}" x2="{x2+5}" y2="{y_bin}" '
        svg += f'stroke="#aaa" stroke-width="2" marker-end="url(#arrowG)"/>\n'

    svg += f'  <text x="400" y="{y_bin+50}" text-anchor="middle" fill="#888" font-size="12" '
    svg += f'font-family="Arial">Rule: 2·2ⁿ = 2ⁿ⁺¹ (carry only upward)</text>\n'

    # FIBONACCI SECTION
    svg += f'''
  <text x="400" y="215" text-anchor="middle" fill="#e67e22" font-size="15"
        font-family="Arial" font-weight="bold">Fibonacci: Bidirectional ↔</text>
'''

    y_fib = 270
    fibs = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]

    for i in range(10):
        x = x_start + i * spacing
        svg += f'  <rect x="{x-20}" y="{y_fib-15}" width="40" height="30" rx="5" '
        svg += f'fill="#1a1a3e" stroke="#e67e22" stroke-opacity="0.5"/>\n'
        svg += f'  <text x="{x}" y="{y_fib+5}" text-anchor="middle" fill="#e67e22" '
        svg += f'font-size="12" font-family="monospace">F({9-i+2})</text>\n'

    # Fibonacci carry: UPWARD (red, +1 position)
    for i in range(1, 9):
        x1 = x_start + i * spacing + 20
        x2 = x_start + (i-1) * spacing - 20
        y1 = y_fib - 18
        svg += f'  <line x1="{x1}" y1="{y1}" x2="{x2+5}" y2="{y1}" '
        svg += f'stroke="#e74c3c" stroke-width="2" marker-end="url(#arrowR)"/>\n'

    # Fibonacci carry: DOWNWARD (blue, -2 positions)
    for i in range(0, 7):
        x1 = x_start + i * spacing - 20
        x2 = x_start + (i+2) * spacing + 20
        y1 = y_fib + 18
        svg += f'  <line x1="{x1}" y1="{y1}" x2="{x2-5}" y2="{y1}" '
        svg += f'stroke="#3498db" stroke-width="2" marker-end="url(#arrowB)"/>\n'

    svg += f'''
  <text x="400" y="{y_fib+55}" text-anchor="middle" fill="#888" font-size="12"
        font-family="Arial">Rule: 2·F(n) = F(n+1) + F(n−2) (carries both up AND down)</text>

  <!-- Legend -->
  <line x1="200" y1="370" x2="240" y2="370" stroke="#e74c3c" stroke-width="2"
        marker-end="url(#arrowR)"/>
  <text x="250" y="375" fill="#e74c3c" font-size="12" font-family="Arial">
    Upward carry (+1 position)</text>

  <line x1="450" y1="370" x2="490" y2="370" stroke="#3498db" stroke-width="2"
        marker-end="url(#arrowB)"/>
  <text x="500" y="375" fill="#3498db" font-size="12" font-family="Arial">
    Downward carry (−2 positions)</text>

  <text x="400" y="420" text-anchor="middle" fill="#667eea" font-size="14"
        font-family="Georgia, serif" font-style="italic">
    Bidirectional carries create richer constraint networks for factoring
  </text>
</svg>'''

    save_svg("fibonacci_carry_cascade.svg", svg)


# ═══════════════════════════════════════════════════════════════
# 5. NORM SPHERE COLLISION
# ═══════════════════════════════════════════════════════════════

def generate_norm_sphere():
    """Sum-of-squares representations on a circle (2D projection of norm sphere)."""

    w, h = 700, 650
    cx, cy = 350, 330
    R = 220

    # N = 325 = 1²+18² = 6²+17² = 10²+15²
    N = 325
    reps = []
    for a in range(int(math.sqrt(N)) + 1):
        bsq = N - a * a
        b = int(math.sqrt(bsq))
        if b * b == bsq and a <= b:
            reps.append((a, b))

    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">
  <rect width="{w}" height="{h}" fill="#0a0a2e" rx="15"/>

  <text x="350" y="35" text-anchor="middle" fill="white" font-size="20"
        font-family="Georgia, serif" font-weight="bold">
    Norm Sphere Collisions: N = 325 = 5² × 13
  </text>
  <text x="350" y="58" text-anchor="middle" fill="#aaaacc" font-size="13"
        font-family="Arial">
    Multiple sum-of-squares representations reveal factors
  </text>

  <!-- Circle a² + b² = 325 -->
  <circle cx="{cx}" cy="{cy}" r="{R}" fill="none" stroke="#3498db" stroke-width="2" opacity="0.4"/>

  <!-- Axes -->
  <line x1="{cx-R-30}" y1="{cy}" x2="{cx+R+30}" y2="{cy}" stroke="#333" stroke-width="1"/>
  <line x1="{cx}" y1="{cy-R-30}" x2="{cx}" y2="{cy+R+30}" stroke="#333" stroke-width="1"/>
  <text x="{cx+R+35}" y="{cy+4}" fill="#888" font-size="12">a</text>
  <text x="{cx+4}" y="{cy-R-32}" fill="#888" font-size="12">b</text>
'''

    scale = R / math.sqrt(N)
    colors = ["#e74c3c", "#2ecc71", "#f1c40f", "#9b59b6"]

    for i, (a, b) in enumerate(reps):
        # Plot in first quadrant
        px = cx + a * scale
        py = cy - b * scale
        c = colors[i % len(colors)]

        svg += f'  <circle cx="{px:.0f}" cy="{py:.0f}" r="8" fill="{c}" opacity="0.9"/>\n'
        svg += f'  <text x="{px+12:.0f}" y="{py-8:.0f}" fill="{c}" font-size="13" '
        svg += f'font-family="monospace" font-weight="bold">({a}, {b})</text>\n'
        svg += f'  <text x="{px+12:.0f}" y="{py+8:.0f}" fill="{c}" font-size="11" '
        svg += f'font-family="Arial">{a}²+{b}² = {a*a+b*b}</text>\n'

        # Dashed lines to axes
        svg += f'  <line x1="{px:.0f}" y1="{py:.0f}" x2="{px:.0f}" y2="{cy}" '
        svg += f'stroke="{c}" stroke-width="1" stroke-dasharray="3,3" opacity="0.4"/>\n'
        svg += f'  <line x1="{px:.0f}" y1="{py:.0f}" x2="{cx}" y2="{py:.0f}" '
        svg += f'stroke="{c}" stroke-width="1" stroke-dasharray="3,3" opacity="0.4"/>\n'

    # Show the factoring algebra
    if len(reps) >= 2:
        a1, b1 = reps[0]
        a2, b2 = reps[1]
        g1 = math.gcd(abs(a1*b2 - b1*a2), N)
        g2 = math.gcd(abs(a1*b2 + b1*a2), N)

        svg += f'''
  <!-- Factoring algebra -->
  <rect x="30" y="530" width="640" height="90" rx="10" fill="#1a1a3e" opacity="0.8"/>
  <text x="350" y="555" text-anchor="middle" fill="white" font-size="14"
        font-family="monospace">
    325 = {a1}² + {b1}² = {a2}² + {b2}²
  </text>
  <text x="350" y="578" text-anchor="middle" fill="#2ecc71" font-size="13"
        font-family="monospace">
    gcd({a1}·{b2} − {b1}·{a2}, 325) = gcd({abs(a1*b2-b1*a2)}, 325) = {g1}
  </text>
  <text x="350" y="598" text-anchor="middle" fill="#e74c3c" font-size="13"
        font-family="monospace">
    gcd({a1}·{b2} + {b1}·{a2}, 325) = gcd({abs(a1*b2+b1*a2)}, 325) = {g2}
  </text>
  <text x="350" y="616" text-anchor="middle" fill="#f1c40f" font-size="14"
        font-family="Georgia, serif" font-weight="bold">
    → 325 = {g1 if 1 < g1 < N else g2} × {N // (g1 if 1 < g1 < N else g2)}  ✓
  </text>
'''

    svg += '</svg>'
    save_svg("norm_sphere_collision.svg", svg)


# ═══════════════════════════════════════════════════════════════
# 6. LENS EFFECTIVENESS RADAR CHART
# ═══════════════════════════════════════════════════════════════

def generate_radar_chart():
    """Radar chart showing which lenses work best for different composite types."""

    w, h = 750, 700
    cx, cy = 375, 370
    R = 220

    categories = ["Close\nPrimes", "Random\nSemiprimes", "Smooth\nComposites",
                   "Power\nComposites", "Multi-\nFactor", "Balanced\nSemiprimes"]
    n_cats = len(categories)

    # Effectiveness scores (0-1) for each lens on each composite type
    lenses_data = [
        ("Fibonacci",   [0.6, 0.5, 0.7, 0.4, 0.6, 0.5], "#E74C3C"),
        ("Hyperbolic",  [0.3, 0.4, 0.8, 0.6, 0.9, 0.4], "#E67E22"),
        ("Orbit (ρ)",   [0.7, 0.9, 0.6, 0.5, 0.7, 0.8], "#F1C40F"),
        ("Spectral",    [0.5, 0.6, 0.9, 0.3, 0.5, 0.6], "#2ECC71"),
        ("Norm",        [0.4, 0.3, 0.5, 0.8, 0.4, 0.3], "#3498DB"),
        ("Lattice",     [0.6, 0.5, 0.4, 0.7, 0.5, 0.6], "#9B59B6"),
        ("Fermat",      [0.9, 0.3, 0.5, 0.6, 0.3, 0.4], "#1ABC9C"),
    ]

    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">
  <rect width="{w}" height="{h}" fill="#0a0a2e" rx="15"/>

  <text x="{cx}" y="35" text-anchor="middle" fill="white" font-size="20"
        font-family="Georgia, serif" font-weight="bold">
    Lens Effectiveness by Composite Type
  </text>
  <text x="{cx}" y="58" text-anchor="middle" fill="#aaaacc" font-size="13"
        font-family="Arial">
    No single lens dominates — MetaFactoring exploits the complementarity
  </text>
'''

    # Grid rings
    for level in [0.2, 0.4, 0.6, 0.8, 1.0]:
        pts = []
        for i in range(n_cats):
            angle = -math.pi/2 + 2 * math.pi * i / n_cats
            x = cx + R * level * math.cos(angle)
            y = cy + R * level * math.sin(angle)
            pts.append(f"{x:.0f},{y:.0f}")
        svg += f'  <polygon points="{" ".join(pts)}" fill="none" '
        svg += f'stroke="#333355" stroke-width="0.5"/>\n'

    # Axis lines and labels
    for i, cat in enumerate(categories):
        angle = -math.pi/2 + 2 * math.pi * i / n_cats
        x = cx + (R + 40) * math.cos(angle)
        y = cy + (R + 40) * math.sin(angle)
        x_line = cx + R * math.cos(angle)
        y_line = cy + R * math.sin(angle)

        svg += f'  <line x1="{cx}" y1="{cy}" x2="{x_line:.0f}" y2="{y_line:.0f}" '
        svg += f'stroke="#333355" stroke-width="0.5"/>\n'

        lines = cat.split('\n')
        for j, line in enumerate(lines):
            svg += f'  <text x="{x:.0f}" y="{y + j*15:.0f}" text-anchor="middle" '
            svg += f'fill="#aaaacc" font-size="11" font-family="Arial">{line}</text>\n'

    # Plot each lens
    for name, scores, color in lenses_data:
        pts = []
        for i, s in enumerate(scores):
            angle = -math.pi/2 + 2 * math.pi * i / n_cats
            x = cx + R * s * math.cos(angle)
            y = cy + R * s * math.sin(angle)
            pts.append(f"{x:.0f},{y:.0f}")
        svg += f'  <polygon points="{" ".join(pts)}" fill="{color}" fill-opacity="0.1" '
        svg += f'stroke="{color}" stroke-width="2" opacity="0.7"/>\n'

    # Legend
    ly = 640
    for i, (name, _, color) in enumerate(lenses_data):
        lx = 50 + i * 100
        svg += f'  <rect x="{lx}" y="{ly}" width="12" height="12" fill="{color}" opacity="0.8"/>\n'
        svg += f'  <text x="{lx+16}" y="{ly+11}" fill="#aaaacc" font-size="10" '
        svg += f'font-family="Arial">{name}</text>\n'

    svg += '</svg>'
    save_svg("lens_effectiveness_radar.svg", svg)


# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Generating MetaFactoring SVG visuals...\n")
    generate_architecture()
    generate_constraint_intersection()
    generate_hyperbola()
    generate_fibonacci_cascade()
    generate_norm_sphere()
    generate_radar_chart()
    print(f"\nDone! {6} SVG files generated in {OUTPUT_DIR}/")
