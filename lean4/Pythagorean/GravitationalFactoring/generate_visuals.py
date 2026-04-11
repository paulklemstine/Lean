#!/usr/bin/env python3
"""
Generate SVG visualizations for Gravitational Factoring on Pythagorean Quadruple Trees.
"""

import math

def svg_header(width, height, title=""):
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}">
<defs>
  <style>
    .title {{ font: bold 20px sans-serif; fill: #1a1a2e; }}
    .subtitle {{ font: 14px sans-serif; fill: #16213e; }}
    .label {{ font: 11px monospace; fill: #333; }}
    .small {{ font: 9px sans-serif; fill: #666; }}
    .axis {{ stroke: #333; stroke-width: 1; }}
    .grid {{ stroke: #e0e0e0; stroke-width: 0.5; }}
    .node {{ stroke: #1a1a2e; stroke-width: 1.5; }}
    .edge {{ stroke: #4a4e69; stroke-width: 1; opacity: 0.6; }}
    .highlight {{ stroke: #e63946; stroke-width: 2; fill: #e63946; fill-opacity: 0.3; }}
    .factor {{ fill: #2a9d8f; stroke: #264653; stroke-width: 2; }}
    .energy-high {{ fill: #e76f51; }}
    .energy-mid {{ fill: #f4a261; }}
    .energy-low {{ fill: #2a9d8f; }}
  </style>
  <marker id="arrow" viewBox="0 0 10 10" refX="10" refY="5" markerWidth="6" markerHeight="6" orient="auto">
    <path d="M 0 0 L 10 5 L 0 10 z" fill="#4a4e69"/>
  </marker>
  <radialGradient id="glow" cx="50%" cy="50%" r="50%">
    <stop offset="0%" style="stop-color:#2a9d8f;stop-opacity:0.8"/>
    <stop offset="100%" style="stop-color:#264653;stop-opacity:0"/>
  </radialGradient>
</defs>
'''

def svg_footer():
    return '</svg>'

# ============================================================================
# VISUAL 1: The Pythagorean Quadruple Tree
# ============================================================================

def generate_quadruple_tree_svg():
    """Visualize the tree of Pythagorean quadruples rooted at (0,0,1,1)."""
    W, H = 1000, 700
    svg = svg_header(W, H, "Pythagorean Quadruple Tree")
    
    # Background
    svg += f'<rect width="{W}" height="{H}" fill="#faf9f6" rx="10"/>\n'
    svg += '<text x="500" y="35" text-anchor="middle" class="title">The Pythagorean Quadruple Tree</text>\n'
    svg += '<text x="500" y="55" text-anchor="middle" class="subtitle">a² + b² + c² = d²  |  Root: (0, 0, 1, 1)</text>\n'
    
    # Tree nodes (manually laid out for clarity)
    nodes = {
        (0,0,1,1): (500, 100),
        (1,2,2,3): (300, 200),
        (2,3,6,7): (500, 200),
        (0,0,2,2): (700, 200),
        (1,4,8,9): (150, 310),
        (4,4,7,9): (350, 310),
        (2,6,9,11): (500, 310),
        (6,6,7,11): (650, 310),
        (0,3,4,5): (200, 200),
        (2,4,4,6): (800, 310),
        (1,2,14,15): (100, 420),
        (2,10,11,15): (250, 420),
        (3,6,14,15): (400, 420), # Not actually valid but shows the tree
        (4,6,12,14): (550, 420),
        (1,6,18,19): (700, 420),
    }
    
    # Edges (parent → child relationships)
    edges = [
        ((0,0,1,1), (1,2,2,3)),
        ((0,0,1,1), (2,3,6,7)),
        ((0,0,1,1), (0,0,2,2)),
        ((0,0,1,1), (0,3,4,5)),
        ((1,2,2,3), (1,4,8,9)),
        ((1,2,2,3), (4,4,7,9)),
        ((2,3,6,7), (2,6,9,11)),
        ((2,3,6,7), (6,6,7,11)),
        ((0,0,2,2), (2,4,4,6)),
        ((1,4,8,9), (1,2,14,15)),
        ((1,4,8,9), (2,10,11,15)),
        ((4,4,7,9), (3,6,14,15)),
        ((2,6,9,11), (4,6,12,14)),
        ((6,6,7,11), (1,6,18,19)),
    ]
    
    # Draw edges
    for (p, c) in edges:
        if p in nodes and c in nodes:
            x1, y1 = nodes[p]
            x2, y2 = nodes[c]
            svg += f'<line x1="{x1}" y1="{y1+15}" x2="{x2}" y2="{y2-15}" class="edge"/>\n'
    
    # Draw nodes
    for (a,b,c,d), (x, y) in nodes.items():
        # Check if valid quadruple
        valid = a*a + b*b + c*c == d*d
        color = "#2a9d8f" if valid else "#e76f51"
        r = 18 if (a,b,c,d) == (0,0,1,1) else 14
        
        svg += f'<circle cx="{x}" cy="{y}" r="{r}" fill="{color}" class="node" fill-opacity="0.8"/>\n'
        svg += f'<text x="{x}" y="{y+4}" text-anchor="middle" class="small" fill="white" font-weight="bold">({a},{b},{c},{d})</text>\n'
        svg += f'<text x="{x}" y="{y+r+12}" text-anchor="middle" class="small">d={d}</text>\n'
    
    # Legend
    svg += '<rect x="30" y="530" width="250" height="130" fill="white" stroke="#ccc" rx="5"/>\n'
    svg += '<text x="45" y="555" class="subtitle" font-weight="bold">Legend</text>\n'
    svg += '<circle cx="55" cy="575" r="8" fill="#2a9d8f"/>\n'
    svg += '<text x="70" y="579" class="label">Valid quadruple (a²+b²+c²=d²)</text>\n'
    svg += '<circle cx="55" cy="600" r="8" fill="#e76f51"/>\n'
    svg += '<text x="70" y="604" class="label">Invalid / approximate</text>\n'
    svg += '<text x="45" y="630" class="small">Each node has multiple children</text>\n'
    svg += '<text x="45" y="645" class="small">Hypotenuse d increases down the tree</text>\n'
    
    # Gravity arrow
    svg += '<text x="920" y="150" text-anchor="middle" class="subtitle" fill="#e63946">↑ Gravity</text>\n'
    svg += '<text x="920" y="170" text-anchor="middle" class="small">(toward root)</text>\n'
    svg += '<line x1="920" y1="400" x2="920" y2="180" stroke="#e63946" stroke-width="2" marker-end="url(#arrow)"/>\n'
    svg += '<text x="920" y="420" text-anchor="middle" class="small">↓ Energy</text>\n'
    svg += '<text x="920" y="435" text-anchor="middle" class="small">(tree expansion)</text>\n'
    
    svg += svg_footer()
    return svg

# ============================================================================
# VISUAL 2: Peel Channel Diagram
# ============================================================================

def generate_peel_channels_svg():
    """Visualize the three peel channels for a quadruple."""
    W, H = 900, 600
    svg = svg_header(W, H)
    svg += f'<rect width="{W}" height="{H}" fill="#faf9f6" rx="10"/>\n'
    svg += '<text x="450" y="35" text-anchor="middle" class="title">Peel Channels: Factor Extraction</text>\n'
    svg += '<text x="450" y="55" text-anchor="middle" class="subtitle">a² + b² + c² = d²  →  (d-x)(d+x) = sum of remaining squares</text>\n'
    
    # Central quadruple
    cx, cy = 450, 200
    svg += f'<circle cx="{cx}" cy="{cy}" r="50" fill="#264653" fill-opacity="0.8"/>\n'
    svg += f'<text x="{cx}" y="{cy-5}" text-anchor="middle" fill="white" font-size="16" font-weight="bold">(a,b,c,d)</text>\n'
    svg += f'<text x="{cx}" y="{cy+15}" text-anchor="middle" fill="#a8dadc" font-size="12">a²+b²+c²=d²</text>\n'
    
    # Three peel channels
    channels = [
        ("Channel A", 150, 400, "d-a", "d+a", "b²+c²", "#e63946"),
        ("Channel B", 450, 400, "d-b", "d+b", "a²+c²", "#457b9d"),
        ("Channel C", 750, 400, "d-c", "d+c", "a²+b²", "#2a9d8f"),
    ]
    
    for name, x, y, minus, plus, result, color in channels:
        # Arrow from center
        svg += f'<line x1="{cx}" y1="{cy+50}" x2="{x}" y2="{y-60}" stroke="{color}" stroke-width="2" stroke-dasharray="5,5"/>\n'
        
        # Channel box
        svg += f'<rect x="{x-100}" y="{y-50}" width="200" height="120" fill="{color}" fill-opacity="0.1" stroke="{color}" stroke-width="2" rx="10"/>\n'
        svg += f'<text x="{x}" y="{y-30}" text-anchor="middle" font-weight="bold" fill="{color}" font-size="14">{name}</text>\n'
        svg += f'<text x="{x}" y="{y}" text-anchor="middle" class="label">({minus})({plus}) = {result}</text>\n'
        svg += f'<text x="{x}" y="{y+25}" text-anchor="middle" class="small">gcd({minus}, N) → factor?</text>\n'
        svg += f'<text x="{x}" y="{y+45}" text-anchor="middle" class="small">gcd({plus}, N) → factor?</text>\n'
    
    # GCD extraction annotation
    svg += '<rect x="50" y="510" width="800" height="60" fill="#f1faee" stroke="#a8dadc" rx="5"/>\n'
    svg += '<text x="450" y="535" text-anchor="middle" class="subtitle" fill="#1d3557">For N = p·q: If any gcd(d±x, N) ∈ {p, q}, factoring succeeds!</text>\n'
    svg += '<text x="450" y="555" text-anchor="middle" class="small">3 channels × 2 GCDs each = 6 independent factor extraction attempts per quadruple</text>\n'
    
    svg += svg_footer()
    return svg

# ============================================================================
# VISUAL 3: Dimensional Hierarchy
# ============================================================================

def generate_dimensional_hierarchy_svg():
    """Visualize how factoring power grows with dimension."""
    W, H = 1000, 650
    svg = svg_header(W, H)
    svg += f'<rect width="{W}" height="{H}" fill="#faf9f6" rx="10"/>\n'
    svg += '<text x="500" y="35" text-anchor="middle" class="title">Dimensional Hierarchy of Factoring Power</text>\n'
    svg += '<text x="500" y="55" text-anchor="middle" class="subtitle">k-tuples: x₁² + x₂² + ... + xₖ = d²  |  Channels = k + C(k,2) = k(k+1)/2</text>\n'
    
    # Bar chart data
    dims = list(range(2, 13))
    channels = [k + k*(k-1)//2 for k in dims]
    max_ch = max(channels)
    
    # Chart area
    chart_x, chart_y = 100, 90
    chart_w, chart_h = 800, 380
    
    # Grid
    for i in range(0, max_ch + 10, 10):
        y = chart_y + chart_h - (i / max_ch * chart_h)
        svg += f'<line x1="{chart_x}" y1="{y}" x2="{chart_x + chart_w}" y2="{y}" class="grid"/>\n'
        svg += f'<text x="{chart_x - 10}" y="{y + 4}" text-anchor="end" class="small">{i}</text>\n'
    
    # Bars
    bar_w = chart_w / len(dims) * 0.7
    gap = chart_w / len(dims) * 0.3
    
    special_dims = {2: "ℂ", 4: "ℍ", 8: "𝕆"}
    
    for idx, (k, ch) in enumerate(zip(dims, channels)):
        x = chart_x + idx * (bar_w + gap) + gap/2
        bar_h = ch / max_ch * chart_h
        y = chart_y + chart_h - bar_h
        
        # Color based on division algebra connection
        if k in special_dims:
            color = "#e63946"
            opacity = "0.9"
        else:
            color = "#457b9d"
            opacity = "0.7"
        
        svg += f'<rect x="{x}" y="{y}" width="{bar_w}" height="{bar_h}" fill="{color}" fill-opacity="{opacity}" rx="3"/>\n'
        svg += f'<text x="{x + bar_w/2}" y="{y - 8}" text-anchor="middle" class="label" font-weight="bold">{ch}</text>\n'
        svg += f'<text x="{x + bar_w/2}" y="{chart_y + chart_h + 15}" text-anchor="middle" class="label">k={k}</text>\n'
        
        if k in special_dims:
            svg += f'<text x="{x + bar_w/2}" y="{chart_y + chart_h + 30}" text-anchor="middle" class="small" fill="#e63946" font-weight="bold">{special_dims[k]}</text>\n'
    
    # Axis labels
    svg += f'<text x="{chart_x + chart_w/2}" y="{chart_y + chart_h + 50}" text-anchor="middle" class="subtitle">Dimension k</text>\n'
    svg += f'<text x="30" y="{chart_y + chart_h/2}" text-anchor="middle" class="subtitle" transform="rotate(-90, 30, {chart_y + chart_h/2})">Factoring Channels</text>\n'
    
    # Annotations
    svg += '<rect x="100" y="530" width="800" height="90" fill="white" stroke="#ccc" rx="5"/>\n'
    svg += '<text x="500" y="555" text-anchor="middle" class="subtitle" fill="#1d3557">Division Algebra Dimensions (k = 2, 4, 8) have multiplicative norm identities</text>\n'
    svg += '<circle cx="130" cy="580" r="6" fill="#e63946"/>\n'
    svg += '<text x="145" y="584" class="label">Cayley-Dickson dimensions (ℂ, ℍ, 𝕆): norm is multiplicative → direct factoring</text>\n'
    svg += '<circle cx="130" cy="600" r="6" fill="#457b9d"/>\n'
    svg += '<text x="145" y="604" class="label">Other dimensions: GCD cascade only (no norm multiplicativity)</text>\n'
    
    svg += svg_footer()
    return svg

# ============================================================================
# VISUAL 4: Energy Landscape
# ============================================================================

def generate_energy_landscape_svg():
    """Visualize the factoring energy landscape."""
    W, H = 900, 600
    svg = svg_header(W, H)
    svg += f'<rect width="{W}" height="{H}" fill="#1a1a2e" rx="10"/>\n'
    svg += '<text x="450" y="35" text-anchor="middle" class="title" fill="#e0e0e0">Factoring Energy Landscape</text>\n'
    svg += '<text x="450" y="55" text-anchor="middle" class="subtitle" fill="#a0a0c0">Energy E = 0 at valid factoring quadruples | N = p × q</text>\n'
    
    # Energy surface (stylized contour plot)
    # Concentric ellipses representing energy levels
    cx, cy = 450, 320
    
    for level in range(20, 0, -1):
        rx = level * 20
        ry = level * 12
        opacity = 0.05 + (20 - level) * 0.04
        color_val = min(255, int(50 + level * 10))
        svg += f'<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="none" stroke="rgb({color_val}, {100}, {255 - color_val})" stroke-width="1" opacity="{opacity}"/>\n'
    
    # Factor points (energy minima)
    factor_points = [
        (cx - 120, cy - 40, "p divides (d-a)"),
        (cx + 150, cy + 30, "q divides (d-b)"),
        (cx - 50, cy + 60, "p divides (d-c)"),
    ]
    
    for fx, fy, label in factor_points:
        svg += f'<circle cx="{fx}" cy="{fy}" r="30" fill="url(#glow)"/>\n'
        svg += f'<circle cx="{fx}" cy="{fy}" r="6" fill="#2a9d8f" stroke="#fff" stroke-width="1.5"/>\n'
        svg += f'<text x="{fx}" y="{fy + 22}" text-anchor="middle" fill="#a8dadc" font-size="9">{label}</text>\n'
    
    # Trajectory (gravitational descent)
    trajectory = [
        (100, 120), (180, 150), (250, 180), (300, 220), 
        (320, 260), (cx - 120, cy - 40)
    ]
    for i in range(len(trajectory) - 1):
        x1, y1 = trajectory[i]
        x2, y2 = trajectory[i+1]
        svg += f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="#e63946" stroke-width="2" stroke-dasharray="4,2"/>\n'
    svg += f'<circle cx="{trajectory[0][0]}" cy="{trajectory[0][1]}" r="5" fill="#e63946"/>\n'
    svg += f'<text x="{trajectory[0][0]+10}" y="{trajectory[0][1]-5}" fill="#e63946" font-size="10">Start</text>\n'
    svg += f'<text x="{trajectory[-1][0]+15}" y="{trajectory[-1][1]-5}" fill="#2a9d8f" font-size="10" font-weight="bold">Factor found!</text>\n'
    
    # Labels
    svg += '<text x="450" y="530" text-anchor="middle" fill="#a0a0c0" font-size="12">Gravitational descent follows the gradient of the energy surface</text>\n'
    svg += '<text x="450" y="550" text-anchor="middle" fill="#a0a0c0" font-size="12">toward minima where gcd(d-x, N) reveals a nontrivial factor</text>\n'
    
    # Legend
    svg += '<rect x="30" y="80" width="200" height="80" fill="rgba(255,255,255,0.1)" rx="5"/>\n'
    svg += '<circle cx="50" cy="100" r="5" fill="#e63946"/>\n'
    svg += '<text x="62" y="104" fill="#ddd" font-size="10">Descent trajectory</text>\n'
    svg += '<circle cx="50" cy="125" r="5" fill="#2a9d8f"/>\n'
    svg += '<text x="62" y="129" fill="#ddd" font-size="10">Energy minimum (factor)</text>\n'
    svg += '<text x="50" y="150" fill="#888" font-size="9">Contours: energy levels</text>\n'
    
    svg += svg_footer()
    return svg

# ============================================================================
# VISUAL 5: Quaternion Norm Factoring Diagram
# ============================================================================

def generate_quaternion_factoring_svg():
    """Visualize quaternion norm factoring."""
    W, H = 1000, 550
    svg = svg_header(W, H)
    svg += f'<rect width="{W}" height="{H}" fill="#faf9f6" rx="10"/>\n'
    svg += '<text x="500" y="35" text-anchor="middle" class="title">Quaternion Norm Factoring</text>\n'
    svg += '<text x="500" y="55" text-anchor="middle" class="subtitle">N = p·q  →  q₁·q₂ = Q  where |q₁|²=p, |q₂|²=q, |Q|²=N</text>\n'
    
    # Three boxes: p, q, N
    boxes = [
        (150, 150, "p", "#e63946", "Prime factor", "q₁ = a₁+b₁i+c₁j+d₁k", "|q₁|² = a₁²+b₁²+c₁²+d₁² = p"),
        (500, 150, "q", "#457b9d", "Prime factor", "q₂ = a₂+b₂i+c₂j+d₂k", "|q₂|² = a₂²+b₂²+c₂²+d₂² = q"),
        (850, 150, "N=p·q", "#2a9d8f", "Semiprime", "Q = q₁·q₂", "|Q|² = |q₁|²·|q₂|² = N"),
    ]
    
    for x, y, label, color, desc, quat, norm in boxes:
        svg += f'<rect x="{x-100}" y="{y-40}" width="200" height="100" fill="{color}" fill-opacity="0.15" stroke="{color}" stroke-width="2" rx="10"/>\n'
        svg += f'<text x="{x}" y="{y-15}" text-anchor="middle" font-size="22" font-weight="bold" fill="{color}">{label}</text>\n'
        svg += f'<text x="{x}" y="{y+10}" text-anchor="middle" class="small">{quat}</text>\n'
        svg += f'<text x="{x}" y="{y+30}" text-anchor="middle" class="small">{norm}</text>\n'
        svg += f'<text x="{x}" y="{y+50}" text-anchor="middle" class="small" fill="#888">{desc}</text>\n'
    
    # Multiplication arrows
    svg += '<text x="325" y="150" text-anchor="middle" font-size="24" fill="#333">×</text>\n'
    svg += '<text x="675" y="150" text-anchor="middle" font-size="24" fill="#333">=</text>\n'
    
    # Euler four-square identity box
    svg += '<rect x="50" y="290" width="900" height="100" fill="#f1faee" stroke="#264653" stroke-width="1" rx="8"/>\n'
    svg += '<text x="500" y="315" text-anchor="middle" font-weight="bold" fill="#264653" font-size="14">Euler Four-Square Identity (1748)</text>\n'
    svg += '<text x="500" y="340" text-anchor="middle" class="label">(a₁²+b₁²+c₁²+d₁²)(a₂²+b₂²+c₂²+d₂²) = A² + B² + C² + D²</text>\n'
    svg += '<text x="500" y="365" text-anchor="middle" class="small">where A,B,C,D are explicit bilinear combinations of the components</text>\n'
    svg += '<text x="500" y="380" text-anchor="middle" class="small" fill="#e63946">→ gcd(A, N), gcd(B, N), gcd(A±B, N), ... each may reveal p or q</text>\n'
    
    # Key insight
    svg += '<rect x="50" y="410" width="900" height="110" fill="#264653" fill-opacity="0.05" stroke="#264653" rx="8"/>\n'
    svg += '<text x="500" y="440" text-anchor="middle" font-weight="bold" fill="#264653" font-size="14">Key Insight: The Factoring Reverse Problem</text>\n'
    svg += '<text x="500" y="465" text-anchor="middle" class="label" fill="#333">Given N = A² + B² + C² + D² (by Lagrange\'s theorem), find q₁, q₂ such that q₁·q₂ = Q.</text>\n'
    svg += '<text x="500" y="485" text-anchor="middle" class="label" fill="#333">This is equivalent to factoring N, but in the quaternion algebra ℍ(ℤ).</text>\n'
    svg += '<text x="500" y="505" text-anchor="middle" class="small" fill="#e63946">The Pythagorean quadruple tree provides a structured search space for this decomposition!</text>\n'
    
    svg += svg_footer()
    return svg

# ============================================================================
# VISUAL 6: Cross-Collision Diagram  
# ============================================================================

def generate_cross_collision_svg():
    """Visualize shared-hypotenuse cross-collision factoring."""
    W, H = 900, 550
    svg = svg_header(W, H)
    svg += f'<rect width="{W}" height="{H}" fill="#faf9f6" rx="10"/>\n'
    svg += '<text x="450" y="35" text-anchor="middle" class="title">Cross-Collision Factoring</text>\n'
    svg += '<text x="450" y="55" text-anchor="middle" class="subtitle">Two representations with shared hypotenuse d reveal factors</text>\n'
    
    # Sphere
    cx, cy, r = 450, 280, 150
    svg += f'<ellipse cx="{cx}" cy="{cy}" rx="{r}" ry="{r*0.4}" fill="none" stroke="#264653" stroke-width="1" stroke-dasharray="5,5"/>\n'
    svg += f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="#264653" stroke-width="2"/>\n'
    svg += f'<text x="{cx}" y="{cy}" text-anchor="middle" fill="#264653" font-size="18" opacity="0.3">S²(d)</text>\n'
    
    # Two points on the sphere
    angle1 = -0.8
    angle2 = 0.5
    px1 = cx + int(r * math.cos(angle1))
    py1 = cy + int(r * math.sin(angle1))
    px2 = cx + int(r * math.cos(angle2))
    py2 = cy + int(r * math.sin(angle2))
    
    svg += f'<circle cx="{px1}" cy="{py1}" r="8" fill="#e63946"/>\n'
    svg += f'<text x="{px1-15}" y="{py1-15}" fill="#e63946" font-size="12" font-weight="bold">(a₁,b₁,c₁)</text>\n'
    svg += f'<text x="{px1-15}" y="{py1+20}" fill="#e63946" font-size="10">a₁²+b₁²+c₁²=d²</text>\n'
    
    svg += f'<circle cx="{px2}" cy="{py2}" r="8" fill="#457b9d"/>\n'
    svg += f'<text x="{px2+15}" y="{py2-15}" fill="#457b9d" font-size="12" font-weight="bold">(a₂,b₂,c₂)</text>\n'
    svg += f'<text x="{px2+15}" y="{py2+20}" fill="#457b9d" font-size="10">a₂²+b₂²+c₂²=d²</text>\n'
    
    # Connection line
    svg += f'<line x1="{px1}" y1="{py1}" x2="{px2}" y2="{py2}" stroke="#2a9d8f" stroke-width="2" stroke-dasharray="4,3"/>\n'
    mid_x, mid_y = (px1+px2)//2, (py1+py2)//2
    svg += f'<text x="{mid_x}" y="{mid_y-10}" text-anchor="middle" fill="#2a9d8f" font-size="11" font-weight="bold">Cross-collision!</text>\n'
    
    # Equations
    svg += '<rect x="50" y="460" width="800" height="70" fill="#f1faee" stroke="#a8dadc" rx="5"/>\n'
    svg += '<text x="450" y="485" text-anchor="middle" class="label">a₁²−a₂² = (a₁−a₂)(a₁+a₂)  and  (b₂²−b₁²) + (c₂²−c₁²) = a₁²−a₂²</text>\n'
    svg += '<text x="450" y="510" text-anchor="middle" class="small" fill="#e63946">→ gcd(a₁−a₂, N) and gcd(a₁+a₂, N) are candidate factors of N</text>\n'
    
    svg += svg_footer()
    return svg

# ============================================================================
# MAIN: Generate all visuals
# ============================================================================

if __name__ == "__main__":
    visuals = [
        ("quadruple_tree.svg", generate_quadruple_tree_svg),
        ("peel_channels.svg", generate_peel_channels_svg),
        ("dimensional_hierarchy.svg", generate_dimensional_hierarchy_svg),
        ("energy_landscape.svg", generate_energy_landscape_svg),
        ("quaternion_factoring.svg", generate_quaternion_factoring_svg),
        ("cross_collision.svg", generate_cross_collision_svg),
    ]
    
    for filename, generator in visuals:
        svg_content = generator()
        filepath = f"visuals/{filename}"
        import os
        os.makedirs("visuals", exist_ok=True)
        with open(filepath, 'w') as f:
            f.write(svg_content)
        print(f"Generated {filepath} ({len(svg_content)} bytes)")
    
    print("\nAll visuals generated successfully!")
