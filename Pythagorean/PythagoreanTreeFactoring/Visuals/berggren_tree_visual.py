#!/usr/bin/env python3
"""
Berggren Tree Visualization (SCG)
====================================
Generates publication-quality visualizations of:
1. The Berggren ternary tree of Pythagorean triples
2. The lattice-tree correspondence diagram
3. Complexity scaling plots
4. The 2D→3D dimensional escape

Outputs SVG files suitable for scientific papers.

Requirements: matplotlib, numpy (standard scientific Python)
"""

import math
import json
import os

# ─── Pure Python SVG Generator (no dependencies needed) ────────────

class SVGCanvas:
    """Minimal SVG generator for scientific graphics."""

    def __init__(self, width: int, height: int, title: str = ""):
        self.width = width
        self.height = height
        self.elements = []
        self.title = title
        self.defs = []

    def add_style(self, css: str):
        self.defs.append(f"<style>{css}</style>")

    def rect(self, x, y, w, h, fill="white", stroke="black", stroke_width=1, rx=0, opacity=1):
        self.elements.append(
            f'<rect x="{x}" y="{y}" width="{w}" height="{h}" '
            f'fill="{fill}" stroke="{stroke}" stroke-width="{stroke_width}" '
            f'rx="{rx}" opacity="{opacity}"/>'
        )

    def circle(self, cx, cy, r, fill="white", stroke="black", stroke_width=1):
        self.elements.append(
            f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}" '
            f'stroke="{stroke}" stroke-width="{stroke_width}"/>'
        )

    def line(self, x1, y1, x2, y2, stroke="black", stroke_width=1, dash=""):
        d = f' stroke-dasharray="{dash}"' if dash else ""
        self.elements.append(
            f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
            f'stroke="{stroke}" stroke-width="{stroke_width}"{d}/>'
        )

    def text(self, x, y, content, font_size=14, fill="black", anchor="middle", font_weight="normal", font_family="serif"):
        self.elements.append(
            f'<text x="{x}" y="{y}" font-size="{font_size}" fill="{fill}" '
            f'text-anchor="{anchor}" font-weight="{font_weight}" font-family="{font_family}">{content}</text>'
        )

    def path(self, d, fill="none", stroke="black", stroke_width=1):
        self.elements.append(
            f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{stroke_width}"/>'
        )

    def arrow(self, x1, y1, x2, y2, stroke="black", stroke_width=2):
        """Draw an arrow from (x1,y1) to (x2,y2)."""
        angle = math.atan2(y2 - y1, x2 - x1)
        head_len = 10
        # Arrow body
        self.line(x1, y1, x2, y2, stroke=stroke, stroke_width=stroke_width)
        # Arrowhead
        ax1 = x2 - head_len * math.cos(angle - 0.3)
        ay1 = y2 - head_len * math.sin(angle - 0.3)
        ax2 = x2 - head_len * math.cos(angle + 0.3)
        ay2 = y2 - head_len * math.sin(angle + 0.3)
        self.path(f"M{x2},{y2} L{ax1},{ay1} L{ax2},{ay2} Z", fill=stroke)

    def group_start(self, transform=""):
        t = f' transform="{transform}"' if transform else ""
        self.elements.append(f'<g{t}>')

    def group_end(self):
        self.elements.append('</g>')

    def render(self) -> str:
        defs_str = "\n".join(self.defs)
        elems_str = "\n".join(self.elements)
        return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{self.width}" height="{self.height}"
     viewBox="0 0 {self.width} {self.height}">
  <defs>
    {defs_str}
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="black"/>
    </marker>
  </defs>
  {elems_str}
