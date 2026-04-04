#!/usr/bin/env python3
"""
SCG (Scientific Computing Graphics) Visualizations
for Inverse Pythagorean Tree Factoring

Generates publication-quality figures as SVG for the research paper
and Scientific American article.

Figures generated:
1. Berggren tree structure (first 4 levels)
2. Descent path visualization
3. Klein disk geodesic trace
4. Depth vs min(p,q) scatter plot
5. Branch sequence patterns
6. Hypotenuse decay curves
"""

import math
import sys

sys.path.insert(0, '../Python')
from inverse_tree_factoring import (
    trivial_triple, parent, full_descent, fwd_B1, fwd_B2, fwd_B3
)

# ============================================================================
# SVG Utilities
# ============================================================================

def svg_header(width: int, height: int, viewbox: str = None) -> str:
    if viewbox is None:
        viewbox = f"0 0 {width} {height}"
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="{viewbox}">
<defs>
  <style>
    .title {{ font: bold 18px 'Helvetica Neue', Arial, sans-serif; fill: #2c3e50; }}
    .subtitle {{ font: 14px 'Helvetica Neue', Arial, sans-serif; fill: #7f8c8d; }}
    .label {{ font: 11px 'Courier New', monospace; fill: #2c3e50; text-anchor: middle; }}
    .small-label {{ font: 9px 'Courier New', monospace; fill: #555; text-anchor: middle; }}
    .axis-label {{ font: 12px 'Helvetica Neue', Arial, sans-serif; fill: #2c3e50; }}
    .node-root {{ fill: #e74c3c; stroke: #c0392b; stroke-width: 2; }}
    .node-l1 {{ fill: #3498db; stroke: #2980b9; stroke-width: 1.5; }}
    .node-l2 {{ fill: #2ecc71; stroke: #27ae60; stroke-width: 1.5; }}
    .node-l3 {{ fill: #f39c12; stroke: #e67e22; stroke-width: 1.5; }}
    .node-l4 {{ fill: #9b59b6; stroke: #8e44ad; stroke-width: 1; }}
    .edge {{ stroke: #bdc3c7; stroke-width: 1.5; fill: none; }}
    .descent-edge {{ stroke: #e74c3c; stroke-width: 2.5; fill: none; stroke-dasharray: 5,3; }}
    .descent-node {{ fill: #e74c3c; stroke: #c0392b; stroke-width: 2; }}
    .factor-node {{ fill: #f1c40f; stroke: #f39c12; stroke-width: 3; }}
  </style>
  <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
    <polygon points="0 0, 10 3.5, 0 7" fill="#e74c3c"/>
  </marker>
</defs>
'''

def svg_footer() -> str:
    return '</svg>\n'

# ============================================================================
# Figure 1: Berggren Tree Structure
# ============================================================================

def generate_tree_figure():
    """Generate the Berggren tree showing first 4 levels."""
    width, height = 900, 600
    svg = svg_header(width, height)
    
    svg += '<text x="450" y="30" class="title" text-anchor="middle">The Berggren Pythagorean Triple Tree</text>\n'
    svg += '<text x="450" y="50" class="subtitle" text-anchor="middle">Every primitive Pythagorean triple appears exactly once</text>\n'
    
    # Tree layout
    levels = {}
    
    # Level 0: root
    levels[0] = [(3, 4, 5)]
    
    # Level 1
    l1 = []
    for a, b, c in levels[0]:
        l1.append(fwd_B1(a, b, c))
        l1.append(fwd_B2(a, b, c))
        l1.append(fwd_B3(a, b, c))
    levels[1] = l1
    
    # Level 2
    l2 = []
    for a, b, c in levels[1]:
        l2.append(fwd_B1(a, b, c))
        l2.append(fwd_B2(a, b, c))
        l2.append(fwd_B3(a, b, c))
    levels[2] = l2
    
    # Level 3 (just first few)
    l3 = []
    for a, b, c in levels[2][:3]:
        l3.append(fwd_B1(a, b, c))
        l3.append(fwd_B2(a, b, c))
        l3.append(fwd_B3(a, b, c))
    levels[3] = l3
    
    node_classes = ['node-root', 'node-l1', 'node-l2', 'node-l3', 'node-l4']
    y_positions = [80, 180, 310, 450]
    
    # Draw edges first
    for level in range(3):
        parent_nodes = levels[level]
        child_nodes = levels[level + 1]
        y1 = y_positions[level]
        y2 = y_positions[level + 1]
        
        for pi, (pa, pb, pc) in enumerate(parent_nodes):
            if level + 1 == 3 and pi >= 3:
                break
            px = 450 + (pi - len(parent_nodes)/2 + 0.5) * (700 / max(1, len(parent_nodes)))
            
            for ci in range(3):
                child_idx = pi * 3 + ci
                if child_idx >= len(child_nodes):
                    break
                cx = 450 + (child_idx - len(child_nodes)/2 + 0.5) * (700 / max(1, len(child_nodes)))
                
                svg += f'<line x1="{px:.0f}" y1="{y1+25:.0f}" x2="{cx:.0f}" y2="{y2-15:.0f}" class="edge"/>\n'
    
    # Draw nodes
    for level in range(min(4, len(levels))):
        nodes = levels[level]
        y = y_positions[level]
        node_class = node_classes[min(level, len(node_classes)-1)]
        
        for ni, (a, b, c) in enumerate(nodes):
            x = 450 + (ni - len(nodes)/2 + 0.5) * (700 / max(1, len(nodes)))
            
            rx = 45 if level <= 1 else 38
            ry = 14
            
            svg += f'<ellipse cx="{x:.0f}" cy="{y}" rx="{rx}" ry="{ry}" class="{node_class}"/>\n'
            svg += f'<text x="{x:.0f}" y="{y+4}" class="{"label" if level <= 1 else "small-label"}">({a},{b},{c})</text>\n'
    
    # Legend
    svg += '<text x="50" y="550" class="axis-label">Depth 0: root (3,4,5)</text>\n'
    svg += '<text x="50" y="570" class="axis-label">Each node has exactly 3 children via B₁, B₂, B₃</text>\n'
    svg += '<text x="50" y="590" class="axis-label">Every primitive Pythagorean triple appears at exactly one node</text>\n'
    
    svg += svg_footer()
    return svg

# ============================================================================
# Figure 2: Descent Path for N=77
# ============================================================================

def generate_descent_figure():
    """Visualize the descent path for factoring N=77."""
    width, height = 800, 500
    svg = svg_header(width, height)
    
    svg += '<text x="400" y="30" class="title" text-anchor="middle">Descent Path: Factoring N = 77 = 7 × 11</text>\n'
    svg += '<text x="400" y="50" class="subtitle" text-anchor="middle">Climbing from trivial triple to root, GCD reveals factors</text>\n'
    
    path = full_descent(77)
    
    # Layout descent as a horizontal chain
    n = len(path)
    x_start = 80
    x_end = 720
    y_center = 250
    
    for i, ((a, b, c), branch) in enumerate(path):
        x = x_start + i * (x_end - x_start) / max(1, n - 1)
        
        # Check if this triple reveals a factor
        ga = math.gcd(abs(a), 77)
        gb = math.gcd(abs(b), 77)
        reveals_factor = (1 < ga < 77) or (1 < gb < 77)
        
        # Draw edge to next
        if i < n - 1:
            x_next = x_start + (i+1) * (x_end - x_start) / max(1, n - 1)
            svg += f'<line x1="{x:.0f}" y1="{y_center}" x2="{x_next:.0f}" y2="{y_center}" class="descent-edge" marker-end="url(#arrowhead)"/>\n'
        
        # Node
        node_class = 'factor-node' if reveals_factor else ('node-root' if i == n-1 else 'descent-node')
        r = 20 if reveals_factor else 15
        svg += f'<circle cx="{x:.0f}" cy="{y_center}" r="{r}" class="{node_class}"/>\n'
        
        # Label
        svg += f'<text x="{x:.0f}" y="{y_center - 30}" class="small-label">d={i}</text>\n'
        svg += f'<text x="{x:.0f}" y="{y_center + 40}" class="small-label">({a},{b},{c})</text>\n'
        
        if reveals_factor:
            factor = ga if 1 < ga < 77 else gb
            svg += f'<text x="{x:.0f}" y="{y_center + 60}" class="label" fill="#e74c3c">gcd = {factor}!</text>\n'
    
    # Legend
    svg += '<rect x="50" y="380" width="15" height="15" class="descent-node"/>\n'
    svg += '<text x="75" y="393" class="axis-label">Descent step</text>\n'
    svg += '<rect x="200" y="380" width="15" height="15" class="factor-node"/>\n'
    svg += '<text x="225" y="393" class="axis-label">Factor revealed by GCD</text>\n'
    svg += '<rect x="400" y="380" width="15" height="15" class="node-root"/>\n'
    svg += '<text x="425" y="393" class="axis-label">Root (3,4,5)</text>\n'
    
    svg += '<text x="400" y="440" class="subtitle" text-anchor="middle">Direction of descent →</text>\n'
    svg += '<text x="400" y="470" class="subtitle" text-anchor="middle">Hypotenuse: {0} → ... → 5 (strictly decreasing)</text>\n'.format(path[0][0][2])
    
    svg += svg_footer()
    return svg

# ============================================================================
# Figure 3: Hypotenuse Decay
# ============================================================================

def generate_decay_figure():
    """Plot hypotenuse decay during descent for several N values."""
    width, height = 700, 450
    svg = svg_header(width, height)
    
    svg += '<text x="350" y="25" class="title" text-anchor="middle">Hypotenuse Decay During Descent</text>\n'
    svg += '<text x="350" y="45" class="subtitle" text-anchor="middle">Geometric decay rate ≈ (3 - 2√2) ≈ 0.172 per step</text>\n'
    
    margin_left, margin_bottom = 80, 50
    plot_w = width - margin_left - 50
    plot_h = height - 80 - margin_bottom
    
    # Axes
    svg += f'<line x1="{margin_left}" y1="{height - margin_bottom}" x2="{margin_left + plot_w}" y2="{height - margin_bottom}" stroke="#2c3e50" stroke-width="1.5"/>\n'
    svg += f'<line x1="{margin_left}" y1="{height - margin_bottom}" x2="{margin_left}" y2="60" stroke="#2c3e50" stroke-width="1.5"/>\n'
    
    svg += f'<text x="{margin_left + plot_w/2}" y="{height - 10}" class="axis-label" text-anchor="middle">Descent depth</text>\n'
    svg += f'<text x="15" y="{80 + plot_h/2}" class="axis-label" text-anchor="middle" transform="rotate(-90 15 {80 + plot_h/2})">log₁₀(hypotenuse)</text>\n'
    
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']
    test_Ns = [77, 143, 221, 667, 2537]
    
    max_depth = 0
    max_log_c = 0
    
    # First pass: find ranges
    all_paths = {}
    for N in test_Ns:
        path = full_descent(N)
        hyps = [c for ((a, b, c), _) in path]
        all_paths[N] = hyps
        max_depth = max(max_depth, len(hyps))
        max_log_c = max(max_log_c, math.log10(hyps[0]) if hyps[0] > 0 else 1)
    
    # Draw curves
    for idx, N in enumerate(test_Ns):
        hyps = all_paths[N]
        color = colors[idx % len(colors)]
        
        points = []
        for i, c in enumerate(hyps):
            if c <= 0:
                continue
            x = margin_left + (i / max(1, max_depth - 1)) * plot_w
            y = height - margin_bottom - (math.log10(c) / max_log_c) * plot_h
            points.append(f"{x:.1f},{y:.1f}")
        
        if points:
            svg += f'<polyline points="{" ".join(points)}" fill="none" stroke="{color}" stroke-width="2"/>\n'
            # Label
            last_x, last_y = points[-1].split(',')
            svg += f'<text x="{float(last_x) + 10}" y="{float(last_y) + 4}" class="small-label" fill="{color}" text-anchor="start">N={N}</text>\n'
    
    # Reference line: geometric decay
    ref_points = []
    for i in range(max_depth):
        c_ref = all_paths[2537][0] * (3 - 2*math.sqrt(2))**i
        if c_ref < 1:
            break
        x = margin_left + (i / max(1, max_depth - 1)) * plot_w
        y = height - margin_bottom - (math.log10(c_ref) / max_log_c) * plot_h
        ref_points.append(f"{x:.1f},{y:.1f}")
    
    if ref_points:
        svg += f'<polyline points="{" ".join(ref_points)}" fill="none" stroke="#95a5a6" stroke-width="1" stroke-dasharray="4,4"/>\n'
        svg += f'<text x="{margin_left + plot_w - 10}" y="75" class="small-label" fill="#95a5a6" text-anchor="end">slope = log(3-2√2)</text>\n'
    
    svg += svg_footer()
    return svg

# ============================================================================
# Figure 4: Depth vs min(p,q) Scatter Plot
# ============================================================================

def generate_scatter_figure():
    """Scatter plot of factoring depth vs min(p,q)."""
    width, height = 600, 500
    svg = svg_header(width, height)
    
    svg += '<text x="300" y="25" class="title" text-anchor="middle">Factoring Depth vs Smaller Prime Factor</text>\n'
    svg += '<text x="300" y="45" class="subtitle" text-anchor="middle">d* ≈ 0.85 · min(p, q)</text>\n'
    
    margin_left, margin_bottom = 70, 60
    plot_w = width - margin_left - 40
    plot_h = height - 80 - margin_bottom
    
    # Generate data
    def sieve(n):
        is_prime = [True] * (n + 1)
        is_prime[0] = is_prime[1] = False
        for i in range(2, int(n**0.5) + 1):
            if is_prime[i]:
                for j in range(i*i, n+1, i):
                    is_prime[j] = False
        return [i for i in range(2, n+1) if is_prime[i]]
    
    primes = [p for p in sieve(60) if p > 2]
    
    data_points = []
    for i, p in enumerate(primes):
        for q in primes[i+1:]:
            N = p * q
            path = full_descent(N)
            
            d_star = None
            for d, ((a, b, c), _) in enumerate(path):
                ga = math.gcd(abs(a), N)
                gb = math.gcd(abs(b), N)
                if (1 < ga < N) or (1 < gb < N):
                    d_star = d
                    break
            
            if d_star is not None:
                data_points.append((min(p, q), d_star))
    
    if not data_points:
        svg += svg_footer()
        return svg
    
    max_x = max(p[0] for p in data_points) * 1.1
    max_y = max(p[1] for p in data_points) * 1.1
    
    # Axes
    svg += f'<line x1="{margin_left}" y1="{height - margin_bottom}" x2="{margin_left + plot_w}" y2="{height - margin_bottom}" stroke="#2c3e50" stroke-width="1.5"/>\n'
    svg += f'<line x1="{margin_left}" y1="{height - margin_bottom}" x2="{margin_left}" y2="60" stroke="#2c3e50" stroke-width="1.5"/>\n'
    
    svg += f'<text x="{margin_left + plot_w/2}" y="{height - 15}" class="axis-label" text-anchor="middle">min(p, q)</text>\n'
    svg += f'<text x="15" y="{80 + plot_h/2}" class="axis-label" text-anchor="middle" transform="rotate(-90 15 {80 + plot_h/2})">Factoring depth d*</text>\n'
    
    # Reference line: d* = min(p,q)
    x0 = margin_left
    y0 = height - margin_bottom
    x1 = margin_left + plot_w
    y1 = height - margin_bottom - (max_x / max_y) * plot_h
    svg += f'<line x1="{x0}" y1="{y0}" x2="{x1}" y2="{y1}" stroke="#bdc3c7" stroke-width="1" stroke-dasharray="5,5"/>\n'
    svg += f'<text x="{x1 - 5}" y="{y1 - 5}" class="small-label" fill="#bdc3c7" text-anchor="end">d* = min(p,q)</text>\n'
    
    # Reference line: d* = 0.85 * min(p,q)
    y1_85 = height - margin_bottom - (0.85 * max_x / max_y) * plot_h
    svg += f'<line x1="{x0}" y1="{y0}" x2="{x1}" y2="{y1_85}" stroke="#3498db" stroke-width="1" stroke-dasharray="3,3"/>\n'
    svg += f'<text x="{x1 - 5}" y="{y1_85 + 15}" class="small-label" fill="#3498db" text-anchor="end">d* = 0.85·min(p,q)</text>\n'
    
    # Data points
    for px, py in data_points:
        x = margin_left + (px / max_x) * plot_w
        y = height - margin_bottom - (py / max_y) * plot_h
        svg += f'<circle cx="{x:.1f}" cy="{y:.1f}" r="3" fill="#e74c3c" opacity="0.6"/>\n'
    
    svg += svg_footer()
    return svg

# ============================================================================
# Figure 5: Klein Disk Geodesic
# ============================================================================

def generate_klein_disk_figure():
    """Trace the descent path in the Klein disk model of hyperbolic geometry."""
    width, height = 600, 600
    svg = svg_header(width, height)
    
    cx, cy = 300, 310
    radius = 250
    
    svg += '<text x="300" y="25" class="title" text-anchor="middle">Descent Geodesic in the Klein Disk</text>\n'
    svg += '<text x="300" y="45" class="subtitle" text-anchor="middle">Pythagorean triples as points on the light cone boundary</text>\n'
    
    # Draw the unit disk
    svg += f'<circle cx="{cx}" cy="{cy}" r="{radius}" fill="#f8f9fa" stroke="#2c3e50" stroke-width="2"/>\n'
    
    # Draw coordinate axes
    svg += f'<line x1="{cx - radius}" y1="{cy}" x2="{cx + radius}" y2="{cy}" stroke="#ecf0f1" stroke-width="0.5"/>\n'
    svg += f'<line x1="{cx}" y1="{cy - radius}" x2="{cx}" y2="{cy + radius}" stroke="#ecf0f1" stroke-width="0.5"/>\n'
    
    # Plot descent path for N = 77
    path = full_descent(77)
    
    klein_points = []
    for (a, b, c), branch in path:
        if c > 0:
            kx = a / c
            ky = b / c
            px = cx + kx * radius
            py = cy - ky * radius  # Flip y for SVG
            klein_points.append((px, py, a, b, c))
    
    # Draw path
    for i in range(len(klein_points) - 1):
        x1, y1 = klein_points[i][0], klein_points[i][1]
        x2, y2 = klein_points[i+1][0], klein_points[i+1][1]
        svg += f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="#e74c3c" stroke-width="1.5" opacity="0.7"/>\n'
    
    # Draw points
    for i, (px, py, a, b, c) in enumerate(klein_points):
        r = 5 if i == 0 or i == len(klein_points) - 1 else 3
        color = '#e74c3c' if i == 0 else ('#2ecc71' if i == len(klein_points)-1 else '#3498db')
        svg += f'<circle cx="{px:.1f}" cy="{py:.1f}" r="{r}" fill="{color}"/>\n'
    
    # Labels
    if klein_points:
        svg += f'<text x="{klein_points[0][0]:.0f}" y="{klein_points[0][1] - 10:.0f}" class="small-label" fill="#e74c3c">Start: ({klein_points[0][2]},{klein_points[0][3]},{klein_points[0][4]})</text>\n'
        svg += f'<text x="{klein_points[-1][0] + 10:.0f}" y="{klein_points[-1][1] + 15:.0f}" class="small-label" fill="#2ecc71">Root: (3,4,5)</text>\n'
    
    # Legend
    svg += f'<text x="50" y="{height - 20}" class="small-label" text-anchor="start">Klein model: (a/c, b/c) ∈ D² — all Pythagorean triples map to the unit disk boundary</text>\n'
    
    svg += svg_footer()
    return svg

# ============================================================================
# Figure 6: Branch Sequence Pattern
# ============================================================================

def generate_branch_pattern_figure():
    """Visualize branch sequence patterns across multiple N values."""
    width, height = 800, 400
    svg = svg_header(width, height)
    
    svg += '<text x="400" y="25" class="title" text-anchor="middle">Branch Sequence Patterns During Descent</text>\n'
    svg += '<text x="400" y="45" class="subtitle" text-anchor="middle">Colors: B₁⁻¹ (red), B₂⁻¹ (blue), B₃⁻¹ (green)</text>\n'
    
    test_Ns = [77, 91, 143, 221, 323, 437, 667, 899, 1073, 2537]
    
    margin_left = 80
    margin_top = 70
    row_height = 28
    cell_width = 12
    
    branch_colors = {1: '#e74c3c', 2: '#3498db', 3: '#2ecc71'}
    
    for idx, N in enumerate(test_Ns):
        y = margin_top + idx * row_height
        
        path = full_descent(N)
        branches = [p[1] for p in path[1:]]
        
        # Label
        svg += f'<text x="{margin_left - 10}" y="{y + 10}" class="small-label" text-anchor="end">N={N}</text>\n'
        
        # Branch cells
        for i, b in enumerate(branches[:50]):
            x = margin_left + i * cell_width
            color = branch_colors.get(b, '#95a5a6')
            svg += f'<rect x="{x}" y="{y}" width="{cell_width - 1}" height="{row_height - 4}" fill="{color}" rx="2"/>\n'
        
        if len(branches) > 50:
            x = margin_left + 50 * cell_width
            svg += f'<text x="{x + 5}" y="{y + 12}" class="small-label" text-anchor="start">+{len(branches)-50} more</text>\n'
    
    # Legend
    y_legend = margin_top + len(test_Ns) * row_height + 20
    for b, color, label in [(1, '#e74c3c', 'Branch 1 (B₁⁻¹)'), 
                             (2, '#3498db', 'Branch 2 (B₂⁻¹)'),
                             (3, '#2ecc71', 'Branch 3 (B₃⁻¹)')]:
        x = margin_left + (b - 1) * 200
        svg += f'<rect x="{x}" y="{y_legend}" width="15" height="15" fill="{color}" rx="2"/>\n'
        svg += f'<text x="{x + 22}" y="{y_legend + 12}" class="axis-label">{label}</text>\n'
    
    svg += svg_footer()
    return svg

# ============================================================================
# Main: Generate All Figures
# ============================================================================

def main():
    figures = {
        'fig1_berggren_tree.svg': generate_tree_figure,
        'fig2_descent_path.svg': generate_descent_figure,
        'fig3_hypotenuse_decay.svg': generate_decay_figure,
        'fig4_depth_scatter.svg': generate_scatter_figure,
        'fig5_klein_disk.svg': generate_klein_disk_figure,
        'fig6_branch_patterns.svg': generate_branch_pattern_figure,
    }
    
    for filename, generator in figures.items():
        print(f"Generating {filename}...")
        svg_content = generator()
        
        filepath = f"/workspace/request-project/Pythagorean/InverseTreeFactoring/Visuals/{filename}"
        with open(filepath, 'w') as f:
            f.write(svg_content)
        print(f"  → Saved to {filepath}")
    
    print(f"\nGenerated {len(figures)} figures.")


if __name__ == '__main__':
    main()
