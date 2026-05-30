"""
Visualization 3: Functional Graph Structure

Visualizes the functional graph of x -> x^2 + c (mod p) for different
primes and parameters, showing the tree-and-cycle decomposition that
underlies the orbit signature. Each node is a residue class, and edges
show the action of the map. Cycle elements are highlighted.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import sqrt, pi, cos, sin


def compute_orbits(f, n):
    """Compute orbit data for f on {0, ..., n-1}."""
    preperiods = {}
    periods = {}
    for x in range(n):
        seen = {}
        val = x
        step = 0
        while val not in seen:
            seen[val] = step
            val = f(val)
            step += 1
        cycle_start = seen[val]
        period = step - cycle_start
        preperiods[x] = max(0, cycle_start - seen.get(x, 0))
        periods[x] = period
    
    # Identify cycle elements
    cycles = set()
    for x in range(n):
        if preperiods[x] == 0:
            # Check if truly on cycle
            val = f(x)
            path = [x]
            while val != x:
                path.append(val)
                val = f(val)
            for pt in path:
                cycles.add(pt)
    
    return preperiods, periods, cycles


def draw_functional_graph(ax, f, n, title):
    """Draw the functional graph of f on {0, ..., n-1}."""
    preperiods, periods, cycles = compute_orbits(f, n)
    
    # Layout: place cycle elements in a circle, tree elements outside
    cycle_list = sorted(cycles)
    tree_list = [x for x in range(n) if x not in cycles]
    
    positions = {}
    
    # Place cycle elements in a circle
    if cycle_list:
        for i, x in enumerate(cycle_list):
            angle = 2 * pi * i / len(cycle_list) - pi / 2
            positions[x] = (0.5 + 0.25 * cos(angle), 0.5 + 0.25 * sin(angle))
    
    # Place tree elements outside, near their eventual cycle entry
    for x in tree_list:
        # Find which cycle element this tree node leads to
        val = x
        depth = 0
        while val not in cycles:
            val = f(val)
            depth += 1
        # Place near the cycle entry with some offset
        if val in positions:
            cx, cy = positions[val]
            angle = 2 * pi * (hash((x, depth)) % 360) / 360
            r = 0.15 + 0.08 * depth
            positions[x] = (cx + r * cos(angle), cy + r * sin(angle))
        else:
            positions[x] = (np.random.uniform(0.1, 0.9), np.random.uniform(0.1, 0.9))
    
    # Draw edges
    for x in range(n):
        y = f(x)
        if x != y:
            x1, y1 = positions[x]
            x2, y2 = positions[y]
            dx, dy = x2 - x1, y2 - y1
            length = sqrt(dx*dx + dy*dy)
            if length > 0:
                # Shorten arrow slightly
                shrink = 0.02
                ax.annotate('', xy=(x2 - shrink*dx/length, y2 - shrink*dy/length),
                          xytext=(x1 + shrink*dx/length, y1 + shrink*dy/length),
                          arrowprops=dict(arrowstyle='->', color='#7f8c8d',
                                        lw=0.8, connectionstyle='arc3,rad=0.1'))
    
    # Draw nodes
    for x in range(n):
        px, py = positions[x]
        if x in cycles:
            circle = plt.Circle((px, py), 0.025, color='#e74c3c',
                              ec='#c0392b', linewidth=1.5, zorder=5)
            ax.add_patch(circle)
            ax.text(px, py, str(x), ha='center', va='center',
                   fontsize=7, fontweight='bold', color='white', zorder=6)
        else:
            circle = plt.Circle((px, py), 0.02, color='#3498db',
                              ec='#2980b9', linewidth=1, zorder=5)
            ax.add_patch(circle)
            ax.text(px, py, str(x), ha='center', va='center',
                   fontsize=6, color='white', zorder=6)
    
    # Stats
    cycle_count = 0
    counted = set()
    for x in cycles:
        if x not in counted:
            cycle_count += 1
            val = f(x)
            counted.add(x)
            while val != x:
                counted.add(val)
                val = f(val)
    
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=10, fontweight='bold')
    ax.text(0.02, 0.02, f'{len(cycles)} periodic, {len(tree_list)} tree, {cycle_count} cycles',
            fontsize=7, transform=ax.transAxes,
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    ax.axis('off')


# Create figure
fig, axes = plt.subplots(3, 3, figsize=(15, 15))
fig.suptitle('Functional Graphs of x → x² + c (mod p)\nRed = Periodic Points, Blue = Tree Points',
             fontsize=16, fontweight='bold')

configs = [
    (11, 0), (11, -1), (11, 3),
    (13, 0), (13, -1), (13, 3),
    (17, 0), (17, -1), (17, 3),
]

for idx, (p, c) in enumerate(configs):
    ax = axes[idx // 3][idx % 3]
    f = lambda x, p=p, c=c: (x * x + c) % p
    draw_functional_graph(ax, f, p, f'p = {p}, c = {c}')

plt.tight_layout()
plt.savefig('functional_graphs.png', dpi=150, bbox_inches='tight')
print("Saved functional_graphs.png")