</svg>'''

    def save(self, filename: str):
        with open(filename, 'w') as f:
            f.write(self.render())
        print(f"  Saved: {filename}")


# ─── Figure 1: Berggren Ternary Tree ────────────────────────────────

def draw_berggren_tree():
    """Draw the Berggren ternary tree of Pythagorean triples."""
    svg = SVGCanvas(900, 600, "Berggren Ternary Tree")
    svg.add_style("""
        .node { fill: #E8F4FD; stroke: #2196F3; stroke-width: 2; }
        .root { fill: #FFF3E0; stroke: #FF9800; stroke-width: 3; }
        .label { font-family: 'Georgia', serif; font-size: 13px; }
        .branch { font-family: 'Courier New', monospace; font-size: 11px; fill: #666; }
        .title { font-family: 'Georgia', serif; font-size: 20px; font-weight: bold; }
    """)

    # Title
    svg.text(450, 35, "The Berggren Ternary Tree of Primitive Pythagorean Triples", font_size=20, font_weight="bold")
    svg.text(450, 55, "Every primitive Pythagorean triple appears exactly once", font_size=13, fill="#666")

    # Tree structure: root and three levels
    tree = {
        (3, 4, 5): {
            (5, 12, 13): {
                (7, 24, 25): {},
                (55, 48, 73): {},
                (45, 28, 53): {},
            },
            (21, 20, 29): {
                (39, 80, 89): {},
                (119, 120, 169): {},
                (77, 36, 85): {},
            },
            (15, 8, 17): {
                (33, 56, 65): {},
                (65, 72, 97): {},
                (35, 12, 37): {},
            },
        }
    }

    def draw_node(x, y, triple, is_root=False):
        w, h = 90, 35
        cls = "root" if is_root else "node"
        svg.rect(x - w//2, y - h//2, w, h, rx=8,
                fill="#FFF3E0" if is_root else "#E8F4FD",
                stroke="#FF9800" if is_root else "#2196F3",
                stroke_width=3 if is_root else 2)
        a, b, c = triple
        svg.text(x, y + 5, f"({a},{b},{c})", font_size=12)

    # Positions
    root_y = 120
    level1_y = 250
    level2_y = 400

    # Root
    draw_node(450, root_y, (3, 4, 5), is_root=True)

    # Level 1
    l1_positions = [150, 450, 750]
    l1_triples = [(5, 12, 13), (21, 20, 29), (15, 8, 17)]
    l1_labels = ["B₁", "B₂", "B₃"]

    for i, (pos, triple, label) in enumerate(zip(l1_positions, l1_triples, l1_labels)):
        svg.line(450, root_y + 18, pos, level1_y - 18, stroke="#999", stroke_width=1.5)
        svg.text((450 + pos) // 2 + (-20 if i == 0 else 20 if i == 2 else 0),
                 (root_y + level1_y) // 2 - 5, label, font_size=14, fill="#FF5722", font_weight="bold")
        draw_node(pos, level1_y, triple)

    # Level 2
    l2_groups = [
        [(50, (7, 24, 25)), (150, (55, 48, 73)), (250, (45, 28, 53))],
        [(350, (39, 80, 89)), (450, (119, 120, 169)), (550, (77, 36, 85))],
        [(650, (33, 56, 65)), (750, (65, 72, 97)), (850, (35, 12, 37))],
    ]

    for group_idx, group in enumerate(l2_groups):
        parent_x = l1_positions[group_idx]
        for pos, triple in group:
            svg.line(parent_x, level1_y + 18, pos, level2_y - 18, stroke="#CCC", stroke_width=1)
            draw_node(pos, level2_y, triple)

    # Dots indicating continuation
    for pos, _ in [(50, 0), (150, 0), (250, 0), (350, 0), (450, 0), (550, 0), (650, 0), (750, 0), (850, 0)]:
        svg.text(pos, level2_y + 40, "⋮", font_size=18, fill="#999")

    # Legend
    svg.rect(20, 480, 860, 100, fill="#FAFAFA", stroke="#DDD", rx=5)
    svg.text(450, 505, "KEY PROPERTY: Each Berggren matrix Bᵢ ∈ O(2,1;ℤ) preserves a² + b² = c²", font_size=14)
    svg.text(450, 530, "The tree structure exists because O(2,1;ℤ) is virtually free", font_size=13, fill="#666")
    svg.text(450, 555, "Inverse descent through this tree = Gauss's 2D lattice reduction = Θ(√N) for factoring", font_size=13, fill="#C62828")

    svg.save(os.path.join(os.path.dirname(__file__), "berggren_tree.svg"))


# ─── Figure 2: Lattice-Tree Correspondence ──────────────────────────

def draw_correspondence():
    """Draw the lattice-tree correspondence diagram."""
    svg = SVGCanvas(900, 500, "Lattice-Tree Correspondence")

    # Title
    svg.text(450, 35, "The Lattice-Tree Correspondence Theorem", font_size=20, font_weight="bold")

    # Left box: Berggren Tree
    svg.rect(30, 70, 380, 180, fill="#E3F2FD", stroke="#1565C0", stroke_width=2, rx=10)
    svg.text(220, 100, "Berggren Tree Descent", font_size=16, font_weight="bold", fill="#1565C0")
    svg.text(220, 130, "M₃⁻¹: (m,n) ↦ (m-2n, n)", font_size=14, font_family="monospace")
    svg.text(220, 155, "M₁⁻¹: (m,n) ↦ (n, 2n-m)", font_size=14, font_family="monospace")
    svg.text(220, 185, "Subtraction + Swap", font_size=13, fill="#666")
    svg.text(220, 210, "O(log(m/n)) steps", font_size=13, fill="#666")

    # Right box: Gauss Reduction
    svg.rect(490, 70, 380, 180, fill="#E8F5E9", stroke="#2E7D32", stroke_width=2, rx=10)
    svg.text(680, 100, "Gauss Lattice Reduction", font_size=16, font_weight="bold", fill="#2E7D32")
    svg.text(680, 130, "v₂ ← v₂ - ⌊μ⌋·v₁", font_size=14, font_family="monospace")
    svg.text(680, 155, "swap if |v₂| < |v₁|", font_size=14, font_family="monospace")
    svg.text(680, 185, "Size-reduce + Swap", font_size=13, fill="#666")
    svg.text(680, 210, "O(log(max/min)) steps", font_size=13, fill="#666")

    # Equivalence arrows
    svg.text(450, 150, "≡", font_size=36, fill="#D32F2F", font_weight="bold")
    svg.arrow(410, 140, 490, 140, stroke="#D32F2F", stroke_width=2)
    svg.arrow(490, 170, 410, 170, stroke="#D32F2F", stroke_width=2)

    # Bottom: Continued Fractions
    svg.rect(200, 290, 500, 80, fill="#FFF8E1", stroke="#F57F17", stroke_width=2, rx=10)
    svg.text(450, 320, "Euclidean Algorithm / Continued Fractions", font_size=16, font_weight="bold", fill="#F57F17")
    svg.text(450, 345, "a = q·b + r,  repeat with (b, r)", font_size=14, font_family="monospace")

    # Connecting arrows
    svg.arrow(220, 250, 350, 290, stroke="#F57F17")
    svg.arrow(680, 250, 550, 290, stroke="#F57F17")
    svg.text(260, 275, "≡", font_size=24, fill="#F57F17")
    svg.text(640, 275, "≡", font_size=24, fill="#F57F17")

    # Consequence box
    svg.rect(100, 400, 700, 80, fill="#FFEBEE", stroke="#C62828", stroke_width=2, rx=10)
    svg.text(450, 425, "CONSEQUENCE: Pythagorean tree factoring is Θ(√N)", font_size=16, font_weight="bold", fill="#C62828")
    svg.text(450, 450, "for balanced semiprimes N = p·q with p ≈ q ≈ √N", font_size=14, fill="#C62828")
    svg.text(450, 470, "No 2D method can beat this — Gauss's algorithm is optimal in dimension 2", font_size=12, fill="#666")

    svg.save(os.path.join(os.path.dirname(__file__), "lattice_tree_correspondence.svg"))


# ─── Figure 3: Complexity Scaling ─────────────────────────────────────

def draw_complexity():
    """Draw complexity scaling comparison chart."""
    svg = SVGCanvas(800, 500, "Complexity Scaling")

    # Title
    svg.text(400, 35, "Factoring Complexity: Tree Descent vs Trial Division", font_size=18, font_weight="bold")

    # Axes
    ox, oy = 100, 400  # origin
    ax, ay = 700, 400  # x-axis end
    tx, ty = 100, 80   # y-axis end

    svg.arrow(ox, oy, ax, oy, stroke="black")
    svg.arrow(ox, oy, ox, ty, stroke="black")
    svg.text(400, 450, "N (semiprime size)", font_size=14)
    svg.text(60, 240, "Steps", font_size=14)

    # Data points (approximate)
    # √N curve
    points_sqrt = []
    for i in range(1, 20):
        N = i * i * 50
        x = ox + (i / 20) * (ax - ox - 50)
        y = oy - (math.sqrt(N) / math.sqrt(20 * 20 * 50)) * (oy - ty - 30)
        points_sqrt.append((x, y))

    # Draw √N curve (blue)
    for i in range(len(points_sqrt) - 1):
        svg.line(points_sqrt[i][0], points_sqrt[i][1],
                points_sqrt[i+1][0], points_sqrt[i+1][1],
                stroke="#1565C0", stroke_width=3)

    # N curve (for reference)
    points_n = []
    for i in range(1, 20):
        N = i * i * 50
        x = ox + (i / 20) * (ax - ox - 50)
        y = oy - min((N / (20 * 20 * 50)) * (oy - ty - 30), oy - ty - 30)
        points_n.append((x, y))

    for i in range(len(points_n) - 1):
        svg.line(points_n[i][0], points_n[i][1],
                points_n[i+1][0], points_n[i+1][1],
                stroke="#E53935", stroke_width=2, dash="5,5")

    # Log N curve (ideal)
    points_log = []
    for i in range(1, 20):
        N = i * i * 50
        x = ox + (i / 20) * (ax - ox - 50)
        y = oy - (math.log(N + 1) / math.log(20 * 20 * 50 + 1)) * (oy - ty - 30) * 0.3
        points_log.append((x, y))

    for i in range(len(points_log) - 1):
        svg.line(points_log[i][0], points_log[i][1],
                points_log[i+1][0], points_log[i+1][1],
                stroke="#4CAF50", stroke_width=2, dash="3,3")

    # Labels
    svg.text(660, points_sqrt[-1][1] - 15, "Θ(√N)", font_size=14, fill="#1565C0", font_weight="bold", anchor="start")
    svg.text(660, points_sqrt[-1][1] + 5, "Tree & Trial", font_size=11, fill="#1565C0", anchor="start")

    svg.text(500, ty + 20, "O(N)", font_size=14, fill="#E53935", anchor="start")
    svg.text(500, ty + 38, "(brute force)", font_size=11, fill="#E53935", anchor="start")

    svg.text(660, points_log[-1][1] - 10, "O(log N)?", font_size=14, fill="#4CAF50", font_weight="bold", anchor="start")
    svg.text(660, points_log[-1][1] + 8, "(3D target)", font_size=11, fill="#4CAF50", anchor="start")

    # Annotation
    svg.rect(120, 420, 550, 55, fill="#FFF8E1", stroke="#F57F17", rx=5)
    svg.text(395, 440, "Tree descent and trial division have identical Θ(√N) complexity", font_size=13, fill="#333")
    svg.text(395, 460, "The 3D quadruple lattice is the only known escape route", font_size=12, fill="#666")

    svg.save(os.path.join(os.path.dirname(__file__), "complexity_scaling.svg"))


# ─── Figure 4: Dimensional Escape ─────────────────────────────────────

def draw_dimensional_escape():
    """Draw the 2D→3D dimensional escape diagram."""
    svg = SVGCanvas(900, 550, "Dimensional Escape")

    svg.text(450, 35, "The Dimensional Escape: From 2D Barrier to 3D Opportunity", font_size=18, font_weight="bold")

    # Left panel: 2D Lattice
    svg.rect(30, 60, 400, 230, fill="#FFEBEE", stroke="#C62828", rx=10)
    svg.text(230, 90, "2D: Pythagorean Triples", font_size=16, font_weight="bold", fill="#C62828")

    # 2D lattice grid
    ox2, oy2 = 120, 200
    for i in range(-2, 4):
        for j in range(-1, 3):
            x = ox2 + i * 45
            y = oy2 - j * 40
            svg.circle(x, y, 3, fill="#C62828", stroke="none")

    # Shortest vector highlighted
    svg.arrow(ox2, oy2, ox2 + 45, oy2 - 40, stroke="#C62828", stroke_width=2)
    svg.text(ox2 + 60, oy2 - 50, "λ₁", font_size=14, fill="#C62828", font_weight="bold")

    svg.text(230, 250, "Gauss finds λ₁ exactly", font_size=13, fill="#666")
    svg.text(230, 270, "= Berggren descent", font_size=13, fill="#666")

    # Right panel: 3D Lattice
    svg.rect(470, 60, 400, 230, fill="#E8F5E9", stroke="#2E7D32", rx=10)
    svg.text(670, 90, "3D: Pythagorean Quadruples", font_size=16, font_weight="bold", fill="#2E7D32")

    # 3D lattice (projected)
    ox3, oy3 = 580, 200
    for i in range(-2, 3):
        for j in range(-1, 3):
            for k in range(-1, 2):
                x = ox3 + i * 35 + k * 15
                y = oy3 - j * 30 - k * 10
                svg.circle(x, y, 2.5, fill="#2E7D32", stroke="none")

    # Multiple short vectors
    svg.arrow(ox3, oy3, ox3 + 35, oy3 - 30, stroke="#2E7D32", stroke_width=2)
    svg.arrow(ox3, oy3, ox3 + 15, oy3 - 40, stroke="#4CAF50", stroke_width=2)
    svg.text(ox3 + 50, oy3 - 35, "λ₁?", font_size=14, fill="#2E7D32", font_weight="bold")

    svg.text(670, 250, "Gauss misses shorter vectors!", font_size=13, fill="#666")
    svg.text(670, 270, "LLL/BKZ needed", font_size=13, fill="#666")

    # Arrow between panels
    svg.arrow(430, 175, 470, 175, stroke="#FF9800", stroke_width=3)
    svg.text(450, 165, "escape", font_size=12, fill="#FF9800", font_weight="bold")

    # Bottom comparison table
    svg.rect(50, 320, 800, 200, fill="#FAFAFA", stroke="#DDD", rx=5)
    svg.text(450, 350, "DIMENSIONAL COMPARISON", font_size=16, font_weight="bold")

    # Table headers
    headers = ["Property", "2D (Triples)", "3D (Quadruples)"]
    cols = [180, 420, 680]
    for col, header in zip(cols, headers):
        svg.text(col, 380, header, font_size=13, font_weight="bold", fill="#333")

    # Table rows
    rows = [
        ("Group", "O(2,1;ℤ)", "O(3,1;ℤ)"),
        ("Structure", "Virtually free", "NOT virtually free"),
        ("Tree exists?", "✓ Berggren tree", "✗ No tree"),
        ("Optimal reduction", "Gauss (exact)", "LLL/BKZ (approximate)"),
        ("Factoring", "Θ(√N)", "Sub-√N possible?"),
    ]
    for i, (prop, val2d, val3d) in enumerate(rows):
        y = 405 + i * 22
        svg.text(180, y, prop, font_size=12, fill="#333")
        svg.text(420, y, val2d, font_size=12, fill="#C62828")
        svg.text(680, y, val3d, font_size=12, fill="#2E7D32")

    svg.save(os.path.join(os.path.dirname(__file__), "dimensional_escape.svg"))


# ─── Figure 5: Research Program Overview ─────────────────────────────

def draw_research_program():
    """Draw the research program flowchart."""
    svg = SVGCanvas(800, 650, "Research Program")

    svg.text(400, 35, "Research Program: Pythagorean Tree Factoring", font_size=18, font_weight="bold")

    # Boxes for each stage
    stages = [
        (400, 90, "PROVEN: Lattice-Tree Correspondence", "#E8F5E9", "#2E7D32"),
        (400, 170, "PROVEN: 2D Optimality (Θ(√N) barrier)", "#E8F5E9", "#2E7D32"),
        (400, 250, "CONSTRUCTED: Quadruple Lattice L₄(N)", "#E3F2FD", "#1565C0"),
        (400, 330, "ACTIVE: O(3,1;ℤ) Generators", "#FFF3E0", "#FF9800"),
        (400, 410, "ACTIVE: BKZ Reduction on L₄(N)", "#FFF3E0", "#FF9800"),
        (400, 490, "TARGET: Sub-√N Short Vectors", "#FFEBEE", "#C62828"),
        (400, 570, "GOAL: Sub-√N Factoring Algorithm", "#FFEBEE", "#C62828"),
    ]

    for x, y, label, fill, stroke in stages:
        w = 500
        svg.rect(x - w//2, y - 20, w, 40, fill=fill, stroke=stroke, stroke_width=2, rx=8)
        svg.text(x, y + 5, label, font_size=14, fill="#333")

    # Arrows
    for i in range(len(stages) - 1):
        svg.arrow(400, stages[i][1] + 20, 400, stages[i+1][1] - 20, stroke="#999")

    # Status indicators
    svg.circle(130, stages[0][1], 8, fill="#4CAF50", stroke="none")
    svg.circle(130, stages[1][1], 8, fill="#4CAF50", stroke="none")
    svg.circle(130, stages[2][1], 8, fill="#2196F3", stroke="none")
    svg.circle(130, stages[3][1], 8, fill="#FF9800", stroke="none")
    svg.circle(130, stages[4][1], 8, fill="#FF9800", stroke="none")
    svg.circle(130, stages[5][1], 8, fill="#F44336", stroke="none")
    svg.circle(130, stages[6][1], 8, fill="#F44336", stroke="none")

    # Legend
    svg.rect(600, 90, 170, 120, fill="#FAFAFA", stroke="#DDD", rx=5)
    svg.circle(620, 110, 6, fill="#4CAF50", stroke="none")
    svg.text(640, 115, "Proven", font_size=12, anchor="start")
    svg.circle(620, 135, 6, fill="#2196F3", stroke="none")
    svg.text(640, 140, "Constructed", font_size=12, anchor="start")
    svg.circle(620, 160, 6, fill="#FF9800", stroke="none")
    svg.text(640, 165, "Active", font_size=12, anchor="start")
    svg.circle(620, 185, 6, fill="#F44336", stroke="none")
    svg.text(640, 190, "Target", font_size=12, anchor="start")

    svg.save(os.path.join(os.path.dirname(__file__), "research_program.svg"))


# ─── Main ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating SCG Visuals for Pythagorean Tree Factoring...")
    print()

    draw_berggren_tree()
    draw_correspondence()
    draw_complexity()
    draw_dimensional_escape()
    draw_research_program()

    print()
    print("All visuals generated successfully!")
    print("Files are in the Visuals/ directory as SVG files.")
