#!/usr/bin/env python3
"""
Generate SVG visualizations for the Quadruple Lattice research.

Creates:
1. 2D lattice with quadratic residue structure
2. 3D lattice projection showing sum-of-squares level sets
3. Berggren tree vs quadruple forest comparison
4. Minkowski bound comparison diagram
"""

import math


def svg_header(width: int, height: int, title: str = "") -> str:
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}">
<style>
  text {{ font-family: 'Georgia', 'Times New Roman', serif; }}
  .title {{ font-size: 18px; font-weight: bold; fill: #1a1a2e; }}
  .subtitle {{ font-size: 13px; fill: #4a4a6a; }}
  .label {{ font-size: 11px; fill: #333; }}
  .small {{ font-size: 9px; fill: #666; }}
  .math {{ font-family: 'Times New Roman', serif; font-style: italic; }}
</style>
<defs>
  <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
    <polygon points="0 0, 10 3.5, 0 7" fill="#333"/>
  </marker>
</defs>
<rect width="{width}" height="{height}" fill="#fafaf8"/>
'''


def svg_footer() -> str:
    return '</svg>\n'


# ============================================================================
# Visualization 1: The 2D Quadratic Residue Lattice
# ============================================================================

def create_2d_lattice_svg(N: int = 5, r: int = 2) -> str:
    """Visualize the 2D lattice L = {(x,y) : N | (x - r·y)}."""
    w, h = 700, 600
    svg = svg_header(w, h, "2D Quadratic Residue Lattice")

    # Title
    svg += f'<text x="350" y="35" text-anchor="middle" class="title">The Quadratic Residue Lattice (N = {N}, r = {r})</text>\n'
    svg += f'<text x="350" y="55" text-anchor="middle" class="subtitle">L = {{(x, y) ∈ ℤ² : {N} | (x − {r}y)}}   •   Short vectors ⇒ x² + y² ≡ 0 (mod {N})</text>\n'

    # Coordinate system
    cx, cy = 350, 330
    scale = 30

    # Grid range
    grid_range = 8

    # Draw grid lines (light)
    for i in range(-grid_range, grid_range + 1):
        x = cx + i * scale
        svg += f'<line x1="{x}" y1="{cy - grid_range * scale}" x2="{x}" y2="{cy + grid_range * scale}" stroke="#e8e8e8" stroke-width="0.5"/>\n'
        y = cy - i * scale
        svg += f'<line x1="{cx - grid_range * scale}" y1="{y}" x2="{cx + grid_range * scale}" y1="{y}" y2="{y}" stroke="#e8e8e8" stroke-width="0.5"/>\n'

    # Draw axes
    svg += f'<line x1="{cx - grid_range * scale - 10}" y1="{cy}" x2="{cx + grid_range * scale + 10}" y2="{cy}" stroke="#333" stroke-width="1.5" marker-end="url(#arrowhead)"/>\n'
    svg += f'<line x1="{cx}" y1="{cy + grid_range * scale + 10}" x2="{cx}" y2="{cy - grid_range * scale - 10}" stroke="#333" stroke-width="1.5" marker-end="url(#arrowhead)"/>\n'
    svg += f'<text x="{cx + grid_range * scale + 20}" y="{cy + 4}" class="label math">x</text>\n'
    svg += f'<text x="{cx + 8}" y="{cy - grid_range * scale - 15}" class="label math">y</text>\n'

    # Draw lattice points
    for x in range(-grid_range, grid_range + 1):
        for y in range(-grid_range, grid_range + 1):
            px = cx + x * scale
            py = cy - y * scale
            if (x - r * y) % N == 0:
                # Lattice point
                s = x * x + y * y
                if s > 0 and s % N == 0:
                    # Divisibility satisfied — highlight
                    svg += f'<circle cx="{px}" cy="{py}" r="5" fill="#e74c3c" stroke="#c0392b" stroke-width="1"/>\n'
                elif x == 0 and y == 0:
                    svg += f'<circle cx="{px}" cy="{py}" r="5" fill="#2ecc71" stroke="#27ae60" stroke-width="1.5"/>\n'
                else:
                    svg += f'<circle cx="{px}" cy="{py}" r="4" fill="#3498db" stroke="#2980b9" stroke-width="1"/>\n'
            else:
                # Not a lattice point — small gray dot
                svg += f'<circle cx="{px}" cy="{py}" r="1.5" fill="#ddd"/>\n'

    # Draw basis vectors
    b1 = (N, 0)
    b2 = (r, 1)
    svg += f'<line x1="{cx}" y1="{cy}" x2="{cx + b1[0] * scale}" y2="{cy - b1[1] * scale}" stroke="#e74c3c" stroke-width="2.5" marker-end="url(#arrowhead)"/>\n'
    svg += f'<text x="{cx + b1[0] * scale // 2}" y="{cy + 20}" class="label" fill="#e74c3c">b₁ = ({N}, 0)</text>\n'

    svg += f'<line x1="{cx}" y1="{cy}" x2="{cx + b2[0] * scale}" y2="{cy - b2[1] * scale}" stroke="#2ecc71" stroke-width="2.5" marker-end="url(#arrowhead)"/>\n'
    svg += f'<text x="{cx + b2[0] * scale + 10}" y="{cy - b2[1] * scale}" class="label" fill="#2ecc71">b₂ = ({r}, 1)</text>\n'

    # Legend
    svg += '<rect x="20" y="475" width="660" height="110" fill="#f5f5f0" stroke="#ccc" rx="5"/>\n'
    svg += '<text x="350" y="500" text-anchor="middle" class="label" font-weight="bold">Legend</text>\n'
    svg += '<circle cx="60" cy="520" r="4" fill="#3498db" stroke="#2980b9"/>\n'
    svg += '<text x="75" y="524" class="small">Lattice point (x − ry ≡ 0 mod N)</text>\n'
    svg += '<circle cx="60" cy="545" r="5" fill="#e74c3c" stroke="#c0392b"/>\n'
    svg += f'<text x="75" y="549" class="small">N | (x² + y²) — factoring-relevant</text>\n'
    svg += '<circle cx="350" cy="520" r="1.5" fill="#ddd"/>\n'
    svg += '<text x="360" y="524" class="small">Non-lattice integer point</text>\n'
    svg += f'<text x="350" y="570" text-anchor="middle" class="small">r² + 1 = {r**2 + 1} = {(r**2+1)//N} × {N}  ⇒  r² ≡ −1 (mod {N})</text>\n'

    svg += svg_footer()
    return svg


# ============================================================================
# Visualization 2: Berggren Tree vs Quadruple Forest
# ============================================================================

def create_tree_forest_svg() -> str:
    """Compare the binary/ternary tree of triples vs the forest of quadruples."""
    w, h = 800, 550
    svg = svg_header(w, h)

    svg += '<text x="400" y="35" text-anchor="middle" class="title">Pythagorean Triples: Tree  vs  Quadruples: Forest</text>\n'

    # LEFT: Berggren Tree
    svg += '<rect x="20" y="55" width="370" height="470" fill="#f0f4ff" stroke="#8899cc" rx="8"/>\n'
    svg += '<text x="205" y="80" text-anchor="middle" class="subtitle">Berggren Tree (2+1 dimensions)</text>\n'
    svg += '<text x="205" y="98" text-anchor="middle" class="small">Every primitive triple has exactly 3 children</text>\n'

    # Draw the tree
    def draw_node(x, y, label, color="#3498db"):
        svg_parts = []
        svg_parts.append(f'<circle cx="{x}" cy="{y}" r="18" fill="{color}" stroke="#2c3e50" stroke-width="1.5"/>\n')
        svg_parts.append(f'<text x="{x}" y="{y + 4}" text-anchor="middle" class="small" fill="white" font-weight="bold">{label}</text>\n')
        return ''.join(svg_parts)

    def draw_edge(x1, y1, x2, y2):
        return f'<line x1="{x1}" y1="{y1 + 18}" x2="{x2}" y2="{y2 - 18}" stroke="#2c3e50" stroke-width="1.5"/>\n'

    # Root
    svg += draw_node(205, 135, "3,4,5", "#e74c3c")

    # Level 1
    l1_nodes = [(85, 210, "5,12,13"), (205, 210, "21,20,29"), (325, 210, "15,8,17")]
    for x, y, label in l1_nodes:
        svg += draw_edge(205, 135, x, y)
        svg += draw_node(x, y, label)

    # Level 2 (partial)
    l2_data = [
        (85, [(45, 290), (85, 290), (125, 290)]),
        (205, [(165, 290), (205, 290), (245, 290)]),
        (325, [(285, 290), (325, 290), (365, 290)]),
    ]
    for parent_x, children in l2_data:
        for cx_c, cy_c in children:
            svg += draw_edge(parent_x, 210, cx_c, cy_c)
            svg += f'<circle cx="{cx_c}" cy="{cy_c}" r="6" fill="#3498db" stroke="#2c3e50"/>\n'

    # Level 3 dots
    for parent_x, children in l2_data:
        for cx_c, cy_c in children:
            for dx in [-12, 0, 12]:
                svg += f'<circle cx="{cx_c + dx}" cy="{cy_c + 40}" r="2" fill="#aaa"/>\n'

    svg += '<text x="205" y="370" text-anchor="middle" class="label" fill="#2c3e50">Branching number = 3</text>\n'
    svg += '<text x="205" y="390" text-anchor="middle" class="small" fill="#666">≅ Gauss reduction in 2D</text>\n'
    svg += '<text x="205" y="410" text-anchor="middle" class="small" fill="#666">Moduli space ≅ ℙ¹ (1-dimensional)</text>\n'
    svg += '<text x="205" y="440" text-anchor="middle" class="label" fill="#c0392b">Factoring speed: Θ(√N)</text>\n'

    # RIGHT: Quadruple Forest
    svg += '<rect x="410" y="55" width="370" height="470" fill="#fff0f0" stroke="#cc8888" rx="8"/>\n'
    svg += '<text x="595" y="80" text-anchor="middle" class="subtitle">Quadruple Forest (3+1 dimensions)</text>\n'
    svg += '<text x="595" y="98" text-anchor="middle" class="small">No finite tree — infinitely many independent families</text>\n'

    # Draw multiple small trees (forest)
    tree_roots = [
        (460, 135, "1,2,2,3"),
        (540, 135, "2,3,6,7"),
        (620, 135, "1,4,8,9"),
        (700, 135, "4,6,12,14"),
    ]

    colors = ["#e74c3c", "#e67e22", "#9b59b6", "#1abc9c"]

    for i, (tx, ty, label) in enumerate(tree_roots):
        c = colors[i]
        svg += f'<circle cx="{tx}" cy="{ty}" r="15" fill="{c}" stroke="#2c3e50" stroke-width="1.5"/>\n'
        svg += f'<text x="{tx}" y="{ty + 3}" text-anchor="middle" class="small" fill="white" font-size="7">{label}</text>\n'

        # Each root has many children
        n_children = 5 + i
        for j in range(min(n_children, 6)):
            angle = -60 + j * (120 / max(n_children - 1, 1))
            rad = math.radians(angle)
            child_x = tx + 35 * math.sin(rad)
            child_y = ty + 45 * math.cos(rad)
            svg += f'<line x1="{tx}" y1="{ty + 15}" x2="{child_x}" y2="{child_y - 5}" stroke="{c}" stroke-width="1" opacity="0.6"/>\n'
            svg += f'<circle cx="{child_x}" cy="{child_y}" r="4" fill="{c}" opacity="0.7"/>\n'

            # Grandchildren (dots)
            for k in range(3):
                gangle = -30 + k * 30
                grad = math.radians(gangle)
                gx = child_x + 15 * math.sin(grad)
                gy = child_y + 20 * math.cos(grad)
                svg += f'<circle cx="{gx}" cy="{gy}" r="2" fill="{c}" opacity="0.4"/>\n'

    # Ellipsis
    svg += '<text x="595" y="300" text-anchor="middle" class="label" fill="#666">⋮ ∞ independent trees ⋮</text>\n'

    # More scattered trees at bottom
    for i in range(8):
        x = 430 + i * 40
        y = 330 + (i % 3) * 15
        svg += f'<circle cx="{x}" cy="{y}" r="8" fill="#95a5a6" opacity="0.4"/>\n'
        for j in range(3):
            svg += f'<circle cx="{x + (j-1)*10}" cy="{y + 20}" r="3" fill="#95a5a6" opacity="0.3"/>\n'

    svg += '<text x="595" y="400" text-anchor="middle" class="label" fill="#2c3e50">Branching number = ∞</text>\n'
    svg += '<text x="595" y="420" text-anchor="middle" class="small" fill="#666">Moduli space ≅ ℙ³ (2-dimensional)</text>\n'
    svg += '<text x="595" y="440" text-anchor="middle" class="small" fill="#666">SO(3,1;ℤ) symmetry group</text>\n'
    svg += '<text x="595" y="470" text-anchor="middle" class="label" fill="#27ae60">Factoring speed: sub-√N (?)</text>\n'

    svg += svg_footer()
    return svg


# ============================================================================
# Visualization 3: Minkowski Bound Comparison
# ============================================================================

def create_bound_comparison_svg() -> str:
    """Visualize the comparison between √N, N^{2/3}, and Minkowski bounds."""
    w, h = 750, 500
    svg = svg_header(w, h)

    svg += '<text x="375" y="35" text-anchor="middle" class="title">Factoring Bounds: √N vs Lattice Methods</text>\n'
    svg += '<text x="375" y="55" text-anchor="middle" class="subtitle">Shortest vector norm needed for factoring vs. guaranteed bounds</text>\n'

    # Plot area
    px, py = 100, 80
    pw, ph = 580, 340

    svg += f'<rect x="{px}" y="{py}" width="{pw}" height="{ph}" fill="#fefefe" stroke="#ccc"/>\n'

    # Axes
    svg += f'<line x1="{px}" y1="{py + ph}" x2="{px + pw}" y2="{py + ph}" stroke="#333" stroke-width="1.5" marker-end="url(#arrowhead)"/>\n'
    svg += f'<line x1="{px}" y1="{py + ph}" x2="{px}" y2="{py}" stroke="#333" stroke-width="1.5" marker-end="url(#arrowhead)"/>\n'
    svg += f'<text x="{px + pw // 2}" y="{py + ph + 40}" text-anchor="middle" class="label">log N</text>\n'
    svg += f'<text x="{px - 40}" y="{py + ph // 2}" text-anchor="middle" class="label" transform="rotate(-90, {px - 40}, {py + ph // 2})">log(bound)</text>\n'

    # Plot curves
    # N from 10 to 10^8, log scale
    n_points = 100
    def log_N(i):
        return 1 + 7 * i / n_points  # log₁₀(N) from 1 to 8

    def to_px(logN):
        return px + (logN - 1) * pw / 7

    def to_py(logBound):
        return py + ph - (logBound) * ph / 4.5  # logBound from 0 to 4.5

    # Curve 1: √N = N^{1/2}, log = (1/2) log N
    points_sqrt = []
    for i in range(n_points + 1):
        lN = log_N(i)
        lB = 0.5 * lN
        points_sqrt.append(f"{to_px(lN):.1f},{to_py(lB):.1f}")
    svg += f'<polyline points="{" ".join(points_sqrt)}" fill="none" stroke="#e74c3c" stroke-width="2.5"/>\n'

    # Curve 2: N^{2/3}, log = (2/3) log N
    points_23 = []
    for i in range(n_points + 1):
        lN = log_N(i)
        lB = (2/3) * lN
        points_23.append(f"{to_px(lN):.1f},{to_py(lB):.1f}")
    svg += f'<polyline points="{" ".join(points_23)}" fill="none" stroke="#3498db" stroke-width="2.5" stroke-dasharray="8,4"/>\n'

    # Curve 3: N^{1/3}, log = (1/3) log N (hypothetical improved bound)
    points_13 = []
    for i in range(n_points + 1):
        lN = log_N(i)
        lB = (1/3) * lN
        points_13.append(f"{to_px(lN):.1f},{to_py(lB):.1f}")
    svg += f'<polyline points="{" ".join(points_13)}" fill="none" stroke="#2ecc71" stroke-width="2" stroke-dasharray="4,4"/>\n'

    # Curve 4: N (linear bound, for reference)
    points_N = []
    for i in range(n_points + 1):
        lN = log_N(i)
        if lN <= 4.5:
            points_N.append(f"{to_px(lN):.1f},{to_py(lN):.1f}")
    svg += f'<polyline points="{" ".join(points_N)}" fill="none" stroke="#95a5a6" stroke-width="1.5" stroke-dasharray="2,3"/>\n'

    # Shade the "factoring useful" region (below √N)
    shade_points = [f"{to_px(1):.0f},{to_py(0.5):.0f}"]
    for i in range(n_points + 1):
        lN = log_N(i)
        shade_points.append(f"{to_px(lN):.1f},{to_py(0.5 * lN):.1f}")
    shade_points.append(f"{to_px(8):.0f},{py + ph:.0f}")
    shade_points.append(f"{to_px(1):.0f},{py + ph:.0f}")
    svg += f'<polygon points="{" ".join(shade_points)}" fill="#e74c3c" opacity="0.08"/>\n'

    # Labels
    svg += f'<text x="{to_px(7) + 10}" y="{to_py(3.5) - 5}" class="label" fill="#e74c3c">N^(1/2) (trial division)</text>\n'
    svg += f'<text x="{to_px(6) + 10}" y="{to_py(4) - 5}" class="label" fill="#3498db">N^(2/3) (Minkowski 3D)</text>\n'
    svg += f'<text x="{to_px(7) + 10}" y="{to_py(2.33) - 5}" class="label" fill="#2ecc71">N^(1/3) (hypothetical)</text>\n'
    svg += f'<text x="{to_px(4) + 10}" y="{to_py(4) + 3}" class="label" fill="#95a5a6">N (linear)</text>\n'

    # Annotation
    svg += f'<text x="{to_px(4)}" y="{to_py(1)}" text-anchor="middle" class="small" fill="#e74c3c">Factoring-useful region</text>\n'

    # Key insight box
    svg += '<rect x="130" y="445" width="490" height="45" fill="#fffde7" stroke="#f9a825" rx="5"/>\n'
    svg += '<text x="375" y="465" text-anchor="middle" class="label" fill="#e65100">Key insight: Generic Minkowski bound (N^(2/3)) is ABOVE √N</text>\n'
    svg += '<text x="375" y="482" text-anchor="middle" class="small" fill="#bf360c">Structured lattices might beat the generic bound → empirical question</text>\n'

    svg += svg_footer()
    return svg


# ============================================================================
# Visualization 4: The L₄(N) Non-Closure Counterexample
# ============================================================================

def create_nonclosure_svg() -> str:
    """Visualize why L₄(3) is NOT a lattice."""
    w, h = 700, 400
    svg = svg_header(w, h)

    svg += '<text x="350" y="30" text-anchor="middle" class="title">L₄(3) is NOT a Lattice: Counterexample</text>\n'
    svg += '<text x="350" y="50" text-anchor="middle" class="subtitle">The sum-of-squares congruence set fails closure under addition</text>\n'

    # Three boxes
    box_w, box_h = 190, 260
    boxes = [
        (30, 80, "v = (2, 1, 2)", "#3498db"),
        (250, 80, "w = (1, 2, 2)", "#2ecc71"),
        (470, 80, "v + w = (3, 3, 4)", "#e74c3c"),
    ]

    for bx, by, title, color in boxes:
        svg += f'<rect x="{bx}" y="{by}" width="{box_w}" height="{box_h}" fill="white" stroke="{color}" stroke-width="2" rx="8"/>\n'
        svg += f'<text x="{bx + box_w // 2}" y="{by + 25}" text-anchor="middle" class="label" fill="{color}" font-weight="bold">{title}</text>\n'

    # Box 1 content
    svg += '<text x="125" y="130" text-anchor="middle" class="label">2² + 1² + 2² = ?</text>\n'
    svg += '<text x="125" y="155" text-anchor="middle" class="label">4 + 1 + 4 = 9</text>\n'
    svg += '<text x="125" y="185" text-anchor="middle" class="label" font-weight="bold">9 = 3²  ✓</text>\n'
    svg += '<text x="125" y="220" text-anchor="middle" class="label" fill="#3498db">3² | 9</text>\n'
    svg += '<text x="125" y="250" text-anchor="middle" class="label" fill="#3498db">v ∈ L₄(3)  ✓</text>\n'
    svg += '<circle cx="125" cy="280" r="15" fill="#3498db" opacity="0.2"/>\n'
    svg += '<text x="125" y="285" text-anchor="middle" class="label" fill="#3498db" font-size="20">✓</text>\n'

    # Box 2 content
    svg += '<text x="345" y="130" text-anchor="middle" class="label">1² + 2² + 2² = ?</text>\n'
    svg += '<text x="345" y="155" text-anchor="middle" class="label">1 + 4 + 4 = 9</text>\n'
    svg += '<text x="345" y="185" text-anchor="middle" class="label" font-weight="bold">9 = 3²  ✓</text>\n'
    svg += '<text x="345" y="220" text-anchor="middle" class="label" fill="#2ecc71">3² | 9</text>\n'
    svg += '<text x="345" y="250" text-anchor="middle" class="label" fill="#2ecc71">w ∈ L₄(3)  ✓</text>\n'
    svg += '<circle cx="345" cy="280" r="15" fill="#2ecc71" opacity="0.2"/>\n'
    svg += '<text x="345" y="285" text-anchor="middle" class="label" fill="#2ecc71" font-size="20">✓</text>\n'

    # Box 3 content
    svg += '<text x="565" y="130" text-anchor="middle" class="label">3² + 3² + 4² = ?</text>\n'
    svg += '<text x="565" y="155" text-anchor="middle" class="label">9 + 9 + 16 = 34</text>\n'
    svg += '<text x="565" y="185" text-anchor="middle" class="label" font-weight="bold">34 / 9 ≈ 3.78  ✗</text>\n'
    svg += '<text x="565" y="220" text-anchor="middle" class="label" fill="#e74c3c">3² ∤ 34</text>\n'
    svg += '<text x="565" y="250" text-anchor="middle" class="label" fill="#e74c3c">v+w ∉ L₄(3)  ✗</text>\n'
    svg += '<circle cx="565" cy="280" r="15" fill="#e74c3c" opacity="0.2"/>\n'
    svg += '<text x="565" y="285" text-anchor="middle" class="label" fill="#e74c3c" font-size="20">✗</text>\n'

    # Plus sign and arrow
    svg += '<text x="235" y="210" text-anchor="middle" class="title" fill="#333" font-size="28">+</text>\n'
    svg += '<text x="455" y="210" text-anchor="middle" class="title" fill="#333" font-size="28">=</text>\n'

    # Bottom annotation
    svg += '<rect x="100" y="355" width="500" height="35" fill="#ffeaea" stroke="#e74c3c" rx="5"/>\n'
    svg += '<text x="350" y="377" text-anchor="middle" class="label" fill="#c0392b">Conclusion: L₄(N) = {(x,y,z) : N² | x²+y²+z²} is NOT a sublattice of ℤ³</text>\n'

    svg += svg_footer()
    return svg


# ============================================================================
# Visualization 5: The True Lattice Construction
# ============================================================================

def create_true_lattice_svg() -> str:
    """Visualize the genuine lattice Λ(N, r₁, r₂)."""
    w, h = 750, 520
    svg = svg_header(w, h)

    svg += '<text x="375" y="30" text-anchor="middle" class="title">The Sum-of-Three-Squares Lattice Λ(N, r₁, r₂)</text>\n'
    svg += '<text x="375" y="52" text-anchor="middle" class="subtitle">A genuine lattice whose short vectors encode divisibility by N</text>\n'

    # Construction diagram
    svg += '<rect x="30" y="70" width="690" height="120" fill="#f0f8ff" stroke="#4a86c8" rx="8"/>\n'
    svg += '<text x="375" y="95" text-anchor="middle" class="label" font-weight="bold">Construction</text>\n'
    svg += '<text x="375" y="115" text-anchor="middle" class="label">Given N and r₁, r₂ with N | (r₁² + r₂² + 1):</text>\n'
    svg += '<text x="375" y="140" text-anchor="middle" class="label math">Λ(N, r₁, r₂) = { (x, y, z) ∈ ℤ³ : N | (x − r₁z)  and  N | (y − r₂z) }</text>\n'
    svg += '<text x="375" y="165" text-anchor="middle" class="small">This IS a lattice: closed under +, −, and contains 0</text>\n'

    # Basis
    svg += '<rect x="30" y="205" width="340" height="140" fill="#f5fff0" stroke="#4ac84a" rx="8"/>\n'
    svg += '<text x="200" y="230" text-anchor="middle" class="label" font-weight="bold" fill="#2d7d2d">Basis Vectors</text>\n'
    svg += '<text x="200" y="255" text-anchor="middle" class="label math">b₁ = (N, 0, 0)</text>\n'
    svg += '<text x="200" y="278" text-anchor="middle" class="label math">b₂ = (0, N, 0)</text>\n'
    svg += '<text x="200" y="301" text-anchor="middle" class="label math">b₃ = (r₁, r₂, 1)</text>\n'
    svg += '<text x="200" y="330" text-anchor="middle" class="small" fill="#2d7d2d">det(B) = N² (proven in Lean 4)</text>\n'

    # Properties
    svg += '<rect x="390" y="205" width="330" height="140" fill="#fff5f0" stroke="#c84a4a" rx="8"/>\n'
    svg += '<text x="555" y="230" text-anchor="middle" class="label" font-weight="bold" fill="#7d2d2d">Key Properties</text>\n'
    svg += '<text x="555" y="258" text-anchor="middle" class="label">✓ True lattice (subgroup of ℤ³)</text>\n'
    svg += '<text x="555" y="281" text-anchor="middle" class="label">✓ N | (x² + y² + z²) for all (x,y,z) ∈ Λ</text>\n'
    svg += '<text x="555" y="304" text-anchor="middle" class="label">✓ Determinant = N²</text>\n'
    svg += '<text x="555" y="330" text-anchor="middle" class="small" fill="#7d2d2d">All properties formally verified</text>\n'

    # Arrow to factoring
    svg += '<line x1="375" y1="360" x2="375" y2="395" stroke="#333" stroke-width="2" marker-end="url(#arrowhead)"/>\n'
    svg += '<text x="375" y="380" text-anchor="start" x="390" class="small">LLL/BKZ reduction</text>\n'

    # Factoring connection
    svg += '<rect x="100" y="400" width="550" height="100" fill="#fffff0" stroke="#c8a84a" rx="8"/>\n'
    svg += '<text x="375" y="425" text-anchor="middle" class="label" font-weight="bold" fill="#7d6d2d">Factoring Application</text>\n'
    svg += '<text x="375" y="450" text-anchor="middle" class="label">Find short vector (x, y, z) with x² + y² + z² = k · N</text>\n'
    svg += '<text x="375" y="475" text-anchor="middle" class="label">If 1 &lt; gcd(k, N) &lt; N → nontrivial factor!</text>\n'
    svg += '<text x="375" y="495" text-anchor="middle" class="small" fill="#7d6d2d">Minkowski bound: λ₁ ≤ 1.26 · N^(2/3)  |  Need: λ₁ ≲ √N</text>\n'

    svg += svg_footer()
    return svg


# ============================================================================
# Main: Generate All SVGs
# ============================================================================

def main():
    svgs = {
        "lattice_2d.svg": create_2d_lattice_svg(N=5, r=2),
        "tree_vs_forest.svg": create_tree_forest_svg(),
        "bound_comparison.svg": create_bound_comparison_svg(),
        "nonclosure_proof.svg": create_nonclosure_svg(),
        "true_lattice.svg": create_true_lattice_svg(),
    }

    for filename, content in svgs.items():
        with open(filename, 'w') as f:
            f.write(content)
        print(f"Generated {filename}")


if __name__ == "__main__":
    main()
