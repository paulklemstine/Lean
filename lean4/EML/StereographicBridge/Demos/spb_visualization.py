#!/usr/bin/env python3
"""
SPB Visualization Generator

Generates visualizations of SPB orbits, the Cayley circle, 
stereographic projection geometry, and the EML-SPB bridge.

Usage:
    python3 spb_visualization.py
"""

import math
import cmath

def cayley(x: float) -> complex:
    return (x - 1j) / (x + 1j)

def spb(x: float, y: float):
    denom = 1 - x * y
    if abs(denom) < 1e-15:
        return None
    return (x + y) / denom

# ═══════════════════════════════════════════════════════════════
# ASCII VISUALIZATIONS
# ═══════════════════════════════════════════════════════════════

def visualize_stereographic_projection():
    """ASCII visualization of stereographic projection from S¹ to ℝ."""
    print("\n" + "="*70)
    print("STEREOGRAPHIC PROJECTION: S¹ → ℝ")
    print("="*70)
    
    width, height = 60, 30
    canvas = [[' ' for _ in range(width)] for _ in range(height)]
    
    cx, cy = width // 2, height // 2 - 3
    r = 10
    
    # Draw circle
    for step in range(300):
        theta = 2 * math.pi * step / 300
        px = int(cx + r * math.cos(theta) + 0.5)
        py = int(cy - r * math.sin(theta) + 0.5)
        if 0 <= px < width and 0 <= py < height:
            canvas[py][px] = '·'
    
    # Mark north pole (projection point)
    if 0 <= cy - r < height:
        canvas[cy - r][cx] = 'N'
    
    # Draw real line at bottom
    line_y = cy + r + 3
    if line_y < height:
        for x in range(5, width - 5):
            canvas[line_y][x] = '─'
    
    # Draw some projection lines from N through circle to line
    for theta_deg in [-120, -60, -30, 30, 60, 120]:
        theta = math.radians(theta_deg + 90)  # Offset so 0° is at top
        # Point on circle
        px_c = cx + r * math.cos(theta)
        py_c = cy - r * math.sin(theta)
        
        # Corresponding point on line via stereographic projection
        # For S¹: stereographic from N=(0,1) maps (cos θ, sin θ) → cos θ/(1-sin θ)
        if abs(1 - math.sin(theta)) > 0.1:
            line_x = math.cos(theta) / (1 - math.sin(theta))
            lpx = int(cx + r * line_x + 0.5)
            
            # Mark circle point
            ipx, ipy = int(px_c + 0.5), int(py_c + 0.5)
            if 0 <= ipx < width and 0 <= ipy < height:
                canvas[ipy][ipx] = '●'
            
            # Mark line point
            if line_y < height and 0 <= lpx < width:
                canvas[line_y][lpx] = '▼'
    
    # Labels
    if line_y + 1 < height:
        label = "ℝ (real line)"
        start = cx - len(label) // 2
        for i, ch in enumerate(label):
            if 0 <= start + i < width:
                canvas[line_y + 1][start + i] = ch
    
    print()
    for row in canvas:
        print('  ' + ''.join(row))

def visualize_cayley_circle():
    """Show how the Cayley transform maps real points onto the unit circle."""
    print("\n" + "="*70)
    print("CAYLEY TRANSFORM: ℝ → S¹")
    print("C(x) = (x-i)/(x+i)")
    print("="*70)
    
    size = 31
    canvas = [[' ' for _ in range(size)] for _ in range(size)]
    center = size // 2
    radius = center - 2
    
    # Draw unit circle
    for step in range(400):
        theta = 2 * math.pi * step / 400
        px = int(center + radius * math.cos(theta) + 0.5)
        py = int(center - radius * math.sin(theta) + 0.5)
        if 0 <= px < size and 0 <= py < size:
            canvas[py][px] = '·'
    
    # Map specific real points to the circle
    points = [
        (0, "0", 'A'),
        (1, "1", 'B'),
        (-1, "-1", 'C'),
        (2, "2", 'D'),
        (-2, "-2", 'E'),
        (0.5, "½", 'F'),
    ]
    
    legend = []
    for x, label, marker in points:
        c = cayley(x)
        px = int(center + radius * c.real + 0.5)
        py = int(center - radius * c.imag + 0.5)
        if 0 <= px < size and 0 <= py < size:
            canvas[py][px] = marker
        legend.append(f"  {marker}: C({label:>4}) = {c.real:>7.4f} + {c.imag:>7.4f}i  (|C| = {abs(c):.4f})")
    
    # Mark special points
    # C(0) = -1 (leftmost)
    # C(∞) = 1 (rightmost, not plotted)
    # C(1) = -i (bottom)
    # C(-1) = i (top)
    
    # Draw axes
    for x in range(2, size - 2):
        if canvas[center][x] == ' ':
            canvas[center][x] = '─'
    for y in range(2, size - 2):
        if canvas[y][center] == ' ':
            canvas[y][center] = '│'
    canvas[center][center] = '┼'
    
    print()
    for row in canvas:
        print('  ' + ''.join(row))
    
    print(f"\n  Legend:")
    for l in legend:
        print(l)
    print(f"  ∞: C(∞) → 1 + 0i (rightmost point)")

