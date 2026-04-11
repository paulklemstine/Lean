#!/usr/bin/env python3
"""
Generate additional SVG visuals for the MetaFactoring New Theorem Candidates.

Produces:
1. dimension_barrier.svg — The Hurwitz dimension hierarchy
2. pisano_spiral.svg — Pisano period structure
3. bridge_network.svg — Inter-lens bridge theorem connections
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


def generate_dimension_barrier():
    """Visualization of the Hurwitz dimension barrier."""
    w, h = 800, 500

    dims = [
        (1, "ℝ", "Reals", "#666", "trivial"),
        (2, "ℂ", "Complex", "#E74C3C", "Brahmagupta-\nFibonacci"),
        (4, "ℍ", "Quaternions", "#3498DB", "Euler\n4-square"),
        (8, "𝕆", "Octonions", "#2ECC71", "Degen\n8-square"),
    ]

    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">
  <defs>
    <linearGradient id="barrier" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#E74C3C" stop-opacity="0.3"/>
      <stop offset="100%" stop-color="#E74C3C" stop-opacity="0"/>
    </linearGradient>
  </defs>

  <rect width="{w}" height="{h}" fill="#0a0a2e" rx="15"/>

  <text x="400" y="40" text-anchor="middle" fill="white" font-size="22"
        font-family="Georgia, serif" font-weight="bold">
    Division Algebra Dimension Barrier (Hurwitz 1898)
  </text>
  <text x="400" y="65" text-anchor="middle" fill="#aaaacc" font-size="13"
        font-family="Arial">
    Norm-multiplicative composition identities exist ONLY in dimensions 1, 2, 4, 8
  </text>
'''

    # Draw the 4 allowed dimensions as growing circles
    y_base = 300
    spacing = 160
    x_start = 100

    for i, (dim, symbol, name, color, identity) in enumerate(dims):
        x = x_start + i * spacing
        r = 15 + dim * 5  # radius proportional to dimension

        # Circle
        svg += f'  <circle cx="{x}" cy="{y_base}" r="{r}" fill="{color}" opacity="0.7"/>\n'

        # Symbol
        svg += f'  <text x="{x}" y="{y_base+6}" text-anchor="middle" fill="white" '
        svg += f'font-size="{16 + dim}" font-family="Georgia, serif" font-weight="bold">{symbol}</text>\n'

        # Dimension label
        svg += f'  <text x="{x}" y="{y_base - r - 15}" text-anchor="middle" fill="{color}" '
        svg += f'font-size="16" font-family="Arial" font-weight="bold">dim {dim}</text>\n'

        # Name
        svg += f'  <text x="{x}" y="{y_base + r + 25}" text-anchor="middle" fill="#aaa" '
        svg += f'font-size="12" font-family="Arial">{name}</text>\n'

        # Identity
        lines = identity.split('\n')
        for j, line in enumerate(lines):
            svg += f'  <text x="{x}" y="{y_base + r + 42 + j*15}" text-anchor="middle" '
            svg += f'fill="#888" font-size="11" font-family="Arial">{line}</text>\n'

        # Connecting line
        if i < len(dims) - 1:
            x2 = x_start + (i + 1) * spacing
            svg += f'  <line x1="{x + r + 5}" y1="{y_base}" x2="{x2 - 15 - dims[i+1][0]*5 - 5}" '
            svg += f'y2="{y_base}" stroke="#555" stroke-width="2" stroke-dasharray="6,3"/>\n'

    # The barrier after dimension 8
    barrier_x = x_start + 3 * spacing + 70
    svg += f'''
  <!-- The barrier -->
  <rect x="{barrier_x}" y="100" width="4" height="300" fill="#E74C3C" opacity="0.8"/>
  <rect x="{barrier_x + 10}" y="100" width="120" height="300" fill="url(#barrier)"/>

  <text x="{barrier_x + 65}" y="150" text-anchor="middle" fill="#E74C3C"
        font-size="18" font-family="Georgia, serif" font-weight="bold">BARRIER</text>
  <text x="{barrier_x + 65}" y="175" text-anchor="middle" fill="#E74C3C"
        font-size="12" font-family="Arial">No dim 16</text>
  <text x="{barrier_x + 65}" y="195" text-anchor="middle" fill="#E74C3C"
        font-size="12" font-family="Arial">identity exists</text>

  <text x="{barrier_x + 65}" y="{y_base}" text-anchor="middle" fill="#E74C3C"
        font-size="40" font-family="Georgia, serif" opacity="0.5">✕</text>
  <text x="{barrier_x + 65}" y="{y_base + 50}" text-anchor="middle" fill="#E74C3C"
        font-size="14" font-family="Arial">dim 16</text>

  <!-- Bottom annotation -->
  <text x="400" y="{h - 30}" text-anchor="middle" fill="#667eea" font-size="13"
        font-family="Georgia, serif" font-style="italic">
    The 8-dimensional octonion norm channel is the richest possible factoring channel
  </text>
</svg>'''

    save_svg("dimension_barrier.svg", svg)


def generate_pisano_spiral():
    """Visualization of Pisano period structure for small primes."""
    w, h = 700, 700
    cx, cy = 350, 370

    def pisano_period(m):
        if m <= 1: return 1
        a, b = 0, 1
        for i in range(1, 6 * m + 1):
            a, b = b, (a + b) % m
            if a == 0 and b == 1: return i
        return None

    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">
  <rect width="{w}" height="{h}" fill="#0a0a2e" rx="15"/>

  <text x="350" y="35" text-anchor="middle" fill="white" font-size="20"
        font-family="Georgia, serif" font-weight="bold">
    Pisano Period Structure: π(m) for primes m
  </text>
  <text x="350" y="58" text-anchor="middle" fill="#aaaacc" font-size="13"
        font-family="Arial">
    The Fibonacci sequence mod m repeats with period π(m)
  </text>
'''

    # Draw Fibonacci sequence mod p as a spiral for several primes
    primes = [2, 3, 5, 7, 11, 13]
    colors = ["#E74C3C", "#E67E22", "#F1C40F", "#2ECC71", "#3498DB", "#9B59B6"]

    R_base = 60
    R_step = 40

    for idx, (p, color) in enumerate(zip(primes, colors)):
        R = R_base + idx * R_step
        pi = pisano_period(p)

        # Draw the Fibonacci sequence mod p as points on a circle
        a, b = 0, 1
        for i in range(pi):
            angle = 2 * math.pi * i / pi - math.pi / 2
            x = cx + R * math.cos(angle)
            y = cy + R * math.sin(angle)
            r = 2 + a * 2  # radius proportional to value

            svg += f'  <circle cx="{x:.1f}" cy="{y:.1f}" r="{min(r, 8)}" '
            svg += f'fill="{color}" opacity="0.7"/>\n'
            a, b = b, (a + b) % p

        # Label
        label_angle = -math.pi / 2 - 0.3
        lx = cx + (R + 15) * math.cos(label_angle)
        ly = cy + (R + 15) * math.sin(label_angle)
        svg += f'  <text x="{lx:.0f}" y="{ly:.0f}" fill="{color}" font-size="12" '
        svg += f'font-family="monospace">p={p}, π={pi}</text>\n'

    # Legend
    svg += f'''
  <rect x="20" y="620" width="660" height="55" rx="8" fill="#1a1a3e" opacity="0.7"/>
  <text x="350" y="645" text-anchor="middle" fill="white" font-size="13" font-family="Arial">
    Pisano periods: π(2)=3, π(3)=8, π(5)=20, π(7)=16, π(11)=10, π(13)=7
  </text>
  <text x="350" y="665" text-anchor="middle" fill="#aaaacc" font-size="11" font-family="Arial">
    For prime p: π(p) divides p² − 1 = (p−1)(p+1) — connecting Fibonacci to spectral structure
  </text>
</svg>'''

    save_svg("pisano_spiral.svg", svg)


def generate_bridge_network():
    """Network diagram showing bridge theorems between lenses."""
    w, h = 850, 650

    lenses = [
        (130, 150, "Fibonacci\nZeckendorf", "#E74C3C", "1"),
        (400, 90,  "Hyperbolic\nGeometry", "#E67E22", "2"),
        (670, 150, "Orbit\nDynamics", "#F1C40F", "3"),
        (750, 380, "Spectral\nHarmonic", "#2ECC71", "4"),
        (620, 540, "Division\nAlgebra", "#3498DB", "5"),
        (280, 540, "Lattice\nReduction", "#9B59B6", "6"),
        (100, 380, "Congruence\nof Squares", "#1ABC9C", "7"),
    ]

    bridges = [
        (0, 1, "Thm 4.3\nHyp-Fib Bridge", "#ff9999"),
        (2, 3, "Thm 4.4\nOrbit-Spectral", "#99ff99"),
        (4, 6, "Thm 4.5\nNorm-CoS Bridge", "#9999ff"),
        (1, 5, "Conj 3\nHyp-Lattice", "#ffcc99"),
        (0, 3, "Conj 2\nFib-Spectral", "#ff99cc"),
        (2, 4, "Conj 4\nOrbit-Norm", "#99ccff"),
        (5, 6, "Classical\nLLL → CoS", "#cccccc"),
    ]

    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">
  <defs>
    <filter id="glow2">
      <feGaussianBlur stdDeviation="3" result="blur"/>
      <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>

  <rect width="{w}" height="{h}" fill="#0a0a2e" rx="15"/>

  <text x="425" y="35" text-anchor="middle" fill="white" font-size="22"
        font-family="Georgia, serif" font-weight="bold">
    Bridge Theorem Network
  </text>
  <text x="425" y="58" text-anchor="middle" fill="#aaaacc" font-size="13"
        font-family="Arial">
    Theorems and conjectures connecting the seven lenses
  </text>
'''

    # Draw bridges (lines between lenses)
    for i, j, label, color in bridges:
        x1, y1 = lenses[i][0], lenses[i][1]
        x2, y2 = lenses[j][0], lenses[j][1]
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2

        # Is it a conjecture or a theorem?
        is_conj = "Conj" in label
        dash = 'stroke-dasharray="8,4"' if is_conj else ''

        svg += f'  <line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
        svg += f'stroke="{color}" stroke-width="2" opacity="0.6" {dash}/>\n'

        # Label at midpoint
        lines = label.split('\n')
        for k, line in enumerate(lines):
            svg += f'  <text x="{mx:.0f}" y="{my - 8 + k*14:.0f}" text-anchor="middle" '
            svg += f'fill="{color}" font-size="10" font-family="Arial">{line}</text>\n'

    # Draw lens nodes
    r = 35
    for x, y, name, color, num in lenses:
        svg += f'  <circle cx="{x}" cy="{y}" r="{r}" fill="{color}" opacity="0.8" '
        svg += f'filter="url(#glow2)"/>\n'

        lines = name.split('\n')
        for k, line in enumerate(lines):
            svg += f'  <text x="{x}" y="{y - 5 + k*14}" text-anchor="middle" fill="white" '
            svg += f'font-size="11" font-family="Arial" font-weight="bold">{line}</text>\n'

        svg += f'  <text x="{x}" y="{y + 25}" text-anchor="middle" fill="white" '
        svg += f'font-size="14" font-family="Georgia" opacity="0.7">L{num}</text>\n'

    # Legend
    svg += f'''
  <rect x="30" y="595" width="200" height="40" rx="5" fill="#1a1a3e" opacity="0.7"/>
  <line x1="45" y1="610" x2="85" y2="610" stroke="#99ff99" stroke-width="2"/>
  <text x="92" y="614" fill="#aaa" font-size="11" font-family="Arial">= Proved theorem</text>

  <line x1="45" y1="625" x2="85" y2="625" stroke="#ffcc99" stroke-width="2" stroke-dasharray="8,4"/>
  <text x="92" y="629" fill="#aaa" font-size="11" font-family="Arial">= Open conjecture</text>
</svg>'''

    save_svg("bridge_network.svg", svg)


if __name__ == "__main__":
    print("Generating new MetaFactoring SVG visuals...\n")
    generate_dimension_barrier()
    generate_pisano_spiral()
    generate_bridge_network()
    print(f"\nDone! 3 new SVG files generated in {OUTPUT_DIR}/")
