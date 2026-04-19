#!/usr/bin/env python3
"""
Berggren Tree Visualizations — SVG Generation
==============================================
Generates publication-quality SVG visualizations for the V18 research paper.

Output files:
  - berggren_tree.svg: The Berggren tree to depth 3
  - pell_growth.svg: Pell sequence growth chart
  - deficit_scatter.svg: Deficit classification scatter plot
  - spectral_comparison.svg: Spectral trichotomy diagram
  - markoff_tree.svg: Markoff tree comparison

No external dependencies beyond Python standard library.
"""

import math

# =============================================================================
# SVG Helper
# =============================================================================

class SVG:
    def __init__(self, width, height, bg='white'):
        self.width = width
        self.height = height
        self.elements = []
        if bg:
            self.rect(0, 0, width, height, fill=bg, stroke='none')
    
    def rect(self, x, y, w, h, fill='none', stroke='black', stroke_width=1, rx=0):
        self.elements.append(
            f'<rect x="{x}" y="{y}" width="{w}" height="{h}" '
            f'fill="{fill}" stroke="{stroke}" stroke-width="{stroke_width}" rx="{rx}"/>')
    
    def circle(self, cx, cy, r, fill='steelblue', stroke='black', stroke_width=1):
        self.elements.append(
            f'<circle cx="{cx}" cy="{cy}" r="{r}" '
            f'fill="{fill}" stroke="{stroke}" stroke-width="{stroke_width}"/>')
    
    def line(self, x1, y1, x2, y2, stroke='black', stroke_width=1, dash=None):
        extra = f' stroke-dasharray="{dash}"' if dash else ''
        self.elements.append(
            f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
            f'stroke="{stroke}" stroke-width="{stroke_width}"{extra}/>')
    
    def text(self, x, y, content, font_size=12, anchor='middle', fill='black',
             font_weight='normal', font_family='sans-serif'):
        self.elements.append(
            f'<text x="{x}" y="{y}" font-size="{font_size}" '
            f'text-anchor="{anchor}" fill="{fill}" '
            f'font-weight="{font_weight}" font-family="{font_family}">'
            f'{content}</text>')
    
    def save(self, filename):
        with open(filename, 'w') as f:
            f.write(f'<svg xmlns="http://www.w3.org/2000/svg" '
                   f'width="{self.width}" height="{self.height}" '
                   f'viewBox="0 0 {self.width} {self.height}">\n')
            for elem in self.elements:
                f.write(f'  {elem}\n')
            f.write('</svg>\n')

# =============================================================================
# Berggren Matrices
# =============================================================================

def mat_mul(M, v):
    return [sum(M[i][j] * v[j] for j in range(3)) for i in range(3)]

