"""
Visualization 3: Functional Graph Structure

Visualizes the functional graph of a mod-p dynamical system,
showing the cycle-and-tree structure that underlies the persistence profile.
Color-codes nodes by preimage size to illustrate the degree sequence.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def mod_p_poly(coeffs, p, x):
    """Evaluate polynomial at x mod p."""
    if x == p:
        return p
    return sum(c * pow(x, i, p) for i, c in enumerate(coeffs)) % p


def find_cycles(map_fn, n):
    """Find all cycles in a functional graph."""
    visited = [False] * n
    in_cycle = [False] * n
    cycles = []

    for start in range(n):
        if visited[start]:
            continue
        path = []
        x = start
        while not visited[x]:
            visited[x] = True
            path.append(x)
            x = map_fn(x)
        # x is now either in a cycle or already processed
        if x in path:
            idx = path.index(x)
            cycle = path[idx:]
            cycles.append(cycle)
            for c in cycle:
                in_cycle[c] = True

    return cycles, in_cycle


def layout_functional_graph(map_fn, n):
    """Compute positions for nodes in a functional graph layout."""
    cycles, in_cycle = find_cycles(map_fn, n)
    positions = {}

    # Layout cycles in concentric rings
    center_x, center_y = 0.0, 0.0

    for ci, cycle in enumerate(cycles):
        r = 2.0 + ci * 1.5
        for i, node in enumerate(cycle):
            angle = 2 * math.pi * i / len(cycle) + ci * 0.5
            positions[node] = (center_x + r * math.cos(angle),
                               center_y + r * math.sin(angle))

    # Layout tree nodes by BFS from cycle
    queue = [x for x in range(n) if in_cycle[x]]
    # Find reverse map
    reverse = [[] for _ in range(n)]
    for x in range(n):
        reverse[map_fn(x)].append(x)

    layer = 0
    while queue:
        next_queue = []
        for parent in queue:
            px, py = positions[parent]
            children = [c for c in reverse[parent] if c not in positions]
            for i, child in enumerate(children):
                angle = math.atan2(py - center_y, px - center_x)
                spread = 0.8 / (1 + layer)
                offset = (i - len(children) / 2) * spread
                dist = 1.2
                positions[child] = (px + dist * math.cos(angle + offset),
                                    py + dist * math.sin(angle + offset))
                next_queue.append(child)
        queue = next_queue
        layer += 1

    # Place any remaining nodes
    for x in range(n):
        if x not in positions:
            positions[x] = (5.0 + x * 0.3, 5.0)

    return positions, cycles, in_cycle


# Create figure with 4 subplots for different maps
fig, axes = plt.subplots(2, 2, figsize=(14, 14))
axes = axes.flatten()

p = 11
n = p + 1
maps_info = [
    ([0, 0, 1], "x² mod 11"),
    ([1, 0, 1], "x²+1 mod 11"),
    ([3, 0, 1], "x²+3 mod 11"),
    ([0, 0, 0, 1], "x³ mod 11"),
]

for idx, (coeffs, title) in enumerate(maps_info):
    ax = axes[idx]
    f = lambda x, c=coeffs: mod_p_poly(c, p, x)

    # Compute preimage sizes
    pre_sizes = [0] * n
    for x in range(n):
        pre_sizes[f(x)] += 1

    positions, cycles, in_cycle = layout_functional_graph(f, n)

    # Draw edges
    for x in range(n):
        if x in positions and f(x) in positions:
            x1, y1 = positions[x]
            x2, y2 = positions[f(x)]
            dx, dy = x2 - x1, y2 - y1
            ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                        arrowprops=dict(arrowstyle="->", color='gray',
                                        alpha=0.5, connectionstyle="arc3,rad=0.1"))

    # Draw nodes colored by preimage size
    max_pre = max(pre_sizes) if pre_sizes else 1
    for x in range(n):
        if x not in positions:
            continue
        px, py = positions[x]
        size = pre_sizes[x]
        color_val = size / max(max_pre, 1)

        # Cycle nodes are squares, tree nodes are circles
        if in_cycle[x]:
            marker = 's'
            ms = 12
        else:
            marker = 'o'
            ms = 8

        ax.plot(px, py, marker, markersize=ms,
                color=plt.cm.YlOrRd(color_val),
                markeredgecolor='black', markeredgewidth=0.5)

        label = str(x) if x < p else '∞'
        ax.annotate(label, (px, py), textcoords="offset points",
                    xytext=(0, -15), ha='center', fontsize=7)

    # Compute invariants
    entropy_val = math.log(n) - sum(math.log(s + 1) for s in pre_sizes) / n
    deg_seq = sorted(pre_sizes)
    fixed = sum(1 for x in range(n) if f(x) == x)

    ax.set_title(f'{title}\nFixed pts: {fixed}, Entropy: {entropy_val:.3f}', fontsize=11)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.1)
    ax.set_xlim(-6, 8)
    ax.set_ylim(-6, 8)

fig.suptitle('Functional Graphs of Mod-p Dynamical Systems\n'
             '(□ = cycle node, ○ = tree node, color = preimage size)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_functional_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_functional_graph.png")
