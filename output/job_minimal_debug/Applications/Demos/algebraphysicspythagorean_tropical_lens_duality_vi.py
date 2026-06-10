#!/usr/bin/env python3
"""Build PACKAGE.json from all deliverables."""
import json

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
lean_code = read_file('Bridges/AlgebraPhysicsPythagorean/TropicalLensBerggrenDuality.lean')
tree_svg = read_file('berggren_tree.svg')

package = {
    "title": "Tropical Lens–Berggren Duality: Factor Reconstruction via Min-Plus Inverse Geometry on Arithmetic Trees",
    "domain": "Tropical Geometry × Number Theory × Inverse Problems",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Tropical Lens Transform Demonstrations",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "Tropical Lens Transform",
            "pseudocode": """Algorithm: ComputeLensTransform(Sys, S)
Input: System Sys with n nodes, source weighting S
Output: Delay profile d : Node → ℕ

for each observer o in Sys.observers:
    d[o] ← ∞
    for each source node s:
        d[o] ← min(d[o], S[s] + edgeCost[s][o])
return d

Time: O(n × |observers|)
Space: O(n)""",
            "code": """def lens_transform(source, edge_cost):
    import numpy as np
    n = len(source)
    delay = np.full(n, np.inf)
    for o in range(n):
        for s in range(n):
            cost = source[s] + edge_cost[s, o]
            delay[o] = min(delay[o], cost)
    return delay.astype(int)

# Example
import numpy as np
source = np.array([7, 13, 3, 22])
M = 1000
cost = np.full((4, 4), M)
np.fill_diagonal(cost, 0)
print("Source:", source)
print("Delay:", lens_transform(source, cost))
"""
        },
        {
            "name": "Myhill–Nerode Quotient Computation",
            "pseudocode": """Algorithm: MyhillNerodeQuotient(edgeCost)
Input: Edge cost matrix of size n×n
Output: Equivalence classes of nodes

classes ← empty dictionary
for each node i in 0..n-1:
    profile ← edgeCost[i, :]
    if profile not in classes:
        classes[profile] ← new class
    add i to classes[profile]
return classes

Time: O(n²)
Space: O(n²)""",
            "code": """def myhill_nerode_quotient(edge_cost):
    import numpy as np
    n = len(edge_cost)
    classes = {}
    for i in range(n):
        profile = tuple(edge_cost[i])
        if profile not in classes:
            classes[profile] = []
        classes[profile].append(i)
    return classes

# Example
import numpy as np
edge_cost = np.array([
    [0, 1, 2, 3, 1, 2],
    [1, 0, 1, 2, 0, 1],
    [2, 1, 0, 1, 1, 0],
    [3, 2, 1, 0, 2, 1],
    [1, 0, 1, 2, 0, 1],
    [2, 1, 0, 1, 1, 0],
])
classes = myhill_nerode_quotient(edge_cost)
for k, (profile, nodes) in enumerate(classes.items()):
    print(f"Class {k}: nodes {nodes}")
print(f"|Quotient| = {len(classes)} <= |Node| = {len(edge_cost)}")
"""
        }
    ],
    "visualizations": [
        {
            "name": "Berggren Tree with Tropical Lens Signals",
            "data": tree_svg
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json created successfully.")
print(f"  Size: {len(json.dumps(package)):,} bytes")


#!/usr/bin/env python3
"""
Tropical Lens–Berggren Duality: Demo and Visualization

Demonstrates the main mathematical concepts:
1. Min-plus (tropical) lens transform on finite graphs
2. Direct-observation systems and source recovery
3. Pythagorean shell arithmetic content
4. Factor-sensitive encoding and delay separation
"""

import numpy as np
from typing import List, Tuple, Dict
import json


# ═══════════════════════════════════════════════════════════════════════════════
# §1. TROPICAL LENS TRANSFORM
# ═══════════════════════════════════════════════════════════════════════════════

def lens_transform(source: np.ndarray, edge_cost: np.ndarray) -> np.ndarray:
    """
    Compute the tropical (min-plus) lens transform.
    
    For each observer o:
        delay[o] = min_s (source[s] + edge_cost[s, o])
    
    Args:
        source: Array of source weights, shape (n,)
        edge_cost: Edge cost matrix, shape (n, n)
    
    Returns:
        Delay profile, shape (n,)
    """
    n = len(source)
    delay = np.full(n, np.inf)
    for o in range(n):
        for s in range(n):
            cost = source[s] + edge_cost[s, o]
            delay[o] = min(delay[o], cost)
    return delay.astype(int)


def direct_obs_edge_cost(n: int, M: int) -> np.ndarray:
    """
    Edge cost matrix for a direct-observation system.
    Diagonal = 0, off-diagonal = M.
    """
    cost = np.full((n, n), M)
    np.fill_diagonal(cost, 0)
    return cost


# ═══════════════════════════════════════════════════════════════════════════════
# §2. DEMOS
# ═══════════════════════════════════════════════════════════════════════════════

def demo_direct_observation():
    """
    Demo 1: Direct-observation system.
    Shows that with large M, the lens transform reads source weights exactly.
    """
    print("=" * 70)
    print("DEMO 1: Direct-Observation System")
    print("=" * 70)
    
    n = 4
    M = 1000
    source = np.array([7, 13, 3, 22])
    cost = direct_obs_edge_cost(n, M)
    
    delay = lens_transform(source, cost)
    
    print(f"Nodes: {n}, M = {M}")
    print(f"Source weights: {source}")
    print(f"Delay profile:  {delay}")
    print(f"Source == Delay: {np.array_equal(source, delay)}")
    print()
    
    # Show what happens with small M (separation fails)
    M_small = 5
    cost_small = direct_obs_edge_cost(n, M_small)
    
    source1 = np.array([7, 13, 3, 22])
    source2 = np.array([7, 13, 3, 8])  # Different last component
    
    delay1 = lens_transform(source1, cost_small)
    delay2 = lens_transform(source2, cost_small)
    
    print(f"With M = {M_small} (too small):")
    print(f"Source 1: {source1} → Delay: {delay1}")
    print(f"Source 2: {source2} → Delay: {delay2}")
    print(f"Delays equal despite different sources: {np.array_equal(delay1, delay2)}")
    print()


def demo_pythagorean_shell():
    """
    Demo 2: Pythagorean shell on a 4-node system.
    Assigns Pythagorean triples to nodes and computes delay profiles.
    """
    print("=" * 70)
    print("DEMO 2: Pythagorean Shell Arithmetic Content")
    print("=" * 70)
    
    # Four primitive Pythagorean triples from the Berggren tree
    triples = [
        (3, 4, 5),     # Root
        (5, 12, 13),   # Child A
        (21, 20, 29),  # Child B
        (15, 8, 17),   # Child C
    ]
    
    n = len(triples)
    a_vals = np.array([t[0] for t in triples])  # Leg a
    c_vals = np.array([t[2] for t in triples])  # Hypotenuse c
    
    # Edge costs = |c_s - c_o|
    edge_cost = np.abs(c_vals[:, None] - c_vals[None, :])
    
    # Source weights = leg a
    delay = lens_transform(a_vals, edge_cost)
    
    print("Triples (a, b, c):", triples)
    print(f"Source weights (leg a): {a_vals}")
    print(f"Hypotenuses:           {c_vals}")
    print(f"Edge cost matrix (|c_s - c_o|):")
    print(edge_cost)
    print(f"Delay profile: {delay}")
    print()
    
    # Verify the delay profile manually
    for o in range(n):
        terms = [a_vals[s] + abs(c_vals[s] - c_vals[o]) for s in range(n)]
        print(f"  Observer {o} (triple {triples[o]}): "
              f"terms = {terms}, min = {min(terms)}")
    print()


def demo_factor_encoding():
    """
    Demo 3: Factor-sensitive encoding on a 2-node direct system.
    Shows that distinct factor pairs produce distinct delay profiles.
    """
    print("=" * 70)
    print("DEMO 3: Factor-Sensitive Encoding")
    print("=" * 70)
    
    M = 1000
    cost = direct_obs_edge_cost(2, M)
    
    # Test several factor pairs
    factor_pairs = [(3, 5), (5, 3), (7, 11), (11, 7), (2, 37), (37, 2)]
    
    print(f"2-node direct system, M = {M}")
    print(f"Encoding: (p, q) → source weights [p, q]")
    print()
    
    seen_profiles = {}
    for p, q in factor_pairs:
        source = np.array([p, q])
        delay = lens_transform(source, cost)
        profile_key = tuple(delay)
        
        print(f"  ({p:2d}, {q:2d}) → delay = {delay}  "
              f"[N = {p*q:4d}]", end="")
        
        if profile_key in seen_profiles:
            print(f"  ⚠ COLLISION with {seen_profiles[profile_key]}")
        else:
            seen_profiles[profile_key] = (p, q)
            print(f"  ✓ unique")
    
    print()
    print("Note: The encoding is injective on ordered pairs,")
    print("so different (p,q) always produce different delay profiles.")
    print()


def demo_myhill_nerode():
    """
    Demo 4: Myhill–Nerode quotient on a graph with equivalent nodes.
    """
    print("=" * 70)
    print("DEMO 4: Myhill–Nerode Quotient (Node Equivalence)")
    print("=" * 70)
    
    # 6-node graph where some nodes have identical edge cost profiles
    n = 6
    edge_cost = np.array([
        [0, 1, 2, 3, 1, 2],   # Node 0
        [1, 0, 1, 2, 0, 1],   # Node 1 (same profile as node 4)
        [2, 1, 0, 1, 1, 0],   # Node 2 (same profile as node 5)
        [3, 2, 1, 0, 2, 1],   # Node 3
        [1, 0, 1, 2, 0, 1],   # Node 4 (same as node 1)
        [2, 1, 0, 1, 1, 0],   # Node 5 (same as node 2)
    ])
    
    # Compute equivalence classes
    classes = {}
    for i in range(n):
        profile = tuple(edge_cost[i])
        if profile not in classes:
            classes[profile] = []
        classes[profile].append(i)
    
    print(f"Nodes: {n}")
    print(f"Edge cost matrix:")
    print(edge_cost)
    print(f"\nMyhill–Nerode equivalence classes:")
    for k, (profile, nodes) in enumerate(classes.items()):
        print(f"  Class {k}: nodes {nodes} (profile {list(profile)})")
    
    print(f"\n|Quotient| = {len(classes)} ≤ |Node| = {n}  ✓")
    print(f"Compression ratio: {n}/{len(classes)} = {n/len(classes):.1f}x")
    print()


def demo_finite_congruence():
    """
    Demo 5: Finite delay congruence for bounded sources.
    Counts distinct delay profiles from B-bounded sources.
    """
    print("=" * 70)
    print("DEMO 5: Finite Delay Congruence (Bounded Sources)")
    print("=" * 70)
    
    n = 2
    M = 10
    cost = direct_obs_edge_cost(n, M)
    
    for B in [2, 5, 10, 20]:
        profiles = set()
        for s0 in range(B + 1):
            for s1 in range(B + 1):
                source = np.array([s0, s1])
                delay = lens_transform(source, cost)
                profiles.add(tuple(delay))
        
        max_possible = (B + 1) ** n
        print(f"  B = {B:2d}: {len(profiles):4d} distinct profiles "
              f"(out of {max_possible:4d} possible sources, "
              f"ratio = {len(profiles)/max_possible:.2%})")
    
    print()
    print("The number of distinct delay profiles is always finite")
    print("and bounded by (B+1)^|Node| — the tropical Myhill–Nerode compression.")
    print()


# ═══════════════════════════════════════════════════════════════════════════════
# §3. VISUALIZATION (SVG generation)
# ═══════════════════════════════════════════════════════════════════════════════

def generate_berggren_tree_svg() -> str:
    """Generate an SVG visualization of the Berggren tree with tropical lens overlay."""
    width, height = 600, 400
    
    # Berggren tree nodes (a, b, c) with positions
    nodes = {
        (3,4,5): (300, 50),
        (5,12,13): (150, 150),
        (21,20,29): (300, 150),
        (15,8,17): (450, 150),
        (7,24,25): (75, 250),
        (55,48,73): (150, 250),
        (45,28,53): (225, 250),
    }
    
    edges = [
        ((3,4,5), (5,12,13)),
        ((3,4,5), (21,20,29)),
        ((3,4,5), (15,8,17)),
        ((5,12,13), (7,24,25)),
        ((5,12,13), (55,48,73)),
        ((5,12,13), (45,28,53)),
    ]
    
    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}">',
        '<style>',
        '  .node { fill: #2196F3; stroke: #1565C0; stroke-width: 2; }',
        '  .edge { stroke: #90CAF9; stroke-width: 2; fill: none; }',
        '  .label { font-family: monospace; font-size: 11px; text-anchor: middle; fill: white; }',
        '  .cost { font-family: sans-serif; font-size: 9px; text-anchor: middle; fill: #666; }',
        '  .title { font-family: sans-serif; font-size: 16px; font-weight: bold; text-anchor: middle; fill: #333; }',
        '  .signal { stroke: #FF5722; stroke-width: 1.5; stroke-dasharray: 4,3; fill: none; opacity: 0.6; }',
        '</style>',
        f'<text x="{width//2}" y="25" class="title">Berggren Tree with Tropical Lens Signals</text>',
    ]
    
    # Draw edges with costs
    for (n1, n2) in edges:
        x1, y1 = nodes[n1]
        x2, y2 = nodes[n2]
        cost = abs(n1[2] - n2[2])
        mx, my = (x1+x2)//2, (y1+y2)//2
        svg_parts.append(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" class="edge"/>')
        svg_parts.append(f'<text x="{mx+10}" y="{my-5}" class="cost">|{n1[2]}-{n2[2]}|={cost}</text>')
    
    # Draw signal paths (tropical lens)
    svg_parts.append(f'<path d="M 75 250 Q 150 200 300 50" class="signal"/>')
    svg_parts.append(f'<path d="M 225 250 Q 250 200 300 50" class="signal"/>')
    
    # Draw nodes
    for triple, (x, y) in nodes.items():
        a, b, c = triple
        svg_parts.append(f'<circle cx="{x}" cy="{y}" r="20" class="node"/>')
        svg_parts.append(f'<text x="{x}" y="{y+4}" class="label">{a},{b},{c}</text>')
    
    # Legend
    svg_parts.append(f'<text x="50" y="{height-50}" class="cost" style="text-anchor:start">'
                     f'Node color: source weight = leg a</text>')
    svg_parts.append(f'<text x="50" y="{height-35}" class="cost" style="text-anchor:start">'
                     f'Edge label: |c₁ - c₂| (hypotenuse cost)</text>')
    svg_parts.append(f'<text x="50" y="{height-20}" class="cost" style="text-anchor:start">'
                     f'Dashed: tropical signal paths (min-plus geodesics)</text>')
    
    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


def generate_delay_heatmap_svg() -> str:
    """Generate SVG heatmap of delay profiles for bounded sources on 2-node system."""
    size = 300
    B = 15
    M = 100
    cell = size // (B + 1)
    
    svg_parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {size + 80} {size + 60}">',
        '<style>',
        '  .title { font-family: sans-serif; font-size: 14px; font-weight: bold; text-anchor: middle; fill: #333; }',
        '  .axis { font-family: sans-serif; font-size: 10px; text-anchor: middle; fill: #666; }',
        '</style>',
        f'<text x="{size//2 + 40}" y="18" class="title">Delay Profile Classes (2-node system)</text>',
    ]
    
    # Compute delay profiles
    profiles = {}
    color_map = {}
    color_idx = 0
    colors = ['#E3F2FD', '#BBDEFB', '#90CAF9', '#64B5F6', '#42A5F5',
              '#2196F3', '#1E88E5', '#1976D2', '#1565C0', '#0D47A1']
    
    for s0 in range(B + 1):
        for s1 in range(B + 1):
            d0 = min(s0, s1 + M)  # With large M, d0 = s0
            d1 = min(s0 + M, s1)  # d1 = s1
            key = (d0, d1)
            if key not in color_map:
                color_map[key] = colors[color_idx % len(colors)]
                color_idx += 1
            
            x = 40 + s0 * cell
            y = 30 + s1 * cell
            svg_parts.append(
                f'<rect x="{x}" y="{y}" width="{cell}" height="{cell}" '
                f'fill="{color_map[key]}" stroke="#fff" stroke-width="0.5"/>'
            )
    
    # Axis labels
    for i in range(0, B + 1, 5):
        svg_parts.append(f'<text x="{40 + i * cell + cell//2}" y="{size + 48}" class="axis">{i}</text>')
        svg_parts.append(f'<text x="25" y="{30 + i * cell + cell//2 + 3}" class="axis">{i}</text>')
    
    svg_parts.append(f'<text x="{size//2 + 40}" y="{size + 58}" class="axis">Source weight s₀</text>')
    svg_parts.append(f'<text x="10" y="{size//2 + 30}" class="axis" '
                     f'transform="rotate(-90, 10, {size//2 + 30})">s₁</text>')
    
    svg_parts.append('</svg>')
    return '\n'.join(svg_parts)


# ═══════════════════════════════════════════════════════════════════════════════
# §4. MAIN
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("\n" + "=" * 70)
    print("  TROPICAL LENS–BERGGREN DUALITY: DEMONSTRATIONS")
    print("=" * 70 + "\n")
    
    demo_direct_observation()
    demo_pythagorean_shell()
    demo_factor_encoding()
    demo_myhill_nerode()
    demo_finite_congruence()
    
    # Generate visualizations
    tree_svg = generate_berggren_tree_svg()
    with open("berggren_tree.svg", "w") as f:
        f.write(tree_svg)
    print("Generated: berggren_tree.svg")
    
    heatmap_svg = generate_delay_heatmap_svg()
    with open("delay_heatmap.svg", "w") as f:
        f.write(heatmap_svg)
    print("Generated: delay_heatmap.svg")
    
    print("\nAll demos completed successfully.")