def visualize_spb_orbit():
    """Show an SPB orbit on the Cayley circle."""
    print("\n" + "="*70)
    print("SPB ORBIT ON THE CAYLEY CIRCLE")
    print("a = tan(π/5), orbit has period 5")
    print("="*70)
    
    size = 31
    canvas = [[' ' for _ in range(size)] for _ in range(size)]
    center = size // 2
    radius = center - 2
    
    # Draw unit circle
    for step in range(400):
        theta = 2 * math.pi * step / 400
        px = int(center + radius * math.cos(theta) + 0.5)
        py = int(center - radius * math.sin(theta) + 0.5)
        if 0 <= px < size and 0 <= py < size:
            canvas[py][px] = '·'
    
    # Period-5 orbit
    a = math.tan(math.pi / 5)
    x = 0.0
    orbit_points = []
    
    markers = '①②③④⑤⑥⑦⑧'
    
    for n in range(5):
        c = cayley(x)
        orbit_points.append((x, c))
        px = int(center + radius * c.real + 0.5)
        py = int(center - radius * c.imag + 0.5)
        if 0 <= px < size and 0 <= py < size:
            canvas[py][px] = str(n + 1)
        
        result = spb(x, a)
        if result is None:
            break
        x = result
    
    # Draw axes
    for ax in range(2, size - 2):
        if canvas[center][ax] == ' ':
            canvas[center][ax] = '─'
    for ay in range(2, size - 2):
        if canvas[ay][center] == ' ':
            canvas[ay][center] = '│'
    canvas[center][center] = '┼'
    
    print()
    for row in canvas:
        print('  ' + ''.join(row))
    
    print(f"\n  Orbit points on ℝ:")
    for n, (x, c) in enumerate(orbit_points):
        print(f"    {n+1}: x = {x:>10.6f}, C(x) = {c.real:>8.4f} + {c.imag:>8.4f}i")
    
    print(f"\n  Rotation angle = 2·arctan(a) = 2π/5 (regular pentagon!)")

# ═══════════════════════════════════════════════════════════════
# SPB EXPRESSION TREE VISUALIZER
# ═══════════════════════════════════════════════════════════════

def draw_spb_tree_tan2theta():
    """Draw the SPB tree for tan(2θ) = spb(tan θ, tan θ)."""
    print("\n" + "="*60)
    print("SPB TREE: tan(2θ) = spb(tan θ, tan θ)")
    print("="*60)
    
    tree = """
              spb
             /   \\
          tan θ  tan θ
    
    Depth: 1
    Result: 2·tan(θ) / (1 - tan²(θ))
    """
    print(tree)

def draw_spb_tree_tan3theta():
    """Draw the SPB tree for tan(3θ)."""
    print("\n" + "="*60)
    print("SPB TREE: tan(3θ) = spb(tan θ, spb(tan θ, tan θ))")
    print("="*60)
    
    tree = """
              spb
             /   \\
          tan θ  spb
                /   \\
             tan θ  tan θ
    
    Depth: 2
    Result: (3·tan(θ) - tan³(θ)) / (1 - 3·tan²(θ))
    = Chebyshev polynomial of the 3rd kind!
    """
    print(tree)

def draw_cayley_bridge():
    """Draw the EML ↔ SPB bridge diagram."""
    print("\n" + "="*70)
    print("THE EML-SPB BRIDGE")
    print("="*70)
    
    diagram = """
    ┌─────────────────────┐         ┌─────────────────────┐
    │   ADDITIVE WORLD    │         │  MULTIPLICATIVE WORLD │
    │                     │         │                       │
    │   (ℝ, +)           │  exp    │   (ℝ₊, ×)            │
    │   Addition          │ ──────> │   Multiplication      │
    │                     │ <────── │                       │
    │                     │  log    │                       │
    └──────────┬──────────┘         └──────────┬────────────┘
               │                               │
               │  EML = exp(x) - ln(y)         │
               │  "Bridges add ↔ mult"          │
               │                               │
    ╔══════════╧═══════════════════════════════╧════════════╗
    ║              THE UNIVERSAL BRIDGE                      ║
    ╚══════════╤═══════════════════════════════╤════════════╝
               │                               │
               │  SPB = (x+y)/(1-xy)           │
               │  "Bridges line ↔ circle"       │
               │                               │
    ┌──────────┴──────────┐         ┌──────────┴────────────┐
    │  EUCLIDEAN WORLD    │         │  SPHERICAL WORLD       │
    │                     │ Cayley  │                       │
    │   (ℝ, spb)         │ ──────> │   (S¹, ×)             │
    │   Tangent addition  │ <────── │   Circle multiplication │
    │                     │ Cayley⁻¹│                       │
    └─────────────────────┘         └───────────────────────┘
    
    Key Insight: EML bridges ARITHMETIC, SPB bridges GEOMETRY.
    Together they cover the full landscape of elementary mathematics.
    
    ┌─────────────────────┐  Wick   ┌─────────────────────┐
    │  CIRCULAR (1-xy)    │ ←────→  │  HYPERBOLIC (1+xy)  │
    │  Tangent addition   │  t→it   │  Velocity addition  │
    │  Compact orbits     │         │  Open orbits         │
    │  Chebyshev T_n      │         │  Rapidity addition   │
    └─────────────────────┘         └─────────────────────┘
    """
    print(diagram)

# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   SPB VISUALIZATION GENERATOR                           ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    visualize_stereographic_projection()
    visualize_cayley_circle()
    visualize_spb_orbit()
    draw_spb_tree_tan2theta()
    draw_spb_tree_tan3theta()
    draw_cayley_bridge()
    
    print("\nAll visualizations generated!")
