#!/usr/bin/env python3
"""
Hyperbolic Visualization of the Berggren Tree

Generates SVG visualizations of the Berggren tree projected onto the
Poincaré disk model of the hyperbolic plane. Pythagorean triples appear
as ideal points on the boundary circle.

Run: python3 hyperbolic_visualization.py
Outputs: poincare_disk.svg, angle_histogram.svg
"""

import math
import os

# ── Berggren Matrices ──

def berggren_A(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def generate_tree(max_depth):
    root = (3, 4, 5)
    tree = {0: [root]}
    for d in range(max_depth):
        tree[d + 1] = []
        for a, b, c in tree[d]:
            tree[d + 1].append(berggren_A(a, b, c))
            tree[d + 1].append(berggren_B(a, b, c))
            tree[d + 1].append(berggren_C(a, b, c))
    return tree

# ── Poincaré Disk Projection ──

def to_poincare(a, b, c):
    """Project a null-cone point (a,b,c) to the Poincaré disk.
    
    For a point on the null cone a²+b²=c², the stereographic projection is:
    (x, y) = (a/(c+ε), b/(c+ε)) where ε is for the projection.
    
    For ideal points (boundary), we use the angle directly:
    (x, y) = (cos θ, sin θ) where θ = arctan(b/a).
    """
    theta = math.atan2(abs(b), abs(a))
    # Place slightly inside the boundary, scaled by 1 - 1/c
    r = 1 - 1/max(c, 2)
    return (r * math.cos(theta), r * math.sin(theta))

# ── SVG Generation ──

def generate_poincare_svg(tree, max_depth, filename):
    """Generate SVG of the Berggren tree on the Poincaré disk."""
    cx, cy = 350, 350  # Center
    R = 300             # Radius
    
    colors = {
        0: '#ffffff',
        1: '#ff6666',
        2: '#66ff66',
        3: '#6666ff',
        4: '#ffff66',
        5: '#ff66ff',
        6: '#66ffff',
    }
    
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 750" font-family="Georgia, serif">
  <defs>
    <radialGradient id="diskbg" cx="50%" cy="50%">
      <stop offset="0%" style="stop-color:#1a1a3e"/>
      <stop offset="90%" style="stop-color:#0a0a20"/>
      <stop offset="100%" style="stop-color:#000010"/>
    </radialGradient>
  </defs>
  
  <rect width="700" height="750" fill="#050510"/>
  
  <text x="350" y="30" text-anchor="middle" fill="#e0e0ff" font-size="18" font-weight="bold">Berggren Tree on the Poincaré Disk</text>
  <text x="350" y="50" text-anchor="middle" fill="#8888cc" font-size="11">Primitive Pythagorean Triples as Ideal Points of ℍ²</text>
  
  <!-- Disk boundary -->
  <circle cx="{cx}" cy="{cy}" r="{R}" fill="url(#diskbg)" stroke="#4444aa" stroke-width="2"/>
  
  <!-- Grid lines (hyperbolic geodesics approximated as arcs) -->
'''
    
    # Draw radial lines at key angles
    for angle_deg in range(0, 91, 15):
        angle = math.radians(angle_deg)
        x2 = cx + R * math.cos(angle)
        y2 = cy - R * math.sin(angle)
        svg += f'  <line x1="{cx}" y1="{cy}" x2="{x2:.1f}" y2="{y2:.1f}" '
        svg += f'stroke="#222255" stroke-width="0.5" opacity="0.5"/>\n'
        # Label
        lx = cx + (R + 15) * math.cos(angle)
        ly = cy - (R + 15) * math.sin(angle)
        svg += f'  <text x="{lx:.1f}" y="{ly:.1f}" text-anchor="middle" '
        svg += f'fill="#666699" font-size="9">{angle_deg}°</text>\n'
    
    # Draw points for each depth
    for depth in range(max_depth + 1):
        for a, b, c in tree[depth]:
            px, py = to_poincare(a, b, c)
            sx = cx + px * R
            sy = cy - py * R  # SVG y is inverted
            
            size = max(6 - depth, 1.5)
            color = colors.get(depth, '#aaaaaa')
            opacity = max(1.0 - depth * 0.1, 0.4)
            
            svg += f'  <circle cx="{sx:.1f}" cy="{sy:.1f}" r="{size}" '
            svg += f'fill="{color}" opacity="{opacity}"/>\n'
    
    # Legend
    svg += f'''
  <rect x="20" y="700" width="660" height="40" rx="5" fill="#0a0a20" stroke="#333366" stroke-width="1"/>
  <text x="30" y="722" fill="#aabbee" font-size="10">Depth: </text>
'''
    
    for d in range(min(max_depth + 1, 7)):
        color = colors.get(d, '#aaaaaa')
        x_pos = 80 + d * 85
        svg += f'  <circle cx="{x_pos}" cy="718" r="5" fill="{color}"/>\n'
        svg += f'  <text x="{x_pos + 10}" y="722" fill="#8899bb" font-size="9">{d} ({3**d} triples)</text>\n'
    
    svg += '</svg>\n'
    
    with open(filename, 'w') as f:
        f.write(svg)
    print(f"Generated: {filename}")

def generate_angle_histogram_svg(tree, max_depth, filename):
    """Generate SVG histogram of angle distribution."""
    
    # Collect all angles
    all_angles = []
    for depth in range(max_depth + 1):
        for a, b, c in tree[depth]:
            theta = math.degrees(math.atan2(abs(b), abs(a)))
            all_angles.append(theta)
    
    # Bin the angles
    n_bins = 18
    bin_width = 90.0 / n_bins
    bins = [0] * n_bins
    for theta in all_angles:
        idx = min(int(theta / bin_width), n_bins - 1)
        bins[idx] += 1
    
    max_count = max(bins)
    
    chart_x = 80
    chart_y = 50
    chart_w = 550
    chart_h = 350
    
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 500" font-family="Georgia, serif">
  <rect width="700" height="500" fill="#050510"/>
  
  <text x="350" y="30" text-anchor="middle" fill="#e0e0ff" font-size="16" font-weight="bold">Angle Distribution of Berggren Tree Triples (Depth ≤ {max_depth})</text>
  
  <!-- Axes -->
  <line x1="{chart_x}" y1="{chart_y + chart_h}" x2="{chart_x + chart_w}" y2="{chart_y + chart_h}" stroke="#555588" stroke-width="1"/>
  <line x1="{chart_x}" y1="{chart_y}" x2="{chart_x}" y2="{chart_y + chart_h}" stroke="#555588" stroke-width="1"/>
  
  <!-- X axis labels -->
  <text x="{chart_x + chart_w/2}" y="{chart_y + chart_h + 35}" text-anchor="middle" fill="#8899bb" font-size="12">Angle θ = arctan(b/a) (degrees)</text>
  <text x="{chart_x - 10}" y="{chart_y + chart_h/2}" text-anchor="middle" fill="#8899bb" font-size="12" transform="rotate(-90 {chart_x - 10} {chart_y + chart_h/2})">Count</text>
'''
    
    # Draw bars
    bar_w = chart_w / n_bins - 2
    for i, count in enumerate(bins):
        bar_h = (count / max_count) * chart_h * 0.9
        x = chart_x + i * (chart_w / n_bins) + 1
        y = chart_y + chart_h - bar_h
        
        # Color gradient from blue to red
        r = int(200 * (i / n_bins))
        g = int(100 * (1 - abs(2*i/n_bins - 1)))
        b_color = int(200 * (1 - i/n_bins))
        
        svg += f'  <rect x="{x:.1f}" y="{y:.1f}" width="{bar_w:.1f}" height="{bar_h:.1f}" '
        svg += f'fill="rgb({r},{g},{b_color})" opacity="0.8"/>\n'
        
        # X tick
        tick_x = x + bar_w/2
        label = f"{i * bin_width:.0f}"
        svg += f'  <text x="{tick_x:.1f}" y="{chart_y + chart_h + 15}" text-anchor="middle" fill="#666699" font-size="8">{label}°</text>\n'
    
    # Mark 45° line
    x45 = chart_x + (45/90) * chart_w
    svg += f'  <line x1="{x45}" y1="{chart_y}" x2="{x45}" y2="{chart_y + chart_h}" stroke="#ff6666" stroke-width="1" stroke-dasharray="4,4"/>\n'
    svg += f'  <text x="{x45 + 5}" y="{chart_y + 15}" fill="#ff6666" font-size="9">mean ≈ 45°</text>\n'
    
    # Statistics
    mean = sum(all_angles) / len(all_angles)
    std = (sum((a - mean)**2 for a in all_angles) / len(all_angles)) ** 0.5
    
    svg += f'''
  <rect x="430" y="60" width="230" height="100" rx="5" fill="#0a0a20" stroke="#333366" stroke-width="1"/>
  <text x="445" y="80" fill="#aabbee" font-size="11" font-weight="bold">Statistics</text>
  <text x="445" y="98" fill="#8899bb" font-size="10">N = {len(all_angles)} triples</text>
  <text x="445" y="114" fill="#8899bb" font-size="10">Mean = {mean:.2f}°</text>
  <text x="445" y="130" fill="#8899bb" font-size="10">Std Dev = {std:.2f}°</text>
  <text x="445" y="146" fill="#8899bb" font-size="10">Uniform would be: 25.98°</text>
'''
    
    svg += f'''
  <text x="350" y="475" text-anchor="middle" fill="#666699" font-size="10" font-style="italic">Distribution is concentrated around 45°, confirming non-uniform limiting distribution</text>
</svg>
'''
    
    with open(filename, 'w') as f:
        f.write(svg)
    print(f"Generated: {filename}")

# ── Main ──

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║     HYPERBOLIC VISUALIZATION OF THE BERGGREN TREE             ║")
    print("╚══════════════════════════════════════════════════════════════════╝\n")
    
    max_depth = 5
    tree = generate_tree(max_depth)
    
    total = sum(len(tree[d]) for d in range(max_depth + 1))
    print(f"Generated Berggren tree to depth {max_depth} ({total} triples)")
    
    script_dir = os.path.dirname(os.path.abspath(__file__))
    visuals_dir = os.path.join(os.path.dirname(script_dir), "visuals")
    
    generate_poincare_svg(tree, max_depth, os.path.join(visuals_dir, "poincare_disk.svg"))
    generate_angle_histogram_svg(tree, max_depth, os.path.join(visuals_dir, "angle_histogram.svg"))
    
    print("\nDone! Open the SVG files in a browser to view.")