B1 = [[1, -2, 2], [2, -1, 2], [2, -2, 3]]
B2 = [[1, 2, 2], [2, 1, 2], [2, 2, 3]]
B3 = [[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]

MATRICES = [B1, B2, B3]
COLORS = ['#e74c3c', '#3498db', '#2ecc71']  # Red, Blue, Green
LABELS = ['A', 'B', 'C']

# =============================================================================
# 1. Berggren Tree Visualization
# =============================================================================

def gen_berggren_tree():
    svg = SVG(1000, 600)
    svg.text(500, 30, "Berggren Tree of Primitive Pythagorean Triples", 
             font_size=18, font_weight='bold')
    
    # Tree layout
    nodes = {}
    root = (3, 4, 5)
    nodes[""] = (500, 70, root)
    
    def add_children(path, parent_x, parent_y, parent_triple, spread, depth):
        if depth > 3:
            return
        for i, M in enumerate(MATRICES):
            child = mat_mul(M, list(parent_triple))
            child_x = parent_x + (i - 1) * spread
            child_y = parent_y + 130
            child_path = path + LABELS[i]
            nodes[child_path] = (child_x, child_y, tuple(child))
            
            # Draw edge
            svg.line(parent_x, parent_y + 15, child_x, child_y - 25,
                    stroke=COLORS[i], stroke_width=2)
            svg.text((parent_x + child_x) / 2 - 10, (parent_y + child_y) / 2,
                    LABELS[i], font_size=14, fill=COLORS[i], font_weight='bold')
            
            add_children(child_path, child_x, child_y, tuple(child), 
                        spread / 3, depth + 1)
    
    add_children("", 500, 70, root, 300, 1)
    
    # Draw nodes
    for path, (x, y, triple) in nodes.items():
        a, b, c = triple
        deficit = c - b
        
        # Color by deficit
        if deficit == 1:
            fill = '#fff3cd'  # Yellow for deficit 1
        elif deficit < 10:
            fill = '#d4edda'  # Green for small deficit
        else:
            fill = '#cce5ff'  # Blue for large deficit
        
        svg.rect(x - 48, y - 22, 96, 44, fill=fill, stroke='#333', 
                stroke_width=1, rx=5)
        svg.text(x, y - 5, f"({a},{b},{c})", font_size=10)
        svg.text(x, y + 10, f"d={deficit}", font_size=8, fill='#666')
    
    # Legend
    svg.rect(20, 520, 15, 15, fill='#fff3cd', stroke='#333')
    svg.text(42, 532, "Deficit = 1 (A-branch)", font_size=10, anchor='start')
    svg.rect(20, 542, 15, 15, fill='#d4edda', stroke='#333')
    svg.text(42, 554, "Deficit < 10", font_size=10, anchor='start')
    svg.rect(20, 564, 15, 15, fill='#cce5ff', stroke='#333')
    svg.text(42, 576, "Deficit ≥ 10", font_size=10, anchor='start')
    
    # Branch labels
    for i, (label, color) in enumerate(zip(LABELS, COLORS)):
        svg.line(250 + i*80, 570, 270 + i*80, 570, stroke=color, stroke_width=3)
        svg.text(285 + i*80, 574, f"{label}-branch", font_size=10, anchor='start', fill=color)
    
    svg.save('berggren_tree.svg')
    print("Generated: berggren_tree.svg")

# =============================================================================
# 2. Pell Sequence Growth Chart
# =============================================================================

def pell_fast(n):
    if n == 0: return (1, 0)
    result = (1, 0)
    base = (3, 1)
    while n > 0:
        if n % 2 == 1:
            result = (result[0]*base[0] + 8*result[1]*base[1],
                     result[0]*base[1] + result[1]*base[0])
        base = (base[0]*base[0] + 8*base[1]*base[1],
               2*base[0]*base[1])
        n //= 2
    return result

def gen_pell_growth():
    svg = SVG(800, 500)
    svg.text(400, 30, "Pell Sequence Growth & Trace Formula", 
             font_size=18, font_weight='bold')
    
    # Plot area
    px, py, pw, ph = 80, 60, 650, 350
    svg.rect(px, py, pw, ph, fill='#f8f9fa', stroke='#333')
    
    N = 10
    data_px = [pell_fast(n)[0] for n in range(N+1)]
    data_tr = [2*pell_fast(n)[0] + (-1)**n for n in range(N+1)]
    
    max_val = max(data_tr)
    log_max = math.log10(max_val) if max_val > 0 else 1
    
    # Y-axis (log scale)
    for i in range(int(log_max) + 2):
        y_pos = py + ph - (i / (log_max + 1)) * ph
        svg.line(px, y_pos, px + pw, y_pos, stroke='#ddd', stroke_width=1)
        svg.text(px - 10, y_pos + 4, f"10^{i}", font_size=10, anchor='end')
    
    # X-axis
    for n in range(N + 1):
        x_pos = px + (n / N) * pw
        svg.line(x_pos, py, x_pos, py + ph, stroke='#eee', stroke_width=1)
        svg.text(x_pos, py + ph + 15, str(n), font_size=10)
    
    svg.text(400, py + ph + 35, "n", font_size=14)
    
    # Plot pellX (log scale)
    for n in range(N):
        x1 = px + (n / N) * pw
        x2 = px + ((n+1) / N) * pw
        y1_val = math.log10(data_px[n]) if data_px[n] > 0 else 0
        y2_val = math.log10(data_px[n+1]) if data_px[n+1] > 0 else 0
        y1 = py + ph - (y1_val / (log_max + 1)) * ph
        y2 = py + ph - (y2_val / (log_max + 1)) * ph
        svg.line(x1, y1, x2, y2, stroke='#e74c3c', stroke_width=2)
    
    # Plot trace (log scale)
    for n in range(N):
        x1 = px + (n / N) * pw
        x2 = px + ((n+1) / N) * pw
        y1_val = math.log10(data_tr[n]) if data_tr[n] > 0 else 0
        y2_val = math.log10(data_tr[n+1]) if data_tr[n+1] > 0 else 0
        y1 = py + ph - (y1_val / (log_max + 1)) * ph
        y2 = py + ph - (y2_val / (log_max + 1)) * ph
        svg.line(x1, y1, x2, y2, stroke='#3498db', stroke_width=2)
    
    # Data points
    for n in range(N + 1):
        x = px + (n / N) * pw
        yp = math.log10(data_px[n]) if data_px[n] > 0 else 0
        yt = math.log10(data_tr[n]) if data_tr[n] > 0 else 0
        yp_pos = py + ph - (yp / (log_max + 1)) * ph
        yt_pos = py + ph - (yt / (log_max + 1)) * ph
        svg.circle(x, yp_pos, 3, fill='#e74c3c')
        svg.circle(x, yt_pos, 3, fill='#3498db')
    
    # Legend
    svg.line(500, 440, 530, 440, stroke='#e74c3c', stroke_width=3)
    svg.text(535, 444, "pellX(n)", font_size=12, anchor='start', fill='#e74c3c')
    svg.line(500, 460, 530, 460, stroke='#3498db', stroke_width=3)
    svg.text(535, 464, "tr(B₂ⁿ) = 2·pellX(n) + (-1)ⁿ", font_size=12, 
             anchor='start', fill='#3498db')
    
    # Formula box
    svg.rect(100, 440, 350, 45, fill='#fff3cd', stroke='#856404', rx=5)
    svg.text(275, 458, "PROVED ∀n: tr(B₂ⁿ) = 2·pellX(n) + (-1)ⁿ", 
             font_size=12, font_weight='bold', fill='#856404')
    svg.text(275, 475, "Growth rate: (3 + 2√2)ⁿ ≈ 5.828ⁿ", 
             font_size=11, fill='#856404')
    
    svg.save('pell_growth.svg')
    print("Generated: pell_growth.svg")

# =============================================================================
# 3. Spectral Trichotomy Diagram
# =============================================================================

def gen_spectral_diagram():
    svg = SVG(900, 400)
    svg.text(450, 30, "Spectral Trichotomy of Berggren Matrices", 
             font_size=18, font_weight='bold')
    
    # Three boxes for the three matrices
    box_data = [
        ("B₁ (A-branch)", "#ffe0e0", [
            "det = 1",
            "eigenvalues: {1, 1, 1}",
            "(B₁ - I)³ = 0  UNIPOTENT",
            "tr(B₁ⁿ) = 3  ∀n",
            "Polynomial growth",
        ]),
        ("B₂ (B-branch)", "#e0e0ff", [
            "det = -1",
            "eigenvalues: {3+2√2, 3-2√2, -1}",
            "Diagonalizable",
            "tr(B₂ⁿ) = 2·pellX(n) + (-1)ⁿ",
            "Exponential growth",
        ]),
        ("B₃ (C-branch)", "#e0ffe0", [
            "det = 1",
            "eigenvalues: {1, 1, 1}",
            "(B₃ - I)³ = 0  UNIPOTENT",
            "tr(B₃ⁿ) = 3  ∀n",
            "Polynomial growth",
        ]),
    ]
    
    for i, (title, color, props) in enumerate(box_data):
        x = 30 + i * 290
        y = 60
        svg.rect(x, y, 270, 280, fill=color, stroke='#333', rx=8)
        svg.text(x + 135, y + 25, title, font_size=14, font_weight='bold')
        svg.line(x + 10, y + 35, x + 260, y + 35, stroke='#333')
        
        for j, prop in enumerate(props):
            svg.text(x + 135, y + 60 + j * 30, prop, font_size=11)
    
    # Connecting arrows
    svg.text(450, 370, "★ B₁ and B₃ are spectrally identical (same char. poly: (λ-1)³ = 0)", 
             font_size=12, fill='#333')
    svg.text(450, 390, "★ Only B₂ has exponential spectral growth (spectral radius = 3+2√2 ≈ 5.83)", 
             font_size=12, fill='#333')
    
    svg.save('spectral_trichotomy.svg')
    print("Generated: spectral_trichotomy.svg")

# =============================================================================
# 4. Deficit Classification Scatter Plot
# =============================================================================

def gen_deficit_scatter():
    svg = SVG(800, 500)
    svg.text(400, 30, "Deficit Classification: d = c - b for PPTs", 
             font_size=18, font_weight='bold')
    
    # Generate PPTs
    ppts = []
    root = [3, 4, 5]
    queue = [(root, "")]
    ppts.append((root, ""))
    for depth in range(5):
        next_q = []
        for triple, path in queue:
            for i, M in enumerate(MATRICES):
                child = mat_mul(M, triple)
                child_path = path + LABELS[i]
                ppts.append((child, child_path))
                next_q.append((child, child_path))
        queue = next_q
    
    px, py, pw, ph = 80, 60, 650, 370
    svg.rect(px, py, pw, ph, fill='#f8f9fa', stroke='#333')
    
    max_c = max(t[2] for t, _ in ppts)
    max_d = max(t[2] - t[1] for t, _ in ppts)
    
    for t, path in ppts:
        a, b, c = t
        d = c - b
        x = px + (c / max_c) * pw * 0.95
        y = py + ph - (d / max_d) * ph * 0.95
        
        branch = path[0] if path else 'R'
        color = {'A': '#e74c3c', 'B': '#3498db', 'C': '#2ecc71', 'R': '#f39c12'}[branch]
        svg.circle(x, y, 4, fill=color, stroke='#333', stroke_width=0.5)
    
    svg.text(px + pw/2, py + ph + 30, "Hypotenuse c", font_size=14)
    svg.text(px - 30, py + ph/2, "d = c - b", font_size=14)
    
    # Legend
    for i, (label, color) in enumerate([('Root', '#f39c12'), ('A-branch', '#e74c3c'), 
                                         ('B-branch', '#3498db'), ('C-branch', '#2ecc71')]):
        svg.circle(600, 80 + i*20, 5, fill=color)
        svg.text(615, 84 + i*20, label, font_size=11, anchor='start')
    
    svg.text(400, py + ph + 50, "Note: A-branch preserves deficit (all A-descendants have d=1)", 
             font_size=11, fill='#666')
    
    svg.save('deficit_scatter.svg')
    print("Generated: deficit_scatter.svg")

# =============================================================================
# Main
# =============================================================================

def main():
    print("Generating V18 Research Visualizations...")
    gen_berggren_tree()
    gen_pell_growth()
    gen_spectral_diagram()
    gen_deficit_scatter()
    print("\nAll visualizations generated successfully!")
    print("Files: berggren_tree.svg, pell_growth.svg, spectral_trichotomy.svg, deficit_scatter.svg")

if __name__ == "__main__":
    main()
