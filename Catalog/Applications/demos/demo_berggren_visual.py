#!/usr/bin/env python3
"""
Berggren Tree Visualization Demo

Generates an SVG visualization of Pythagorean triples on the unit circle,
showing how the Berggren tree maps to rational points on the circle via
stereographic projection.
"""

import math

def berggren_B1(t):
    a, b, c = t
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B2(t):
    a, b, c = t
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_B3(t):
    a, b, c = t
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def generate_triples(max_depth=5):
    """Generate all Berggren tree triples up to given depth."""
    root = (3, 4, 5)
    triples = [(root, 0, "root")]
    queue = [(root, 0)]

    while queue:
        t, depth = queue.pop(0)
        if depth >= max_depth:
            continue
        for name, op in [("B₁", berggren_B1), ("B₂", berggren_B2), ("B₃", berggren_B3)]:
            child = op(t)
            triples.append((child, depth + 1, name))
            queue.append((child, depth + 1))

    return triples

def triple_to_circle(triple):
    """Map (a, b, c) to point on unit circle: (a/c, b/c)"""
    a, b, c = triple
    return (a / c, b / c)

def generate_svg(triples, filename):
    """Generate SVG showing triples on the unit circle."""
    width, height = 800, 800
    cx, cy = width / 2, height / 2
    radius = 300

    colors_by_depth = [
        "#ff6b6b",  # depth 0 - red
        "#ffd93d",  # depth 1 - yellow
        "#4ecdc4",  # depth 2 - teal
        "#a29bfe",  # depth 3 - purple
        "#55efc4",  # depth 4 - green
        "#fd79a8",  # depth 5 - pink
    ]

    svg_parts = []
    svg_parts.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" font-family="Arial, sans-serif">')

    # Background
    svg_parts.append(f'<rect width="{width}" height="{height}" fill="#0a0a2e"/>')

    # Title
    svg_parts.append(f'<text x="{cx}" y="35" text-anchor="middle" fill="#fff" font-size="18" font-weight="bold">Pythagorean Triples on the Unit Circle</text>')
    svg_parts.append(f'<text x="{cx}" y="55" text-anchor="middle" fill="#aaa" font-size="12">Each point (a/c, b/c) satisfies a² + b² = c² (Berggren tree, {len(triples)} triples)</text>')

    # Unit circle
    svg_parts.append(f'<circle cx="{cx}" cy="{cy}" r="{radius}" fill="none" stroke="#333" stroke-width="1.5"/>')

    # Axes
    svg_parts.append(f'<line x1="{cx - radius - 20}" y1="{cy}" x2="{cx + radius + 20}" y2="{cy}" stroke="#333" stroke-width="0.5"/>')
    svg_parts.append(f'<line x1="{cx}" y1="{cy - radius - 20}" x2="{cx}" y2="{cy + radius + 20}" stroke="#333" stroke-width="0.5"/>')

    # Axis labels
    svg_parts.append(f'<text x="{cx + radius + 25}" y="{cy + 5}" fill="#666" font-size="12">a/c</text>')
    svg_parts.append(f'<text x="{cx + 5}" y="{cy - radius - 10}" fill="#666" font-size="12">b/c</text>')

    # Plot triples as points on the circle
    for triple, depth, name in triples:
        x_unit, y_unit = triple_to_circle(triple)
        x_px = cx + x_unit * radius
        y_px = cy - y_unit * radius  # flip y for SVG

        color = colors_by_depth[min(depth, len(colors_by_depth) - 1)]
        r = max(2, 6 - depth)

        svg_parts.append(f'<circle cx="{x_px:.1f}" cy="{y_px:.1f}" r="{r}" fill="{color}" opacity="0.8"/>')

        # Label some important triples
        if depth <= 1:
            a, b, c = triple
            label = f"({a},{b},{c})"
            svg_parts.append(f'<text x="{x_px + 10:.1f}" y="{y_px - 8:.1f}" fill="{color}" font-size="10">{label}</text>')

    # Legend
    ly = height - 140
    svg_parts.append(f'<rect x="20" y="{ly}" width="200" height="130" rx="8" fill="#0d0d3a" stroke="#444" stroke-width="1" opacity="0.9"/>')
    svg_parts.append(f'<text x="120" y="{ly + 20}" text-anchor="middle" fill="#fff" font-size="12" font-weight="bold">Legend</text>')
    for i, label in enumerate(["Root (3,4,5)", "Depth 1", "Depth 2", "Depth 3", "Depth 4", "Depth 5"]):
        color = colors_by_depth[i]
        svg_parts.append(f'<circle cx="40" cy="{ly + 38 + i * 16}" r="4" fill="{color}"/>')
        svg_parts.append(f'<text x="55" y="{ly + 42 + i * 16}" fill="{color}" font-size="10">{label}</text>')

    # Stats
    svg_parts.append(f'<text x="{cx}" y="{height - 15}" text-anchor="middle" fill="#888" font-size="11">')
    svg_parts.append(f'All {len(triples)} points satisfy a² + b² = c² — verified by Berggren tree completeness theorem</text>')

    svg_parts.append('</svg>')

    with open(filename, 'w') as f:
        f.write('\n'.join(svg_parts))

    return len(triples)

# Generate triples and SVG
print("Generating Berggren tree triples...")
triples = generate_triples(max_depth=5)
print(f"Generated {len(triples)} primitive Pythagorean triples")

# Verify all are valid
all_valid = True
for triple, depth, name in triples:
    a, b, c = triple
    if a*a + b*b != c*c:
        print(f"INVALID: {triple}")
        all_valid = False
print(f"All triples valid: {'✓' if all_valid else '✗'}")

# Generate SVG
svg_file = "../visuals/pythagorean_circle.svg"
n = generate_svg(triples, svg_file)
print(f"Generated SVG with {n} points: {svg_file}")

# Also show some statistics
print(f"\nTriple statistics:")
depths = {}
for _, depth, _ in triples:
    depths[depth] = depths.get(depth, 0) + 1
for d in sorted(depths.keys()):
    print(f"  Depth {d}: {depths[d]} triples")

# Verify Lorentz invariance for all triples
print(f"\nLorentz form x² + y² - z² for all triples:")
lorentz_values = set()
for triple, _, _ in triples:
    a, b, c = triple
    L = a**2 + b**2 - c**2
    lorentz_values.add(L)
print(f"  All Lorentz values: {lorentz_values}")
print(f"  All equal to 0: {'✓' if lorentz_values == {0} else '✗'}")
print(f"  (Formally verified: B₁, B₂, B₃ preserve Lorentz form)")
